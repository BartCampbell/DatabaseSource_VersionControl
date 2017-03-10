SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/7/2012
-- Description:	Applies the claims and claims attributes identified during event processing
--				to the associated tables in the Claims schema.
--				(Originally extracted and tweaked from Batch.CombineClaims_v2)
-- =============================================
CREATE PROCEDURE [Batch].[ApplyClaimUpdates]
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
		SET @LogEntryXrefGuid = '21F4B6B5-6EFC-44B2-BCEE-973FB30836A0';
		SET @LogObjectName = 'ApplyClaimUpdates'; 
		SET @LogObjectSchema = 'Batch'; 
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Applying claim updates failed!  No batch was specified.', 16, 1);
				
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
			
			--Determine Engine Type and Settings...
			DECLARE @AllowClaimUpdates bit;
			DECLARE @AllowFinalizePurgeInternal bit;
			DECLARE @AllowFinalizePurgeLog bit;
			DECLARE @AllowTruncate bit;
			
		SELECT TOP 1
				@AllowClaimUpdates = ET.AllowClaimUpdates,
				@AllowFinalizePurgeInternal = ET.AllowFinalizePurgeInternal,
				@AllowFinalizePurgeLog = ET.AllowFinalizePurgeLog,
				@AllowTruncate = ET.AllowTruncate
		FROM	Engine.Settings AS ES
				INNER JOIN Engine.[Types] AS ET
						ON ES.EngineTypeID = ET.EngineTypeID;
	
			
			SET @CountRecords = 0;
			
			DECLARE @UpdateClaims bit;
			IF EXISTS (SELECT TOP 1 1 FROM Claim.ClaimLines WITH(NOLOCK) WHERE DataSetID = @DataSetID)
				SET @UpdateClaims = 1;
			ELSE
				SET @UpdateClaims = 0;

			--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			IF @Ansi_Warnings = 0
				SET ANSI_WARNINGS ON;

				
			IF @UpdateClaims = 1 AND ISNULL(@AllowClaimUpdates, 0) = 1
				BEGIN;
					--1) Claim Lines
					UPDATE	CL
					SET		DSClaimID = t.DSClaimID 
					FROM	Claim.ClaimLines AS CL
							INNER JOIN Proxy.ClaimLines AS t
									ON CL.DSClaimLineID = t.DSClaimLineID AND
										CL.DSClaimID IS NULL;
										
					SELECT @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
				
					--2) Claim Codes
					UPDATE	CC
					SET		DSClaimID = t.DSClaimID 
					FROM	Claim.ClaimCodes AS CC
							INNER JOIN Proxy.ClaimCodes AS t
									ON CC.DSClaimCodeID = t.DSClaimCodeID AND
										--CC.DSClaimLineID = t.DSClaimLineID AND
										CC.DSClaimID IS NULL;
					
					SELECT @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
				
					--3) Claims
					DELETE FROM Claim.Claims WHERE DataSetID = @DataSetID;
				
					INSERT INTO Claim.Claims
							(BeginDate,
							ClaimTypeID,
							DataSetID,
							DSClaimID,
							DSMemberID,
							DSProviderID,
							EndDate,
							LOS,
							POS,
							ServDate)
					SELECT	BeginDate,
							ClaimTypeID,
							DataSetID,
							DSClaimID,
							DSMemberID,
							DSProviderID,
							EndDate,
							LOS,
							POS,
							ServDate 
					FROM	Proxy.Claims;
					
					SELECT @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
				
					--4) Claim Attributes
					DELETE FROM Claim.ClaimAttributes WHERE DataSetID = @DataSetID;
					
					INSERT INTO Claim.ClaimAttributes
							(ClaimAttribID,
							DataSetID,
							DSClaimAttribID,
							DSClaimLineID,
							DSMemberID)
					SELECT	ClaimAttribID,
							DataSetID,
							DSClaimAttribID,
							DSClaimLineID,
							DSMemberID 
					FROM	Proxy.ClaimAttributes;
					
					SELECT @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
				END;
			
			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS ON;
			ELSE
				SET ANSI_WARNINGS OFF;
						
			SET @LogDescr = ' - Applying claim updates for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
			SET @LogDescr = '- Applying claim updates for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; 
			
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
GRANT VIEW DEFINITION ON  [Batch].[ApplyClaimUpdates] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[ApplyClaimUpdates] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[ApplyClaimUpdates] TO [Processor]
GO
