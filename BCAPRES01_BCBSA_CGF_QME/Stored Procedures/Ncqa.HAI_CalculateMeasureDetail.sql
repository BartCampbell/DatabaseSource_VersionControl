SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/13/2017
-- Description:	Scores the HAI HEDIS measure.
-- =============================================
CREATE PROCEDURE [Ncqa].[HAI_CalculateMeasureDetail]
(
	@DataRunID int,
	@OutputNcqaScoreKey bit = 0
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

	DECLARE @BatchID int;
	DECLARE @DataSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'HAI_CalculateMeasureDetail'; 
		SET @LogObjectSchema = 'Ncqa'; 
		
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
			
			DECLARE @HAI_MeasureID int;
			DECLARE @HAI_MetricID int;
			DECLARE @HAI1_MetricID int;
			DECLARE @HAI2_MetricID int;
			DECLARE @HAI5_MetricID int;
			DECLARE @HAI6_MetricID int;

			SELECT	@DataSetID = BDR.DataSetID,
					@HAI_MeasureID = MM.MeasureID,
					@MeasureSetID = BDR.MeasureSetID 
			FROM	Batch.DataRuns AS BDR WITH(NOLOCK)
					INNER JOIN Measure.Measures AS MM
							ON MM.MeasureSetID = BDR.MeasureSetID AND
								MM.Abbrev = 'HAI' AND
								MM.IsEnabled = 1
			WHERE	(BDR.DataRunID = @DataRunID);

			SELECT	@HAI_MetricID = MetricID FROM Measure.Metrics WHERE MeasureID = @HAI_MeasureID AND IsEnabled = 1 AND Abbrev = 'HAI';
			SELECT	@HAI1_MetricID = MetricID FROM Measure.Metrics WHERE MeasureID = @HAI_MeasureID AND IsEnabled = 1 AND Abbrev = 'HAI1';
			SELECT	@HAI2_MetricID = MetricID FROM Measure.Metrics WHERE MeasureID = @HAI_MeasureID AND IsEnabled = 1 AND Abbrev = 'HAI2';
			SELECT	@HAI5_MetricID = MetricID FROM Measure.Metrics WHERE MeasureID = @HAI_MeasureID AND IsEnabled = 1 AND Abbrev = 'HAI5';
			SELECT	@HAI6_MetricID = MetricID FROM Measure.Metrics WHERE MeasureID = @HAI_MeasureID AND IsEnabled = 1 AND Abbrev = 'HAI6';

			WITH NcqaPayerBase(NcqaPayer, ProductLine, ProductType) AS
			(
				SELECT	'CEP', 'C', 'EPO'
				UNION
				SELECT	'HMO', 'C', 'HMO'
				UNION
				SELECT	'POS', 'C', 'POS'
				UNION
				SELECT	'PPO', 'C', 'PPO'
				UNION
				SELECT	'MCR', 'R', 'HMO'
				UNION
				SELECT	'MP', 'R', 'PPO'
				UNION
				SELECT	'MCS', 'R', 'POS'
				UNION	
				SELECT	'MCD', 'D', 'HMO'
			),
			NcqaPayers AS 
			(
				SELECT	t.NcqaPayer,
						PPL.ProductLineID,
						PPT.ProductTypeID
				FROM	NcqaPayerBase AS t
						INNER JOIN Product.ProductTypes AS PPT
								ON PPT.Abbrev = t.ProductType
						INNER JOIN Product.ProductLines AS PPL
								ON PPL.Abbrev = t.ProductLine
			)
			SELECT	RMD.BatchID,
					RMD.BeginDate,
					RMD.BitProductLines,
					CASE WHEN RMD.BitProductLines & 6 = 6 THEN 2 ELSE RMD.BitProductLines END AS ConvertBitProductLines,
					MM.CustomerMemberID,
					RMD.DataRunID,
					RMD.DataSetID,
					RMD.DSEntityID,
					RMD.DSMemberID,
					RMD.DSProviderID,
					RMD.EndDate,
					RMD.EnrollGroupID,
					MM.IhdsMemberID,
					-- BORROWED from "EOC Scorekey" script ------------------------------------------
					CASE  
						WHEN PPL.Abbrev IN ('Q', 'S') OR PP.ProductTypeID = 3
						THEN PP.Abbrev
						WHEN PPL.Abbrev = 'D'
						THEN 'MCD'
						WHEN PP.ProductLineID <> PPL.ProductLineID AND PPL.Abbrev = 'R'
						THEN 'MCR'
						ELSE PP.Abbrev --Added to accommodate PayerID = 0 (Non-Ncqa Payers)
						END AS NcqaPayer,
					---------------------------------------------------------------------------------
					RMD.PayerID,
					RMD.PopulationID,
					PPL.ProductLineID,
					PP.ProductTypeID,
					RMD.ResultRowID
			INTO	#HAI_Discharges
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN Member.Members AS MM
							ON MM.DataSetID = RMD.DataSetID AND
								MM.DSMemberID = RMD.DSMemberID
					INNER JOIN Product.ProductLines AS PPL
							ON PPL.BitValue & RMD.BitProductLines > 0
					INNER JOIN Product.Payers AS PP
							ON PP.PayerID = RMD.PayerID
					LEFT OUTER JOIN NcqaPayers AS NP
							ON NP.ProductLineID = PPL.ProductLineID AND
								NP.ProductTypeID = PP.ProductTypeID
			WHERE	(RMD.DataRunID = @DataRunID) AND
					(RMD.DataSetID = @DataSetID) AND
					(RMD.IsDenominator = 1) AND
					(RMD.MeasureID = @HAI_MeasureID) AND
					(RMD.MetricID = @HAI_MetricID);

			CREATE UNIQUE CLUSTERED INDEX IX_#HAI_Discharges ON #HAI_Discharges (DSProviderID, ProductLineID, ResultRowID);

			SELECT TOP 10000
					PP.BitSpecialties,
					P.CustomerProviderID,
					PP.DataSetID,
					PP.DataSourceID,
					PP.DSProviderID,
					HAIH.HospID,
					HAIH.HospitalID,
					PP.IhdsProviderID,
					dbo.ConvertBitFromYN(P.Contracted) AS IsContracted,
					P.MedicareID
			INTO	#HAI_Providers
			FROM	dbo.Provider AS P
					INNER JOIN Provider.Providers AS PP
							ON PP.ProviderID = P.ProviderID
					LEFT OUTER JOIN Ncqa.HAI_Hospitals AS HAIH
							ON HAIH.HospitalID = P.MedicareID
			WHERE	(PP.DSProviderID IN (SELECT DISTINCT PP.DSProviderID FROM #HAI_Discharges)) AND
					(PP.DataSetID = @DataSetID);

			CREATE UNIQUE CLUSTERED INDEX IX_#HAI_Providers ON #HAI_Providers (DSProviderID);

			--SELECT	P.CustomerProviderID,
			--		P.HospID,
			--		P.HospitalID, 
			--		P.IhdsProviderID,
			--		HAIS.Metric,
			--		MX.MetricID,
			--		HAIS.SIRClass,
			--		HAIS.SIRScore,
			--		D.*
			--INTO	#HAI_DischargesByMetric
			--FROM	#HAI_Discharges AS D
			--		INNER JOIN #HAI_Providers AS P
			--				ON P.DSProviderID = D.DSProviderID
			--		INNER JOIN Measure.Metrics AS MX
			--				ON MX.MeasureID = @HAI_MeasureID AND	
			--					MX.MeasureID <> @HAI_MetricID
			--		LEFT OUTER JOIN Ncqa.HAI_HospitalSIRs AS HAIS
			--				ON HAIS.HospitalID = P.HospitalID AND
			--					HAIS.Metric = MX.Abbrev AND
			--					HAIS.MeasureSetID = @MeasureSetID
			--WHERE	(MX.IsEnabled = 1) AND
			--		(P.IsContracted = 1);

			--CREATE UNIQUE CLUSTERED INDEX IX_#HAI_DischargesByMetric ON #HAI_DischargesByMetric (DSProviderID, ProductLineID, MetricID, ResultRowID);


			WITH HAI_SIRClasses AS
			(
				SELECT	*
				FROM	(
							SELECT	HAIH.HospID, HAIS.HospitalID, HAIS.Metric, HAIS.SIRClass
							FROM	Ncqa.HAI_Hospitals AS HAIH
									INNER JOIN Ncqa.HAI_HospitalSIRs AS HAIS
											ON HAIS.HospitalID = HAIH.HospitalID
						) AS tDM
						PIVOT
						(
							MAX(SIRClass) FOR Metric IN ([HAI1], [HAI2], [HAI5], [HAI6])
						) AS DM
			),
			HAI_SIRScores AS 
			(
				SELECT	*
				FROM	(
							SELECT	HAIH.HospID, HAIS.HospitalID, HAIS.Metric, CONVERT(decimal(12, 6), HAIS.SIRScore) AS SIRScore
							FROM	Ncqa.HAI_Hospitals AS HAIH
									INNER JOIN Ncqa.HAI_HospitalSIRs AS HAIS
											ON HAIS.HospitalID = HAIH.HospitalID
						) AS tDM
						PIVOT
						(
							MAX(SIRScore) FOR Metric IN ([HAI1], [HAI2], [HAI5], [HAI6])
						) AS DM
			)
			SELECT	C.HospID,
					C.HospitalID,
					C.HAI1 AS HAI1_SIRClass,
					CASE WHEN ISNULL(C.HAI1, 'U') <> 'U' THEN ISNULL(S.HAI1, 0) END AS HAI1_SIRScore,
					C.HAI2 AS HAI2_SIRClass,
					CASE WHEN ISNULL(C.HAI2, 'U') <> 'U' THEN ISNULL(S.HAI2, 0) END AS HAI2_SIRScore,
					C.HAI5 AS HAI5_SIRClass,
					CASE WHEN ISNULL(C.HAI5, 'U') <> 'U' THEN ISNULL(S.HAI5, 0) END AS HAI5_SIRScore,
					C.HAI6 AS HAI6_SIRClass,
					CASE WHEN ISNULL(C.HAI6, 'U') <> 'U' THEN ISNULL(S.HAI6, 0) END AS HAI6_SIRScore
			INTO	#HAI_MetricSIRs
			FROM	HAI_SIRClasses AS C
					INNER JOIN HAI_SIRScores AS S
							ON S.HospID = C.HospID AND 
								S.HospitalID = C.HospitalID;

			SELECT	MIN(P.CustomerProviderID) AS CustomerProviderID,
					COUNT(DISTINCT D.ResultRowID) AS DischargeCount,
					CONVERT(decimal(12, 10), CONVERT(decimal(24, 10), COUNT(DISTINCT D.ResultRowID)) / CONVERT(decimal(24, 10), MAX(TTL.CountRecords))) AS DischargeWeight,
					D.DSProviderID,
					MIN(MS.HAI1_SIRClass) AS HAI1_SIRClass,
					MIN(MS.HAI1_SIRScore) AS HAI1_SIRScore,
					ROUND(CONVERT(decimal(12, 10), CONVERT(decimal(24, 10), COUNT(DISTINCT D.ResultRowID)) / CONVERT(decimal(24, 10), MAX(TTL.CountRecords))) * ISNULL(MIN(MS.HAI1_SIRScore), 0), 12) AS HAI1_SIRWeight,
					MIN(MS.HAI2_SIRClass) AS HAI2_SIRClass,
					MIN(MS.HAI2_SIRScore) AS HAI2_SIRScore,
					ROUND(CONVERT(decimal(12, 10), CONVERT(decimal(24, 10), COUNT(DISTINCT D.ResultRowID)) / CONVERT(decimal(24, 10), MAX(TTL.CountRecords))) * ISNULL(MIN(MS.HAI2_SIRScore), 0), 12) AS HAI2_SIRWeight,
					MIN(MS.HAI5_SIRClass) AS HAI5_SIRClass,
					MIN(MS.HAI5_SIRScore) AS HAI5_SIRScore,
					ROUND(CONVERT(decimal(12, 10), CONVERT(decimal(24, 10), COUNT(DISTINCT D.ResultRowID)) / CONVERT(decimal(24, 10), MAX(TTL.CountRecords))) * ISNULL(MIN(MS.HAI5_SIRScore), 0), 12) AS HAI5_SIRWeight,
					MIN(MS.HAI6_SIRClass) AS HAI6_SIRClass,
					MIN(MS.HAI6_SIRScore) AS HAI6_SIRScore,
					ROUND(CONVERT(decimal(12, 10), CONVERT(decimal(24, 10), COUNT(DISTINCT D.ResultRowID)) / CONVERT(decimal(24, 10), MAX(TTL.CountRecords))) * ISNULL(MIN(MS.HAI6_SIRScore), 0), 12) AS HAI6_SIRWeight,
					MIN(MS.HospID) AS HospID,
					MIN(MS.HospitalID) AS HospitalID,
					MIN(P.IhdsProviderID) AS IhdsProviderID,
					MIN(D.NcqaPayer) AS NcqaPayer,
					D.PopulationID,
					D.ProductLineID, 
					D.ProductTypeID
			INTO	#HAI_Results
			FROM	#HAI_Discharges AS D
					INNER JOIN #HAI_Providers AS P
							ON P.DSProviderID = D.DSProviderID
					LEFT OUTER JOIN #HAI_MetricSIRs AS MS
							ON MS.HospitalID = P.HospitalID
					OUTER APPLY (
							SELECT	COUNT(DISTINCT t.ResultRowID) AS CountRecords
							FROM	#HAI_Discharges AS t
							WHERE	t.PopulationID = D.PopulationID AND
									t.ProductLineID = D.ProductLineID AND
									t.ProductTypeID = D.ProductTypeID AND
									t.NcqaPayer = D.NcqaPayer
						) AS TTL
			WHERE	(P.IsContracted = 1)
			GROUP BY D.DSProviderID, D.PopulationID, D.ProductLineID, D.ProductTypeID, D.NcqaPayer
			ORDER BY HospitalID, NcqaPayer;

			DELETE FROM Result.MeasureDetail_HAI WHERE (DataRunID = @DataRunID) AND (DataSetID = @DataSetID);

			IF NOT EXISTS (SELECT TOP 1 1 FROM Result.MeasureDetail_HAI)
				TRUNCATE TABLE Result.MeasureDetail_HAI;

			INSERT INTO Result.MeasureDetail_HAI
			        (CustomerProviderID,
			        DataRunID,
			        DataSetID,
			        DischargeCount,
			        DischargeWeight,
			        DSProviderID,
			        HAI1_SIRClass,
			        HAI1_SIRScore,
			        HAI1_SIRWeight,
			        HAI2_SIRClass,
			        HAI2_SIRScore,
			        HAI2_SIRWeight,
			        HAI5_SIRClass,
			        HAI5_SIRScore,
			        HAI5_SIRWeight,
			        HAI6_SIRClass,
			        HAI6_SIRScore,
			        HAI6_SIRWeight,
			        HospID,
			        HospitalID,
			        IhdsProviderID,
			        NcqaPayer,
			        PopulationID,
			        ProductLineID,
			        ProductTypeID)
			SELECT	CustomerProviderID,
			        @DataRunID AS DataRunID,
			        @DataSetID AS DataSetID,
			        DischargeCount,
			        DischargeWeight,
			        DSProviderID,
			        HAI1_SIRClass,
			        HAI1_SIRScore,
			        HAI1_SIRWeight,
			        HAI2_SIRClass,
			        HAI2_SIRScore,
			        HAI2_SIRWeight,
			        HAI5_SIRClass,
			        HAI5_SIRScore,
			        HAI5_SIRWeight,
			        HAI6_SIRClass,
			        HAI6_SIRScore,
			        HAI6_SIRWeight,
			        HospID,
			        HospitalID,
			        IhdsProviderID,
			        NcqaPayer,
			        PopulationID,
			        ProductLineID,
			        ProductTypeID
			FROM	#HAI_Results
			ORDER BY HospID;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			IF @OutputNcqaScoreKey = 1
				SELECT	R.HospitalID AS HospID,
						R.NcqaPayer AS Payer,
						R.DischargeCount AS Discharges,
						CONVERT(decimal(18, 4), ROUND(R.DischargeWeight, 4)) AS DischargeWt,
						ISNULL(CONVERT(varchar(32), CONVERT(decimal(18, 3), R.HAI1_SIRScore)), 'U') AS CLABSISIR,
						R.HAI1_SIRClass AS CLABSIClas,
						ISNULL(CONVERT(varchar(32), CONVERT(decimal(18, 3), R.HAI2_SIRScore)), 'U') AS CAUTISIR,
						R.HAI2_SIRClass AS CAUTIClas,
						ISNULL(CONVERT(varchar(32), CONVERT(decimal(18, 3), R.HAI5_SIRScore)), 'U') AS MRSASIR,
						R.HAI5_SIRClass AS MRSAClas,
						ISNULL(CONVERT(varchar(32), CONVERT(decimal(18, 3), R.HAI6_SIRScore)), 'U') AS CDIFFSIR,
						R.HAI6_SIRClass AS CDIFFClas,
						CONVERT(decimal(18, 4), ROUND(R.HAI1_SIRWeight, 4)) AS CLABSIWt,
						CONVERT(decimal(18, 4), ROUND(R.HAI2_SIRWeight, 4)) AS CAUTIWt,
						CONVERT(decimal(18, 4), ROUND(R.HAI5_SIRWeight, 4)) AS MRSAWt,
						CONVERT(decimal(18, 4), ROUND(R.HAI6_SIRWeight, 4)) AS CDIFFWt
				FROM	#HAI_Results AS R
				ORDER BY HospID, Payer;
						
			SET @LogDescr = 'Calculating HAI measure results completed successfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = [Log].RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = @CountRecords,
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogEndTime, 
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
			SET @LogDescr = 'Calculating HAI measure results failed!';
			
			EXEC @Result = [Log].RecordEntry	@BatchID = @BatchID,
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
