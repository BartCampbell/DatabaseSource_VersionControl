SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/22/2013
-- Description:	Calculates the detailed results of the AMR measure.
-- =============================================
CREATE PROCEDURE [Ncqa].[AMR_CalculateMeasureDetail]
(
	@BatchID int = NULL,
	@CountRecords bigint = NULL OUTPUT
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
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'AMR_CalculateMeasureDetail'; 
		SET @LogObjectSchema = 'Ncqa'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
		
			DECLARE @MetricAMR int;
			DECLARE @MetricCIN int;
			DECLARE @MetricCOR int;
			DECLARE @MetricRIN int;

			SELECT @MetricAMR = MetricID FROM Measure.Metrics AS MX INNER JOIN Measure.Measures AS MM ON MX.MeasureID = MM.MeasureID WHERE MM.MeasureSetID = @MeasureSetID AND MX.Abbrev = 'AMR' AND MM.Abbrev = 'AMR';
			SELECT @MetricCIN = MetricID FROM Measure.Metrics AS MX INNER JOIN Measure.Measures AS MM ON MX.MeasureID = MM.MeasureID WHERE MM.MeasureSetID = @MeasureSetID AND MX.Abbrev = 'AMRCIN' AND MM.Abbrev = 'AMR';
			SELECT @MetricCOR = MetricID FROM Measure.Metrics AS MX INNER JOIN Measure.Measures AS MM ON MX.MeasureID = MM.MeasureID WHERE MM.MeasureSetID = @MeasureSetID AND MX.Abbrev = 'AMRCOR' AND MM.Abbrev = 'AMR';
			SELECT @MetricRIN = MetricID FROM Measure.Metrics AS MX INNER JOIN Measure.Measures AS MM ON MX.MeasureID = MM.MeasureID WHERE MM.MeasureSetID = @MeasureSetID AND MX.Abbrev = 'AMRRIN' AND MM.Abbrev = 'AMR';

			IF OBJECT_ID('tempdb..#AMRResults') IS NOT NULL
				DROP TABLE #AMRResults;

			SELECT	RMD.BatchID, 
					RMD.DataRunID, 
					RMD.DataSetID, 
					RMD.DSMemberID, 
					RMD.DSEntityID, 
					IDENTITY(bigint, 1, 1) AS ID,
					NEWID() AS ResultRowGuid,
					MAX(CASE WHEN RMD.MetricID = @MetricCIN THEN PE.Qty ELSE 0 END) AS QtyCIN,
					MAX(CASE WHEN RMD.MetricID = @MetricCOR THEN PE.Qty ELSE 0 END) AS QtyCOR,
					MAX(CASE WHEN RMD.MetricID = @MetricRIN THEN PE.Qty ELSE 0 END) AS QtyRIN,
					CONVERT(uniqueidentifier, MIN(CASE WHEN RMD.MetricID = @MetricAMR THEN CONVERT(varchar(36), RMD.ResultRowGuid) END)) AS SourceRowGuid, 
					MIN(CASE WHEN RMD.MetricID = @MetricAMR THEN RMD.ResultRowID END) AS SourceRowID
			INTO	#AMRResults
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN Internal.Entities AS PE
							ON RMD.BatchID = PE.BatchID AND
								RMD.DataRunID = PE.DataRunID AND
								RMD.DSMemberID = PE.DSMemberID AND
								(RMD.SourceDenominator = PE.DSEntityID AND RMD.MetricID = @MetricAMR OR
								RMD.SourceNumerator = PE.DSEntityID AND RMD.MetricID <> @MetricAMR)
			WHERE	(RMD.BatchID = @BatchID) AND
					(RMD.DataRunID = @DataRunID) AND
					(RMD.IsDenominator = 1) AND
					(RMD.MetricID IN (@MetricAMR, @MetricCIN, @MetricCOR, @MetricRIN))
			GROUP BY RMD.BatchID, RMD.DataRunID, RMD.DataSetID, RMD.DSMemberID, RMD.DSEntityID
			ORDER BY SourceRowID;

			CREATE UNIQUE CLUSTERED INDEX IX_#AMRResults ON #AMRResults (SourceRowID);

			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			IF @Ansi_Warnings = 0
				SET ANSI_WARNINGS ON;

			INSERT INTO Result.MeasureDetail_AMR
					(BatchID,
					DataRunID,
					DataSetID,
					DSEntityID,
					DSMemberID,
					QtyControl,
					QtyReliever,
					ResultRowGuid,
					SourceRowGuid,
					SourceRowID)
			SELECT	BatchID,
					DataRunID,
					DataSetID,
					DSEntityID,
					DSMemberID,
					QtyCIN + QtyCOR AS QtyControl,
					QtyRIN AS QtyReliever,
					ResultRowGuid,
					SourceRowGuid,
					SourceRowID
			FROM	#AMRResults
			ORDER BY SourceRowID;

			IF @Ansi_Warnings = 0
				SET ANSI_WARNINGS OFF;

			UPDATE	RMD
			SET		IsNumerator = 1,
					IsNumeratorAdmin = 1
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN Result.MeasureDetail_AMR AS AMR
							ON RMD.BatchID = AMR.BatchID AND
								RMD.DataRunID = AMR.DataRunID AND
								RMD.ResultRowID = AMR.SourceRowID
			WHERE	(AMR.BatchID = @BatchID) AND
					(AMR.DataRunID = @DataRunID) AND
					(RMD.MetricID = @MetricAMR) AND
					(AMR.PercentControl >= 0.5);
					
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			SET @LogDescr = ' - Calculating AMR measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' succeeded.'; 
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
			SET @LogDescr = ' - Calculating AMR measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' failed!'; 
			
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
GRANT VIEW DEFINITION ON  [Ncqa].[AMR_CalculateMeasureDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[AMR_CalculateMeasureDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[AMR_CalculateMeasureDetail] TO [Processor]
GO
