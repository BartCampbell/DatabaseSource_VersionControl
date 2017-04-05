SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/12/2011
-- Description: Ranks entity options.
-- =============================================
CREATE PROCEDURE [Measure].[RankEntityOptions]
(
	@DataRunID int
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
	
	DECLARE @DataSetID int;
	DECLARE @MeasureSetID int;
	
	DECLARE @Result int;
	
		BEGIN TRY;
			
		SELECT	@DataSetID = DR.DataSetID,
				@MeasureSetID = DR.MeasureSetID 
		FROM	Batch.DataRuns AS DR
		WHERE	(DR.DataRunID = @DataRunID);
			
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'RankEntityOptions'; 
		SET @LogObjectSchema = 'Measure'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;
				
			DECLARE @CountRecords int;

			WITH Entities AS
			(
				SELECT	EntityID
				FROM	Measure.Entities AS E
				--WHERE	(E.MeasureSetID = @MeasureSetID)
			),
			CriteriaRanks AS
			(
				SELECT	EntityCritID,
						ROW_NUMBER() OVER (PARTITION BY MEC.EntityID, MEC.OptionNbr
											ORDER BY	MEC.IsEnabled DESC, MEC.IsInit DESC, IsForIndex DESC, Allow DESC, 
														DateComparerID, DateComparerInfo, EntityCritID) AS RankOrder
				FROM	Measure.EntityCriteria AS MEC		
				WHERE	MEC.EntityID IN (SELECT EntityID FROM Entities)
			)
			UPDATE	MEC
			SET		RankOrder = t.RankOrder
			FROM	Measure.EntityCriteria AS MEC
					INNER JOIN CriteriaRanks AS t
							ON MEC.EntityCritID = t.EntityCritID;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			--TRUNCATE TABLE Temp.EventKey;
			DELETE FROM Internal.EventKey WHERE (SpId = @@SPID) OR (DataRunID = @DataRunID);
			
			IF NOT EXISTS(SELECT TOP 1 1 FROM Internal.EventKey)
				TRUNCATE TABLE Internal.EventKey;		

			SET @LogDescr = 'Ranking of entity options completed succcessfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
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
			SET @LogDescr = 'Ranking of entity options failed!'; 
			
			EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
												@CountRecords = -1, 
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
GRANT EXECUTE ON  [Measure].[RankEntityOptions] TO [Processor]
GO
