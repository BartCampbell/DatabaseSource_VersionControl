SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/22/2015
-- Description:	Summarizes the claim lines.
-- =============================================
CREATE PROCEDURE [Result].[SummarizeClaims]
(
	@DataRunID int,
	@BatchID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogEntryXrefGuid uniqueidentifier;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @Result int;

	DECLARE @DataSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'SummarizeClaims'; 
		SET @LogObjectSchema = 'Result'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;				
			DECLARE @CountRecords int;
			
			SELECT TOP 1	
					--@DataRunID = B.DataRunID,
					@DataSetID = DS.DataSetID,
					@MbrMonthID = DR.MbrMonthID,
					@MeasureSetID = DR.MeasureSetID,
					@OwnerID = DS.OwnerID,
					@SeedDate = DR.SeedDate
			FROM	Batch.[Batches] AS B 
					INNER JOIN Batch.DataSets AS DS 
							ON B.DataSetID = DS.DataSetID 
					INNER JOIN Batch.DataRuns AS DR
							ON B.DataRunID = DR.DataRunID
			WHERE	(DR.DataRunID = @DataRunID) AND
					((@BatchID IS NULL) OR (B.BatchID = @BatchID));
			
			---------------------------------------------------------------------------
			
			--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS OFF;
			
			--1) Purges existing claim lines summary data, if any, and copies new summary data...
			DELETE FROM Result.ClaimLineSummary WHERE (DataRunID = @DataRunID);

			IF NOT EXISTS (SELECT TOP 1 1 FROM Result.ClaimLineSummary)
				TRUNCATE TABLE Result.ClaimLineSummary;
				
			INSERT INTO Result.ClaimLineSummary
					(ClaimMonth,
					 ClaimSrcTypeID,
					 ClaimTypeID,
					 ClaimYear,
					 CountClaimLines,
					 CountMembers,
					 DataRunID,
					 DataSetID,
					 DataSourceID)
			SELECT	MONTH(ISNULL(CCL.EndDate, CCL.BeginDate)) AS ClaimMonth,
					CCL.ClaimSrcTypeID,
					CCL.ClaimTypeID,
					Year(ISNULL(CCL.EndDate, CCL.BeginDate)) AS ClaimYear,
					COUNT(DISTINCT CCL.DSClaimLineID) AS CountClaimLines,
					COUNT(DISTINCT CCL.DSMemberID) AS CountMembers,
					@DataRunID AS DataRunID,
					CCL.DataSetID,
					CCL.DataSourceID
			FROM	Claim.ClaimLines AS CCL
			WHERE	(CCL.DataSetID = @DataSetID) AND
					(
						(CCL.BeginDate <= @SeedDate) OR
						(CCL.EndDate <= @SeedDate)
					)
			GROUP BY MONTH(ISNULL(CCL.EndDate, CCL.BeginDate)),
					CCL.ClaimSrcTypeID,
					CCL.ClaimTypeID,
					Year(ISNULL(CCL.EndDate, CCL.BeginDate)),
					CCL.DataSetID,
					CCL.DataSourceID
			ORDER BY DataSourceID,
					ClaimTypeID,
					ClaimSrcTypeID,
					ClaimYear,
					ClaimMonth;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			--2) Purges existing claim code summary data, if any, and copies new summary data...
			DELETE FROM Result.ClaimCodeSummary WHERE (DataRunID = @DataRunID);

			IF NOT EXISTS (SELECT TOP 1 1 FROM Result.ClaimCodeSummary)
				TRUNCATE TABLE Result.ClaimCodeSummary;
				
			INSERT INTO Result.ClaimCodeSummary
					(ClaimMonth,
					 ClaimSrcTypeID,
					 ClaimTypeID,
					 ClaimYear,
					 CodeTypeID,
					 CountClaimLines,
					 CountCodes,
					 CountMembers,
					 DataRunID,
					 DataSetID,
					 DataSourceID)
			SELECT	MONTH(ISNULL(CCL.EndDate, CCL.BeginDate)) AS ClaimMonth,
					CCL.ClaimSrcTypeID,
					CCL.ClaimTypeID,
					YEAR(ISNULL(CCL.EndDate, CCL.BeginDate)) AS ClaimYear,
					CCC.CodeTypeID,
					COUNT(DISTINCT CCC.DSClaimLineID) AS CountClaimLines,
					COUNT(DISTINCT CCC.DSClaimCodeID) AS CountCodes,
					COUNT(DISTINCT CCC.DSMemberID) AS CountMembers,
					@DataRunID AS DataRunID,
					@DataSetID AS DataSetID,
					CCL.DataSourceID
			FROM	Claim.ClaimLines AS CCL
					INNER JOIN Claim.ClaimCodes AS CCC
							ON CCC.DSClaimLineID = CCL.DSClaimLineID
			WHERE	(CCL.DataSetID = @DataSetID) AND
					(
						(CCL.BeginDate <= @SeedDate) OR
						(CCL.EndDate <= @SeedDate)
					)
			GROUP BY MONTH(ISNULL(CCL.EndDate, CCL.BeginDate)),
					YEAR(ISNULL(CCL.EndDate, CCL.BeginDate)),
					CCL.ClaimSrcTypeID,
					CCL.ClaimTypeID,
					CCC.CodeTypeID,
					CCL.DataSourceID
			ORDER BY DataSourceID,
					ClaimTypeID,
					ClaimSrcTypeID,
					ClaimYear,
					ClaimMonth,
					CodeTypeID;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--Returns ANSI_WARNINGS back to "ON", if it was originally "ON"...
			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS ON;
						
			SET @LogDescr = 'Summarizing claims completed successfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry		@BeginTime = @LogBeginTime,
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
			SET @LogDescr = 'Summarizing claims failed!';
			
			EXEC @Result = Log.RecordEntry		@BeginTime = @LogBeginTime,
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
		DECLARE @ErrMessage nvarchar(MAX);
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
GRANT VIEW DEFINITION ON  [Result].[SummarizeClaims] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[SummarizeClaims] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[SummarizeClaims] TO [Processor]
GO
