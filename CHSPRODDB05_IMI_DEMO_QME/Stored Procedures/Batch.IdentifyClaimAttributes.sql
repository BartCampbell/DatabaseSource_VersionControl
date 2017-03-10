SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/7/2012
-- Description:	Identifies claim attributes based on pre-compiling the associated events.
--				(Originally extracted and tweaked from Batch.CombineClaims_v2)
-- =============================================
CREATE PROCEDURE [Batch].[IdentifyClaimAttributes]
(
	@BatchID int
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogEntryXrefGuid uniqueidentifier;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	DECLARE @Result int;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'IdentifyClaimAttributes'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Identifying claim attributes failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords int;
			DECLARE @EDCombineDays smallint;
			
			SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
					@DataRunID = DR.DataRunID,
					@DataSetID = DS.DataSetID,
					@EndInitSeedDate = DR.EndInitSeedDate,
					@IsLogged = DR.IsLogged,
					@MeasureSetID = DR.MeasureSetID,
					@OwnerID = DS.OwnerID,
					@SeedDate = DR.SeedDate
			FROM	Batch.[Batches] AS B 
					INNER JOIN Batch.DataRuns AS DR
							ON B.DataRunID = DR.DataRunID
					INNER JOIN Batch.DataSets AS DS 
							ON B.DataSetID = DS.DataSetID 
			WHERE	(B.BatchID = @BatchID);
			
			SELECT	@EDCombineDays = EDCombineDays FROM Batch.DataOwners WHERE OwnerID = @OwnerID;
			
			DECLARE @ClaimTypeE tinyint;
			DECLARE @ClaimTypeL tinyint;
			DECLARE @ClaimTypeP tinyint;

			SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
			SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';
			SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';
			
			DECLARE @ClaimAttribIN smallint;
			DECLARE @ClaimAttribAIN smallint;
			DECLARE @ClaimAttribNIN smallint;
			DECLARE @ClaimAttribED smallint;
			DECLARE @ClaimAttribOUT smallint;

			SELECT @ClaimAttribIN = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'IN';
			SELECT @ClaimAttribAIN = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'AIN';
			SELECT @ClaimAttribNIN = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'NIN';
			SELECT @ClaimAttribED = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'ED';
			SELECT @ClaimAttribOUT = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'OUT';

			IF OBJECT_ID('tempdb..#EventOptions') IS NOT NULL
				DROP TABLE #EventOptions;
				
			--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			IF @Ansi_Warnings = 0
				SET ANSI_WARNINGS ON;

			--1) Identify potential claim attribute events...
			SELECT DISTINCT
					VK.AllowEndDate,
					VK.BeginDate,
					MVTCA.ClaimAttribID,
					CA.ClaimTypeID,
					VK.EndDate,
					VK.EventID,
					VK.RequireEndDate
			INTO	#EventKey
			FROM	Proxy.EventKey AS VK
					INNER JOIN Measure.EventsToClaimAttributes AS MVTCA
							ON VK.EventID = MVTCA.EventID
					INNER JOIN Claim.Attributes AS CA
							ON MVTCA.ClaimAttribID = CA.ClaimAttribID;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#EventKey ON #EventKey (EventID);
			
			SELECT	MIN(VB.BeginDate) AS BeginDate,
					t.ClaimAttribID,
					MIN(VB.ClaimTypeID) AS ClaimTypeID,
					ISNULL(MAX(VB.EndDate), MIN(VB.BeginDate)) AS CompareDate,
					MIN(VB.DSClaimLineID) AS DSClaimLineID,
					MIN(VB.DSMemberID) AS DSMemberID,
					MAX(VB.EndDate) AS EndDate,
					VB.EventBaseID,
					VB.EventID,
					VB.OptionNbr AS OptionNbr
			INTO	#EventOptions
			FROM	Proxy.EventBase AS VB
					INNER JOIN #EventKey AS t
							ON VB.EventID = t.EventID AND
								VB.ClaimTypeID = t.ClaimTypeID
			GROUP BY t.ClaimAttribID,
					VB.EventBaseID,
					VB.EventID,
					VB.OptionNbr 
			HAVING	(COUNT(DISTINCT CASE WHEN VB.Allow = 1 THEN VB.EventCritID END) >= MAX(VB.CountAllowed)) AND
					(COUNT(DISTINCT CASE WHEN VB.Allow = 0 THEN VB.EventCritID END) = 0);
								
			CREATE UNIQUE CLUSTERED INDEX IX_#EventOptions ON #EventOptions (EventID, OptionNbr, EventBaseID);
								
			--2) Evaluate claim attribute events...
			IF OBJECT_ID('tempdb..#ClaimLineAttribs') IS NOT NULL
				DROP TABLE #ClaimLineAttribs;
				
			SELECT DISTINCT
					V.ClaimAttribID, V.DSMemberID, V.DSClaimLineID, V.EventID
			INTO	#ClaimLineEvents
			FROM	#EventKey AS DV
					INNER JOIN #EventOptions AS V
							ON DV.EventID = V.EventID AND
								(
									(V.ClaimTypeID <> @ClaimTypeE) OR
									(
										(V.ClaimTypeID = @ClaimTypeE) AND
										(
											(DV.BeginDate IS NULL) OR
											(DV.BeginDate IS NOT NULL AND DV.BeginDate <= V.CompareDate)
										) AND
										(
											(DV.EndDate IS NULL) OR
											(DV.EndDate IS NOT NULL AND DV.EndDate >= V.CompareDate)
										)
									)
								);
			
			
			CREATE UNIQUE CLUSTERED INDEX IX_#ClaimLineEvents ON #ClaimLineEvents (DSClaimLineID, ClaimAttribID);
			
			SELECT
					CLV.ClaimAttribID,
					IDENTITY(bigint, 1, 1) AS DSClaimAttribID, 
					CLV.DSClaimLineID,
					CLV.DSMemberID
			INTO	#ClaimLineAttribs
			FROM	#ClaimLineEvents AS CLV
					INNER JOIN Proxy.ClaimLines AS CL
							ON CLV.DSClaimLineID = CL.DSClaimLineID
			WHERE	(CL.DSClaimID IS NULL);
			
			DROP TABLE #ClaimLineEvents;
			DROP TABLE #EventKey;						
				
			IF OBJECT_ID('tempdb..#EventOptions') IS NOT NULL
				DROP TABLE #EventOptions;
								
			CREATE UNIQUE CLUSTERED INDEX IX_#ClaimLineAttribs ON #ClaimLineAttribs (DSClaimLineID, ClaimAttribID);

			--Insert identified attributes
			DELETE FROM Proxy.ClaimAttributes;

			INSERT INTO Proxy.ClaimAttributes 
					(BatchID, ClaimAttribID, DataRunID, DataSetID, 
					DSClaimAttribID, DSClaimLineID, DSMemberID)
			SELECT	DISTINCT
					@BatchID AS BatchID,
					CLA.ClaimAttribID,
					@DataRunID AS DataRunID,
					@DataSetID AS DataSetID,
					CLA.DSClaimAttribID,
					CLA.DSClaimLineID,
					CLA.DSMemberID
			FROM	#ClaimLineAttribs AS CLA
			ORDER BY DSClaimLineID, ClaimAttribID;	
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS ON;
			ELSE
				SET ANSI_WARNINGS OFF;
						
			SET @LogDescr = ' - Identifying claim attributes for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = @CountRecords,
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogEndTime, 
												@EntryXrefGuid = @LogEntryXrefGuid,
												@IsSuccess = 1,
												@SrcObjectName = @LogObjectName,
												@SrcObjectSchema = @LogObjectSchema;

			RETURN 0;
		END TRY
		BEGIN CATCH;
			IF @@TRANCOUNT > 0
				ROLLBACK;
				
			DECLARE @ErrorLine int;
			DECLARE @ErrorLogID int;
			DECLARE @ErrorMessage nvarchar(max);
			DECLARE @ErrorNumber int;
			DECLARE @ErrorSeverity int;
			DECLARE @ErrorSource nvarchar(512);
			DECLARE @ErrorState int;
			
			DECLARE @ErrorResult int;
			
			SELECT	@ErrorLine = ERROR_LINE(),
					@ErrorMessage = ERROR_MESSAGE(),
					@ErrorNumber = ERROR_NUMBER(),
					@ErrorSeverity = ERROR_SEVERITY(),
					@ErrorSource = ERROR_PROCEDURE(),
					@ErrorState = ERROR_STATE();
					
			EXEC @ErrorResult = [Log].RecordError	@LineNumber = @ErrorLine,
													@Message = @ErrorMessage,
													@ErrorNumber = @ErrorNumber,
													@ErrorType = 'Q',
													@ErrLogID = @ErrorLogID OUTPUT,
													@Severity = @ErrorSeverity,
													@Source = @ErrorSource,
													@State = @ErrorState,
													@PerformRollback = 0;
			
			
			SET @LogEndTime = GETDATE();
			SET @LogDescr = ' - Identifying claim attributes for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = -1,
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID, 
												@Descr = @LogDescr,
												@EndTime = @LogBeginTime,
												@EntryXrefGuid = @LogEntryXrefGuid,
												@ErrLogID = @ErrorLogID,
												@IsSuccess = 0,
												@SrcObjectName = @LogObjectName,
												@SrcObjectSchema = @LogObjectSchema;
														
			SET @ErrorMessage = REPLACE(@LogDescr, '!', ': ') + @ErrorMessage + ' (Error: ' + CAST(@ErrorNumber AS nvarchar) + ')';
			RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
		END CATCH;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(max);
		DECLARE @ErrNumber int;
		DECLARE @ErrSeverity int;
		DECLARE @ErrSource nvarchar(512);
		DECLARE @ErrState int;
		
		DECLARE @ErrResult int;
		
		SELECT	@ErrApp = DB_NAME(),
				@ErrLine = ERROR_LINE(),
				@ErrMessage = ERROR_MESSAGE(),
				@ErrNumber = ERROR_NUMBER(),
				@ErrSeverity = ERROR_SEVERITY(),
				@ErrSource = ERROR_PROCEDURE(),
				@ErrState = ERROR_STATE();
				
		EXEC @ErrResult = [Log].RecordError	@Application = @ErrApp,
											@LineNumber = @ErrLine,
											@Message = @ErrMessage,
											@ErrorNumber = @ErrNumber,
											@ErrorType = 'Q',
											@ErrLogID = @ErrLogID OUTPUT,
											@Severity = @ErrSeverity,
											@Source = @ErrSource,
											@State = @ErrState;
		
		IF @ErrResult <> 0
			BEGIN
				PRINT '*** Error Log Failure:  Unable to record the specified entry. ***'
				SET @ErrNumber = @ErrLine * -1;
			END
			
		RETURN @ErrNumber;
	END CATCH;
END







GO
GRANT VIEW DEFINITION ON  [Batch].[IdentifyClaimAttributes] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[IdentifyClaimAttributes] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[IdentifyClaimAttributes] TO [Processor]
GO
