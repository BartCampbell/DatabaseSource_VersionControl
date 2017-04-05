SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/6/2016
-- Description:	Calculates the detailed results of the EDU measure.
-- =============================================
CREATE PROCEDURE [Ncqa].[EDU_CalculateMeasureDetail]
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
		SET @LogObjectName = 'EDU_CalculateMeasureDetail'; 
		SET @LogObjectSchema = 'Ncqa'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
			DECLARE @MetricEDU int;
			DECLARE @MetricEDUQTY int;

			SELECT	@MetricEDU = MX.MetricID
			FROM	Measure.Metrics AS MX
					INNER JOIN Measure.Measures AS MM
							ON MM.MeasureID = MX.MeasureID
			WHERE	MM.IsEnabled = 1 AND
					MM.MeasureSetID = @MeasureSetID AND
					MX.Abbrev = 'EDU' AND
					MX.IsEnabled = 1;

			SELECT	@MetricEDUQTY = MX.MetricID
			FROM	Measure.Metrics AS MX
					INNER JOIN Measure.Measures AS MM
							ON MM.MeasureID = MX.MeasureID
			WHERE	MM.IsEnabled = 1 AND
					MM.MeasureSetID = @MeasureSetID AND
					MX.Abbrev = 'EDUQTY' AND
					MX.IsEnabled = 1;

			--IF OBJECT_ID('tempdb..#EDU_Qty') IS NOT NULL
			--	DROP TABLE #EDU_Qty;

			SELECT	RMD.DSMemberID, SUM(RMD.Qty) AS Qty
			INTO	#EDU_Qty
			FROM	Result.MeasureDetail AS RMD
			WHERE	(RMD.BatchID = @BatchID) AND
					(RMD.DataRunID = @DataRunID) AND
					(RMD.DataSetID = @DataSetID) AND
					(RMD.MetricID = @MetricEDUQTY)
			GROUP BY RMD.DSMemberID;

			CREATE UNIQUE CLUSTERED INDEX IX_#EDU_Qty ON #EDU_Qty (DSMemberID);

			--IF OBJECT_ID('tempdb..#EDU_Population') IS NOT NULL
			--	DROP TABLE #EDU_Population;
			DELETE FROM Result.MeasureDetail_PPV_PUCV WHERE BatchID = @BatchID AND DataRunID = @DataRunID AND DataSetID = @DataSetID AND MetricID = @MetricEDU;

			IF NOT EXISTS(SELECT TOP 1 1 FROM Result.MeasureDetail_PPV_PUCV)
				TRUNCATE TABLE Result.MeasureDetail_PPV_PUCV;

			INSERT INTO Result.MeasureDetail_PPV_PUCV
					(BatchID,
					DataRunID,
					DataSetID,
					DSEntityID,
					DSMemberID,
					ExpectedQty,
					MetricID,
					Ppv,
					PpvBaseWeight,
					PpvDemoWeight,
					PpvHccWeight,
					PpvTotalWeight,
					Pucv,
					PucvBaseWeight,
					PucvDemoWeight,
					PucvHccWeight,
					PucvTotalWeight,
					Qty,
					SourceRowGuid,
					SourceRowID)
			SELECT	RMD.BatchID,
					RMD.DataRunID,
					RMD.DataSetID,
					RMD.DSEntityID,
					RMD.DSMemberID,
					CONVERT(decimal(24, 18), ROUND((EXP(HCC4.TotalWeight)) / (1 + EXP(HCC4.TotalWeight)) * HCC5.TotalWeight, 4)) AS ExpectedQty,
					RMD.MetricID,
					CONVERT(decimal(24, 18), ROUND((EXP(HCC4.TotalWeight)) / (1 + EXP(HCC4.TotalWeight)), 4)) AS Ppv,
					HCC4.BaseWeight AS PpvBaseWeight,
					HCC4.DemoWeight AS PpvDemoWeight,
					HCC4.HClinCondWeight AS PpvHccWeight,
					HCC4.TotalWeight AS PpvTotalWeight,
					HCC5.TotalWeight AS Pucv,
					HCC5.BaseWeight AS PucvBaseWeight,
					HCC5.DemoWeight AS PucvDemoWeight,
					HCC5.HClinCondWeight AS PucvHccWeight,
					HCC5.TotalWeight AS PucvTotalWeight,
					ISNULL(Qty.Qty, 0) AS Qty,
					RMD.ResultRowGuid AS SourceRowGuid,
					RMD.ResultRowID AS SourceRowID
			FROM	Result.MeasureDetail AS RMD
					LEFT OUTER JOIN #EDU_Qty AS Qty
							ON Qty.DSMemberID = RMD.DSMemberID
					LEFT OUTER JOIN Result.RiskHCCDetail AS HCC4
							ON HCC4.SourceRowID = RMD.ResultRowID AND
								HCC4.DSEntityID = RMD.DSEntityID AND
								HCC4.DSMemberID = RMD.DSMemberID AND
								HCC4.EvalTypeID = 4 AND
								HCC4.MetricID = RMD.MetricID
					LEFT OUTER JOIN Result.RiskHCCDetail AS HCC5
							ON HCC5.SourceRowID = RMD.ResultRowID AND
								HCC5.DSEntityID = RMD.DSEntityID AND
								HCC5.DSMemberID = RMD.DSMemberID AND
								HCC5.EvalTypeID = 5 AND
								HCC5.MetricID = RMD.MetricID
			WHERE	(RMD.IsDenominator = 1) AND
					(RMD.BatchID = @BatchID) AND
					(RMD.DataRunID = @DataRunID) AND
					(RMD.DataSetID = @DataSetID) AND
					(RMD.MetricID = @MetricEDU)
			ORDER BY RMD.ResultRowID;

			SET @CountRecords = ISNULL(@CountRecords, 0);

			UPDATE	RMD
			SET		Qty = EDU.Qty,
					Qty2 = ROUND(EDU.ExpectedQty, 0)
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN Result.MeasureDetail_PPV_PUCV AS EDU
							ON EDU.SourceRowGuid = RMD.ResultRowGuid AND
								EDU.SourceRowID = RMD.ResultRowID AND
								EDU.MetricID = RMD.MetricID
			WHERE	(RMD.BatchID = @BatchID) AND
					(RMD.DataRunID = @DataRunID) AND
					(RMD.DataSetID = @DataSetID) AND
					(RMD.MetricID = @MetricEDU);						

			SET @LogDescr = ' - Calculating EDU measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' succeeded.'; 
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
			SET @LogDescr = ' - Calculating EDU measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' failed!'; 
			
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
GRANT EXECUTE ON  [Ncqa].[EDU_CalculateMeasureDetail] TO [Processor]
GO
