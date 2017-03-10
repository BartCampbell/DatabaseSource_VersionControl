SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/17/2015
-- Description:	Calculates the detailed results of the PDC measure.
-- =============================================
CREATE PROCEDURE [Ncqa].[PDC_CalculateMeasureDetail]
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
		SET @LogObjectName = 'PDC_CalculateMeasureDetail'; 
		SET @LogObjectSchema = 'Ncqa'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
		
			DECLARE @PDCMeasureID int;
			SELECT @PDCMeasureID = MeasureID FROM Measure.Measures WHERE MeasureSetID = @MeasureSetID AND Abbrev = 'PDC' AND IsEnabled = 1;

			DECLARE @BitBenefitDrug bigint;
			SELECT @BitBenefitDrug = BitValue FROM Product.Benefits WHERE Abbrev = 'Drug';

			DECLARE @BitProductLinesM bigint;
			SELECT @BitProductLinesM = BitValue FROM Product.ProductLines WHERE Abbrev = 'M';

			IF @PDCMeasureID IS NOT NULL
				BEGIN;
					SELECT	*
					INTO	#PDCResults
					FROM	Result.MeasureDetail AS RMD
					WHERE	RMD.BatchID = @BatchID AND
							RMD.DataRunID = @DataRunID AND
							RMD.DataSetID = @DataSetID AND
							RMD.ResultTypeID = 1 AND
							RMD.MeasureID = @PDCMeasureID AND
							RMD.IsDenominator = 1;

					CREATE UNIQUE CLUSTERED INDEX IX_#PDCResults ON #PDCResults (ResultRowID);
					CREATE NONCLUSTERED INDEX IX_#PDCResults2 ON #PDCResults (DSEntityID, BatchID);

					SELECT	PE.*, t.ResultRowID
					INTO	#PDCEntities
					FROM	Proxy.Entities AS PE
							INNER JOIN #PDCResults AS t
									ON t.DSEntityID = PE.DSEntityID AND
										t.BatchID = PE.BatchID AND
										t.DataRunID = PE.DataRunID AND
										t.DataSetID = PE.DataSetID;
					
					CREATE UNIQUE CLUSTERED INDEX IX_#PDCEntities ON #PDCEntities (ResultRowID);
					CREATE NONCLUSTERED INDEX IX_#PDCEntities2 ON #PDCEntities (DSEntityID, BatchID);

					SELECT DISTINCT
							Member.GetAgeAsOf(PM.DOB, PE.LastSegEndDate) AS Age,
							Member.GetAgeInMonths(PM.DOB, PE.LastSegEndDate) AS AgeMonths,
							PE.DSMemberID,
							PNK.EnrollGroupID,
							CONVERT(bit, CASE WHEN ReEnroll.EnrollItemID IS NOT NULL THEN 1 ELSE 0 END) AS IsReEnrolled,
							PNK.PayerID,	
							PNK.PopulationID,				
							PE.ResultRowID
					INTO	#PDCEnrollment
					FROM	Proxy.Enrollment AS PN
							INNER JOIN Proxy.Members AS PM
									ON PM.BatchID = PN.BatchID AND
										PM.DataRunID = PN.DataRunID AND
										PM.DataSetID = PN.DataSetID AND
										PM.DSMemberID = PN.DSMemberID
							INNER JOIN #PDCEntities AS PE
									ON PE.BatchID = PN.BatchID AND
										PE.DataRunID = PN.DataRunID AND
										PE.DataSetID = PN.DataSetID AND
										PE.DSMemberID = PN.DSMemberID AND
										PE.LastSegEndDate BETWEEN PN.BeginDate AND ISNULL(PN.EndDate, @EndInitSeedDate)
							INNER JOIN Proxy.EnrollmentKey AS PNK
									ON PNK.BatchID = PN.BatchID AND
										PNK.DataRunID = PN.DataRunID AND
										PNK.DataSetID = PN.DataSetID AND
										PNK.EnrollGroupID = PN.EnrollGroupID
							OUTER APPLY (
											SELECT TOP 1
													tPN.EnrollItemID
											FROM	Proxy.Enrollment AS tPN
											WHERE	tPN.BatchID = PN.BatchID AND
													tPN.DataRunID = PN.DataRunID AND
													tPN.DataSetID = PN.DataSetID AND
													tPN.DSMemberID = PN.DSMemberID AND
													(
														(tPN.BeginDate BETWEEN DATEADD(dd, 2, PE.LastSegEndDate) AND @EndInitSeedDate) OR
														(
															(tPN.BitProductLines & @BitProductLinesM = 0) AND
															(tPN.BeginDate BETWEEN DATEADD(dd, 1, PE.LastSegEndDate) AND @EndInitSeedDate)
														)
													) AND
													tPN.BitBenefits & @BitBenefitDrug > 0

										) AS ReEnroll
					WHERE	PN.BitProductLines & @BitProductLinesM > 0;

					CREATE UNIQUE CLUSTERED INDEX IX_#PDCEnrollment ON #PDCEnrollment (ResultRowID, PayerID);

					UPDATE	RMD
					SET		Age = ISNULL(N.Age, RMD.Age),
							AgeMonths = ISNULL(N.AgeMonths, RMD.AgeMonths),
							EnrollGroupID = ISNULL(N.EnrollGroupID, RMD.EnrollGroupID),
							IsDenominator = CASE WHEN N.ResultRowID IS NOT NULL AND N.Age >= 18 AND IsReEnrolled = 0 THEN 1 ELSE 0 END,
							IsIndicator = CASE WHEN N.ResultRowID IS NOT NULL AND N.Age >= 18 AND IsReEnrolled = 0 THEN 0 ELSE 1 END,
							PayerID = ISNULL(N.PayerID, RMD.PayerID),
							PopulationID = ISNULL(N.PopulationID, RMD.PopulationID)
					FROM	Result.MeasureDetail AS RMD
							LEFT OUTER JOIN #PDCEnrollment AS N
									ON N.ResultRowID = RMD.ResultRowID
					WHERE	RMD.MeasureID = @PDCMeasureID AND
							RMD.BatchID = @BatchID AND
							RMD.DataRunID = @DataRunID AND
							RMD.DataSetID = @DataSetID AND
							RMD.ResultTypeID = 1;

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

					DROP TABLE #PDCEntities;
					DROP TABLE #PDCEnrollment;
					DROP TABLE #PDCResults;
				END;
			
			SET @LogDescr = ' - Calculating PDC measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' succeeded.'; 
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
			SET @LogDescr = ' - Calculating PDC measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' failed!'; 
			
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
GRANT VIEW DEFINITION ON  [Ncqa].[PDC_CalculateMeasureDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[PDC_CalculateMeasureDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[PDC_CalculateMeasureDetail] TO [Processor]
GO
