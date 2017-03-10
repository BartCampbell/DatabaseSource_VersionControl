SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/3/2011
-- Description:	Summarizes the results from the member month detail.
-- =============================================
CREATE PROCEDURE [Result].[SummarizeMemberMonthDetail]
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
		SET @LogObjectName = 'SummarizeMemberMonthDetail'; 
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
				
			--------------------------------
			
			DELETE FROM Result.MemberMonthSummary WHERE (DataRunID = @DataRunID);

			IF NOT EXISTS (SELECT TOP 1 1 FROM Result.MemberMonthSummary)
				TRUNCATE TABLE Result.MemberMonthSummary;

			SELECT	MIN(Age) AS Age, 
					RMMD.BenefitID,
					RMMD.DataRunID,
					RMMD.DataSetID,
					RMMD.DSMemberID,
					RMMD.EnrollGroupID,
					RMMD.Gender,
					RMMD.PayerID,
					RMMD.PopulationID,
					RMMD.ProductLineID
			INTO	#MemberAges
			FROM	Result.MemberMonthDetail_Classic AS RMMD
			GROUP BY RMMD.BenefitID,
					RMMD.DataRunID,
					RMMD.DataSetID,
					RMMD.DSMemberID,
					RMMD.EnrollGroupID,
					RMMD.Gender,
					RMMD.PayerID,
					RMMD.PopulationID,
					RMMD.ProductLineID
					

			CREATE UNIQUE CLUSTERED INDEX IX_#MemberAges ON #MemberAges (DSMemberID, DataRunID, BenefitID, PopulationID, 
																			PayerID, ProductLineID, EnrollGroupID, Age);
			INSERT INTO Result.MemberMonthSummary
					(Age,
					BenefitID,
					CountMembers,
					CountMonths,
					DataRunID,
					DataSetID,
					EnrollGroupID,
					Gender,
					PayerID,
					PopulationID,
					ProductLineID)
			SELECT	RMMD.Age,
					RMMD.BenefitID,
					COUNT(DISTINCT t.DSMemberID) AS CountMembers,
					SUM(RMMD.CountMonths) AS CountMonths,
					RMMD.DataRunID,
					RMMD.DataSetID,
					RMMD.EnrollGroupID,
					RMMD.Gender,
					RMMD.PayerID,
					RMMD.PopulationID,
					RMMD.ProductLineID
			FROM	Result.MemberMonthDetail_Classic AS RMMD
					LEFT OUTER JOIN #MemberAges AS t
							ON RMMD.Age = t.Age AND		
								RMMD.BenefitID = t.BenefitID AND
								RMMD.DataRunID = t.DataRunID AND
								RMMD.DataSetID = t.DataSetID AND
								RMMD.DSMemberID = t.DSMemberID AND
								RMMD.EnrollGroupID = t.EnrollGroupID AND
								RMMD.Gender = t.Gender AND
								RMMD.PayerID = t.PayerID AND
								RMMD.PopulationID = t.PopulationID AND
								RMMD.ProductLineID = t.ProductLineID
			WHERE	(RMMD.DataRunID = @DataRunID)
			GROUP BY RMMD.Age,
					RMMD.BenefitID,
					RMMD.DataRunID,
					RMMD.DataSetID,
					RMMD.EnrollGroupID,
					RMMD.Gender,
					RMMD.PayerID,
					RMMD.PopulationID,
					RMMD.ProductLineID
			ORDER BY BenefitID, PopulationID, 
					PayerID, ProductLineID, EnrollGroupID, Age, Gender

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			
			--Returns ANSI_WARNINGS back to "ON", if it was originally "ON"...
			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS ON;
						
			SET @LogDescr = 'Summarizing member month detail completed successfully.'; 
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
			SET @LogDescr = 'Summarizing member month detail failed!';
			
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
GRANT VIEW DEFINITION ON  [Result].[SummarizeMemberMonthDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[SummarizeMemberMonthDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[SummarizeMemberMonthDetail] TO [Processor]
GO
