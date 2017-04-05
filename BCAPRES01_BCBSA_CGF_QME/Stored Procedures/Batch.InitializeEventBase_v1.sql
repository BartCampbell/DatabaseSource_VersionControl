SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/28/2011
-- Description:	Populates the Temp.EventBase table with initial data needed to determine events: event options ranked at 1. (v1)
-- =============================================
CREATE PROCEDURE [Batch].[InitializeEventBase_v1]
(
	@BatchID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @Result int;	

	DECLARE @BeginInitSeedDate datetime;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'InitializeEventBase'; 
		SET @LogObjectSchema = 'Batch'; 
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Initizialization of event-based details failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords int;
			
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
			
			---------------------------------------------------------------------------
			DECLARE @ClaimTypeE tinyint;
			/*DECLARE @ClaimTypeL tinyint;*/
			DECLARE @ClaimTypeP tinyint;

			SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
			/*SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';*/
			SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';

			/*DECLARE @EventTypeC tinyint;
			DECLARE @EventTypeL tinyint;
			DECLARE @EventTypeD tinyint;
			DECLARE @EventTypeP tinyint;

			SELECT @EventTypeC = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'C'
			SELECT @EventTypeL = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'L'
			SELECT @EventTypeD = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'D'
			SELECT @EventTypeP = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'P'*/
			----------------------------------------------------------------------------
			
			IF OBJECT_ID('tempdb..#EventBase') IS NOT NULL
				DROP TABLE #EventBase;
			
			DELETE FROM Proxy.EventBase;
			
			CREATE TABLE #EventBase
			(
				Allow bit NOT NULL,
				BatchID int NOT NULL,
				BeginDate datetime NOT NULL,
				ClaimTypeID tinyint NOT NULL,
				CodeID int NULL,
				CountAllowed int NULL,
				CountCriteria int NULL,
				CountDenied int NULL,
				DataRunID int NOT NULL,
				DataSetID int NOT NULL,
				[Days] smallint NULL,
				DSClaimID bigint NULL,
				DSClaimLineID bigint NOT NULL,
				DSMemberID bigint NOT NULL,
				DSProviderID bigint NULL,
				EndDate datetime NULL,
				EventBaseID bigint NOT NULL IDENTITY(1, 1),
				EventCritID int NOT NULL,
				EventID int NOT NULL,
				EventTypeID tinyint NOT NULL,
				HasCodeReqs bit NULL,
				HasDateReqs bit NULL,
				HasEnrollReqs bit NULL,
				HasMemberReqs bit NULL,
				HasProviderReqs bit NULL,
				IsPaid bit NOT NULL,
				OptionNbr tinyint NOT NULL,
				RankOrder smallint NOT NULL,
				Value decimal(18, 6) NULL
			);
				
			INSERT INTO #EventBase
			        (Allow,
			         BatchID,
			         BeginDate,
			         ClaimTypeID,
			         CodeID,
			         CountAllowed,
			         CountCriteria,
			         CountDenied,
			         DataRunID,
			         DataSetID,
			         [Days],
			         DSClaimID,
			         DSClaimLineID,
			         DSMemberID,
			         DSProviderID,
			         EndDate,
			         EventCritID,
			         EventID,
			         EventTypeID,
			         HasCodeReqs,
			         HasDateReqs,
			         HasEnrollReqs,
			         HasMemberReqs,
			         HasProviderReqs,
			         IsPaid,
			         OptionNbr,
			         RankOrder,
			         Value)
			--Portion with Codes--------------------------------
			SELECT DISTINCT
					TEK.Allow,
					@BatchID AS BatchID,
					ISNULL(CC.BeginDate, CCL.BeginDate) AS BeginDate,
					CCL.ClaimTypeID,
					CCC.CodeID,
					TEK.CountAllowed,
					TEK.CountCriteria,
					TEK.CountDenied,
					@DataRunID AS DataRunID,
					@DataSetID AS DataSetID,
					CONVERT(smallint, CASE WHEN TEK.ClaimTypeID IN (@ClaimTypeE, @ClaimTypeP) THEN CASE WHEN CCL.[Days] BETWEEN 0 AND (365 * 5) + 1 THEN CCL.[Days] ELSE 0 END END) AS [Days],
					CCC.DSClaimID,
					CCC.DSClaimLineID,
					CCL.DSMemberID,
					CCL.DSProviderID,
					ISNULL(CC.EndDate, CCL.EndDate) AS EndDate,
					TEK.EventCritID,
					TEK.EventID,
					TEK.EventTypeID,
					TEK.HasCodeReqs,
					TEK.HasDateReqs,
					TEK.HasEnrollReqs,
					TEK.HasMemberReqs,
					TEK.HasProviderReqs,
					CCL.IsPaid,
					TEK.OptionNbr,
					TEK.RankOrder,
					--Nested ISNULLs instead of COALESCE to preserve data type 
					CAST(CASE TEK.ValueTypeID 
							WHEN 1 THEN ISNULL(TEK.Value, ISNULL(CCL.LabValue, TEK.DefaultValue))
							WHEN 2 THEN ISNULL(TEK.Value, ISNULL(CAST(CCL.IsPositive AS decimal(18,6)), TEK.DefaultValue))
							END AS decimal(18,6)) AS Value
			FROM	Proxy.ClaimCodes AS CCC
					INNER JOIN Proxy.ClaimLines AS CCL
							ON CCC.DSClaimLineID = CCL.DSClaimLineID
					LEFT OUTER JOIN Proxy.Claims AS CC
							ON CCC.DSClaimID = CC.DSClaimID AND
								CCL.DSClaimID = CC.DSClaimID
					INNER JOIN Proxy.EventKey AS TEK
							ON CCC.CodeID = TEK.CodeID AND
								--Only Allowed and RankOrder 1
								TEK.RankOrder = 1 AND TEK.Allow = 1 AND
								--Filter Encounter-based Lab *Requests*, if applicable
								((TEK.AllowLab = 1 OR (TEK.AllowLab = 0 AND ((CCL.CPT IS NULL) OR 
																			(CCL.POS IS NULL) OR 
																			(NOT (CCL.CPT LIKE '8____' AND CCL.POS = '81' AND CCL.ClaimTypeID = @ClaimTypeE)))))) AND
								--Filter Paid Claims, if applicable
								(TEK.RequirePaid = 0 OR (TEK.RequirePaid = 1 AND CCL.IsPaid = 1)) AND
								--Filter Primary diagnoses/procedures, if applicable
								(TEK.RequirePrimary = 0 OR (TEK.RequirePrimary = 1 AND CCC.IsPrimary = 1))
			UNION ALL
			--Portion without Codes, Only Provider Specialties 
			SELECT DISTINCT
					TEK.Allow,
					@BatchID AS BatchID,
					ISNULL(CC.BeginDate, CCL.BeginDate) AS BeginDate,
					CCL.ClaimTypeID,
					TEK.CodeID,
					TEK.CountAllowed,
					TEK.CountCriteria,
					TEK.CountDenied,
					@DataRunID AS DataRunID,
					@DataSetID AS DataSetID,
					CONVERT(smallint, NULL) AS [Days],
					CCL.DSClaimID,
					CCL.DSClaimLineID,
					CCL.DSMemberID,
					CCL.DSProviderID,
					ISNULL(CC.EndDate, CCL.EndDate) AS EndDate,
					TEK.EventCritID,
					TEK.EventID,
					TEK.EventTypeID,
					TEK.HasCodeReqs,
					TEK.HasDateReqs,
					TEK.HasEnrollReqs,
					TEK.HasMemberReqs,
					TEK.HasProviderReqs,
					CCL.IsPaid,
					TEK.OptionNbr,
					TEK.RankOrder,
					--Nested ISNULLs instead of COALESCE to preserve data type
					CAST(CASE TEK.ValueTypeID 
							WHEN 1 THEN ISNULL(TEK.Value, ISNULL(CCL.LabValue, TEK.DefaultValue))
							WHEN 2 THEN ISNULL(TEK.Value, ISNULL(CAST(CCL.IsPositive AS decimal(18,6)), TEK.DefaultValue))
							END AS decimal(18,6)) AS Value
			FROM	Proxy.ClaimLines AS CCL
					LEFT OUTER JOIN Proxy.Claims AS CC
							ON CCL.DSClaimID = CC.DSClaimID
					INNER JOIN Proxy.Providers AS PP
							ON CCL.DSProviderID = PP.DSProviderID AND
								CCL.BatchID = PP.BatchID AND
								CCL.DataSetID = PP.DataSetID
					INNER JOIN Proxy.ProviderSpecialties AS PPS
							ON PP.BatchID = PPS.BatchID AND
								PP.DataSetID = PPS.DataSetID AND
								PP.DSProviderID = PPS.DSProviderID
					INNER JOIN Measure.EventCriteriaSpecialties AS MECS
							ON PPS.SpecialtyID = MECS.SpecialtyID 
					INNER JOIN Proxy.EventKey AS TEK
							ON TEK.HasCodeReqs = 0 AND
								TEK.EventCritID = MECS.EventCritID AND
								TEK.HasProviderReqs = 1 AND
								--Only Allowed and RankOrder 1
								TEK.RankOrder = 1 AND TEK.Allow = 1 AND
								--Filter Encounter-based Lab *Requests*, if applicable
								((TEK.AllowLab = 1 OR (TEK.AllowLab = 0 AND ((CCL.CPT IS NULL) OR 
																			(CCL.POS IS NULL) OR 
																			(NOT (CCL.CPT LIKE '8____' AND CCL.POS = '81' AND CCL.ClaimTypeID = @ClaimTypeE)))))) AND
								--Filter Paid Claims, if applicable
								(TEK.RequirePaid = 0 OR (TEK.RequirePaid = 1 AND CCL.IsPaid = 1))
			ORDER BY DSMemberID, EventID, OptionNbr;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			CREATE CLUSTERED INDEX IX_#EventBase ON #EventBase (EventBaseID, RankOrder, CodeID, DSClaimLineID);
						
			INSERT INTO Proxy.EventBase
					(Allow,
					BatchID,
					BeginDate,
					ClaimTypeID,
					CodeID,
					CountAllowed,
					CountCriteria,
					CountDenied,
					DataRunID,
					DataSetID,
					[Days],
					DSClaimID,
					DSClaimLineID,
					DSMemberID,
					DSProviderID,
					EndDate,
					EventBaseID,
					EventCritID,
					EventID,
					EventTypeID,
					HasCodeReqs,
					HasDateReqs,
					HasEnrollReqs,
					HasMemberReqs,
					HasProviderReqs,
					IsPaid,
					OptionNbr,
					RankOrder,
					Value)
			SELECT	Allow,
					BatchID,
					BeginDate,
					ClaimTypeID,
					CodeID,
					CountAllowed,
					CountCriteria,
					CountDenied,
					DataRunID,
					DataSetID,
					[Days],
					DSClaimID,
					DSClaimLineID,
					DSMemberID,
					DSProviderID,
					EndDate,
					EventBaseID,
					EventCritID,
					EventID,
					EventTypeID,
					HasCodeReqs,
					HasDateReqs,
					HasEnrollReqs,
					HasMemberReqs,
					HasProviderReqs,
					IsPaid,
					OptionNbr,
					RankOrder,
					Value
			FROM	#EventBase
			ORDER BY EventBaseID, RankOrder, CodeID, DSClaimLineID;
						
			SET @LogDescr = ' - Initizialization of event-based details for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = @CountRecords,
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogEndTime, 
												@IsSuccess = 1,
												@SrcObjectName = @LogObjectName,
												@SrcObjectSchema = @LogObjectSchema;

			--COMMIT TRANSACTION T1;

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
			SET @LogDescr = ' - Initizialization of event-based details for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = -1, 
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogBeginTime,
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
GRANT EXECUTE ON  [Batch].[InitializeEventBase_v1] TO [Processor]
GO
