SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/6/2016
-- Description:	Calculates the HCCs for risk measures.
--				(*** NOTE: For risk calculations to work, please be sure to populate the PCR_HCC_Codes table via the "PCR Populate PCR_TableB" T-SQL script. ***)
-- =============================================
CREATE PROCEDURE [Risk].[CalculateHCCs]
(
	@BatchID int = NULL,
	@MetricID int = NULL,
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
		SET @LogObjectName = 'CalculateHCCs'; 
		SET @LogObjectSchema = 'Risk'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
						
			--CREATED FROM Ncqa.CalcMeasureDetail_PCR---------------------------------------------
			--1) Find and Replace for "#PCR_" with "#Risk_".
			--2) Implementation of replacement for #PCR_Base as #Risk_Base. 
			--3) Remove "(IsSurg = 0) AND " from population of #CPTs, #HCPCSs, and #RevCodes
			--4) Make adjustments to final table population
			--------------------------------------------------------------------------------------

			--Identify RRU measures for the current measure set...
			SELECT DISTINCT
					RCP.AllowPrimary,
					RCP.AllowSurg,
					RMTEM.AggregateID,
					RCP.BeginDays,
					RCP.BeginMonths,
					RMTEM.ClassPeriodID,
					RMTEM.DefaultValue,
					RMTEM.EvalTypeID, 
					MM.MeasureID,
					RMTEM.MetricID,
					RCP.EndDays,
					RCP.EndMonths,
					RCP.IsIESD
			INTO	#RiskMetrics
			FROM	Risk.MetricToEvalMapping AS RMTEM
					INNER JOIN Measure.Metrics AS MX
							ON MX.MetricID = RMTEM.MetricID
					INNER JOIN Measure.Measures AS MM
							ON MM.MeasureID = MX.MeasureID
					INNER JOIN Risk.ClassificationPeriods AS RCP
							ON RCP.ClassPeriodID = RMTEM.ClassPeriodID
			WHERE	(MM.IsEnabled = 1) AND
					(MM.MeasureSetID = @MeasureSetID) AND
					(MX.IsEnabled = 1) AND
					((@MetricID IS NULL) OR (RMTEM.MetricID = @MetricID));         

			CREATE UNIQUE CLUSTERED INDEX IX_#Risk_Measures ON #RiskMetrics (MetricID, EvalTypeID);

			--Identify base resultset
			SELECT	RM.AllowPrimary,
					RM.AllowSurg,
					RMD.Age,
					RM.AggregateID,
					DATEADD(dd, RM.BeginDays, DATEADD(mm, RM.BeginMonths, CASE WHEN RM.IsIESD = 1 THEN RMD.KeyDate ELSE @BeginInitSeedDate END)) AS BeginDate, 
					RMD.BitProductLines,
					RM.DefaultValue,
					RMD.DSEntityID, 
					RMD.DSMemberID, 
					DATEADD(dd, RM.EndDays, DATEADD(mm, RM.EndMonths, CASE WHEN RM.IsIESD = 1 THEN RMD.KeyDate ELSE @EndInitSeedDate END)) AS EndDate, 
					RMD.EnrollGroupID,
					RM.EvalTypeID,
					RMD.Gender,
					RMD.MeasureID,
					RMD.MetricID,
					RMD.ResultRowGuid AS ResultRowGuid,
					RMD.ResultRowID
			INTO	#Risk_Base          
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN #RiskMetrics AS RM
							ON RM.MetricID = RMD.MetricID                         
			WHERE	(RMD.BatchID = @BatchID) AND
					(RMD.DataRunID = @DataRunID) AND
					((RMD.IsDenominator = 1) OR (RMD.IsExclusion = 1));       


			IF EXISTS(SELECT TOP 1 1 FROM #Risk_Base)
				BEGIN;   

					CREATE UNIQUE CLUSTERED INDEX IX_#Risk_Base ON #Risk_Base (ResultRowID, EvalTypeID);
					CREATE UNIQUE NONCLUSTERED INDEX IX_#Risk_Base_DSEntityID ON #Risk_Base (DSEntityID, EvalTypeID) INCLUDE (Age, Gender);
					CREATE NONCLUSTERED INDEX IX_#Risk_Base_DSMemberID ON #Risk_Base (DSMemberID, EvalTypeID) INCLUDE (BeginDate, EndDate);

					--Identify the Comorbid Weight and Adjusted Probability of Readmission----------------
					DECLARE @CodeType1 tinyint; --CPT
					DECLARE @CodeTypeD tinyint; --ICD-9 Diagnosis Code
					DECLARE @CodeTypeH tinyint; --HCPCS
					DECLARE @CodeTypeI tinyint; --ICD-10 Diagnosis Code
					DECLARE @CodeTypeR tinyint; --UB-92 Revenue Code

					SELECT @CodeType1 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '1';
					SELECT @CodeTypeD = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'D';
					SELECT @CodeTypeH = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'H';
					SELECT @CodeTypeI = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'I';
					SELECT @CodeTypeR = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'R';

					CREATE TABLE #CPTs (Code varchar(16) NOT NULL, IsAcute bit NOT NULL, IsInpatient bit NOT NULL, IsSurg bit NOT NULL);
					CREATE TABLE #HCPCSs (Code varchar(16) NOT NULL, IsAcute bit NOT NULL, IsInpatient bit NOT NULL, IsSurg bit NOT NULL);
					CREATE TABLE #RevCodes (Code varchar(16) NOT NULL, IsAcute bit NOT NULL, IsInpatient bit NOT NULL, IsSurg bit NOT NULL);

					--HCC_Codes formerly PCR Table-B)
					INSERT INTO #CPTs (Code, IsAcute, IsInpatient, IsSurg) SELECT Code, IsAcute, IsInpatient, IsSurg FROM Ncqa.PCR_HCC_Codes WHERE (CodeTypeID = @CodeType1) AND (MeasureSetID = @MeasureSetID);
					INSERT INTO #HCPCSs (Code, IsAcute, IsInpatient, IsSurg) SELECT Code, IsAcute, IsInpatient, IsSurg FROM Ncqa.PCR_HCC_Codes WHERE (CodeTypeID = @CodeTypeH) AND (MeasureSetID = @MeasureSetID);
					INSERT INTO #RevCodes (Code, IsAcute, IsInpatient, IsSurg) SELECT Code, IsAcute, IsInpatient, IsSurg FROM Ncqa.PCR_HCC_Codes WHERE (CodeTypeID = @CodeTypeR) AND (MeasureSetID = @MeasureSetID);

					CREATE UNIQUE CLUSTERED INDEX IX_#CPTs ON #CPTs (Code);
					CREATE UNIQUE CLUSTERED INDEX IX_#HCPCSs ON #HCPCSs (Code);
					CREATE UNIQUE CLUSTERED INDEX IX_#RevCodes ON #RevCodes (Code);
            
					--Step #1, Identify the valid Comorbid Claims
					SELECT DISTINCT
							t.AllowPrimary,			
							CONVERT(bigint, NULL) AS DSClaimID,			--Not valid until IESD fully-implemented 
							t.EndDate, 
							IDENTITY(bigint, 1, 1) AS ID,
							t.MeasureID,
							TCL.CPT AS RefCPT,
							ISNULL(TCL.EndDate, TCL.BeginDate) AS RefDate, 
							TCL.DSClaimID AS RefDSClaimID, 
							TCL.DSClaimLineID AS RefDSClaimLineID, 
							TCL.HCPCS AS RefHCPCS,
							TCL.Rev AS RefRevCode,
							t.ResultRowID
					INTO	#Risk_Comorbid_Claims
					FROM	#Risk_Base AS t
							INNER JOIN Proxy.ClaimLines AS TCL
									ON t.DSMemberID = TCL.DSMemberID AND
										--TCL.IsPaid = 1 AND
										TCL.IsSupplemental = 0 AND
										((TCL.EndDate IS NULL AND TCL.BeginDate BETWEEN t.BeginDate AND t.EndDate) OR
										(TCL.EndDate IS NOT NULL AND TCL.EndDate BETWEEN t.BeginDate AND t.EndDate)) AND
										(
											(TCL.CPT IN (SELECT t1.Code FROM #CPTs AS t1 WHERE t.AllowSurg = 1 OR t1.IsSurg = 0)) OR 
											(TCL.HCPCS IN (SELECT t2.Code FROM #HCPCSs AS t2 WHERE t.AllowSurg = 1 OR t2.IsSurg = 0)) OR 
											(TCL.Rev IN (SELECT t3.Code FROM #RevCodes AS t3 WHERE t.AllowSurg = 1 OR t3.IsSurg = 0))
										);

					CREATE UNIQUE CLUSTERED INDEX IX_#Risk_Comorbid_Claims ON #Risk_Comorbid_Claims (RefDSClaimLineID, ID);

					--Step #2, Identify the valid diagnoses on the Comorbid Claims
					SELECT	PCR_CC.ClinCond, 
							PCR_CC.ClinCondID, 
							t.*, 
							TCC.DSClaimCodeID AS RefDSClaimCodeID,
							TCC.Code AS RefCode, 
							TCC.CodeID AS RefCodeID, 
							TCC.IsPrimary AS RefIsPrimary
					INTO	#Risk_Comorbid_Codes
					FROM	#Risk_Comorbid_Claims AS t
							INNER JOIN Proxy.ClaimCodes AS TCC
									ON t.RefDSClaimLineID = TCC.DSClaimLineID AND
										TCC.CodeTypeID IN(@CodeTypeD, @CodeTypeI) AND
										((t.AllowPrimary = 1) OR ((t.AllowPrimary = 0) AND (TCC.IsPrimary = 0)))
							INNER JOIN Ncqa.PCR_ClinicalConditions AS PCR_CC
									ON TCC.CodeID = PCR_CC.CodeID AND
										TCC.Code = PCR_CC.Code AND
										TCC.CodeTypeID = PCR_CC.CodeTypeID AND
										PCR_CC.MeasureSetID = @MeasureSetID AND
										PCR_CC.EvalTypeID = 2 
								
					CREATE UNIQUE CLUSTERED INDEX IX_#Risk_Comorbid_Codes ON #Risk_Comorbid_Codes (ClinCond, RefDSClaimCodeID, ID);

					--Step #3, Apply the "HCCs"
					SELECT  t.ClinCond, 
							COUNT(DISTINCT t.RefDSClaimCodeID) AS CountCodes, 
							MIN(t.RefDSClaimCodeID) AS DSClaimCodeID, 
							ISNULL(R.HClinCond, t.ClinCond) AS HClinCond, 
							ISNULL(R.RankGrpID, -1) AS RankGrpID, 
							ISNULL(R.RankOrder, 1) AS RankOrder,
							t.ResultRowID
					INTO	#Risk_HCC
					FROM	#Risk_Comorbid_Codes AS t
							LEFT OUTER JOIN Ncqa.PCR_Ranks AS R
									ON t.ClinCond = R.ClinCond AND
										R.MeasureSetID = @MeasureSetID
					GROUP BY t.ClinCond, 
							t.ResultRowID, 
							ISNULL(R.HClinCond, t.ClinCond), 
							ISNULL(R.RankGrpID, -1), 
							ISNULL(R.RankOrder, 1)
					ORDER BY ResultRowID, RankGrpID, RankOrder;

					CREATE UNIQUE CLUSTERED INDEX IX_#Risk_HCC ON #Risk_HCC (ResultRowID, RankGrpID, RankOrder, HClinCond);

					--Step #4, Determine the lowest rank for each "HCC-PCR"
					WITH BestRank AS
					(
						SELECT	t.ResultRowID, t.RankGrpID, MIN(RankOrder) AS RankOrder
						FROM	#Risk_HCC AS t
						GROUP BY t.ResultRowID, t.RankGrpID 
					)
					SELECT DISTINCT
							SUM(t.CountCodes) AS CountCodes, 
							MIN(t.DSClaimCodeID) AS DSClaimCodeID,
							t.HClinCond,
							t.ResultRowID
					INTO	#Risk_EntityHCC
					FROM	#Risk_HCC AS t
							INNER JOIN BestRank AS BR
									ON t.ResultRowID = BR.ResultRowID AND
										t.RankGrpID = BR.RankGrpID AND
										t.RankOrder = BR.RankOrder
					GROUP BY t.ResultRowID, t.HClinCond
					ORDER BY ResultRowID, HClinCond; 

					--Step #5, Identify Combos
					SELECT	COUNT(DISTINCT HClinCond) AS CountHClinCond, HCombo, OptionNbr
					INTO	#Combos
					FROM	Ncqa.PCR_HCC_Combinations 
					WHERE	MeasureSetID = @MeasureSetID
					GROUP BY HCombo, OptionNbr;

					CREATE UNIQUE CLUSTERED INDEX IX_#Combos ON #Combos (HCombo, OptionNbr);
			
					SELECT DISTINCT
							t.ResultRowID, 
							CBO.HCombo
					INTO	#Risk_HCC_Combos
					FROM	#Risk_EntityHCC AS t
							INNER JOIN Ncqa.PCR_HCC_Combinations AS CBO
									ON t.HClinCond = CBO.HClinCond
							INNER JOIN #Combos AS C
									ON CBO.HCombo = C.HCombo AND
										CBO.OptionNbr = C.OptionNbr
					WHERE	(CBO.MeasureSetID = @MeasureSetID)
					GROUP BY C.CountHClinCond, 
							t.ResultRowID, 
							CBO.OptionNbr, 
							CBO.HCombo
					HAVING (COUNT(DISTINCT t.HClinCond) >= C.CountHClinCond)
					ORDER BY ResultRowID, HCombo;
						
					CREATE UNIQUE CLUSTERED INDEX IX_#Risk_HCC_Combos ON #Risk_HCC_Combos(ResultRowID, HCombo);

					--Step #6, Delete Child Combos		
					SELECT	t2.*
					INTO	#DeleteCombos
					FROM	#Risk_HCC_Combos AS t1
							INNER JOIN #Risk_HCC_Combos AS t2
									ON t1.ResultRowID = t2.ResultRowID
							INNER JOIN Ncqa.PCR_HCC_CombinationHierarchy AS H
									ON t1.HCombo = H.ParentHCombo AND
										t2.HCombo = H.ChildHCombo AND
										H.MeasureSetID = @MeasureSetID;
								
					CREATE UNIQUE CLUSTERED INDEX IX_#DeleteCombos ON #DeleteCombos(ResultRowID, HCombo);
					
					DELETE	t
					FROM	#Risk_HCC_Combos AS t
							INNER JOIN #DeleteCombos AS d
									ON t.HCombo = d.HCombo AND
										t.ResultRowID  = d.ResultRowID;
								
					DROP TABLE #DeleteCombos;

					--Step #7, Add Valid Combos to Entity/HCC List
					INSERT INTO #Risk_EntityHCC 
							(ResultRowID, HClinCond)
					SELECT	ResultRowID, HCombo
					FROM	#Risk_HCC_Combos;
								
					CREATE UNIQUE CLUSTERED INDEX IX_#Risk_EntityHCC ON #Risk_EntityHCC (ResultRowID, HClinCond);

					--Step #8, Calculate Weights
					SELECT	B.Age,
							B.AggregateID,
							CAST(0 AS decimal(24, 18)) AS BaseWeight,
							B.BitProductLines,
							CAST(0 AS decimal(24, 18)) AS DemoWeight,
							B.DSEntityID, 
							B.DSMemberID,
							B.EvalTypeID,
							B.Gender,
							ROUND(CASE WHEN B.AggregateID = 1 
										THEN CONVERT(decimal(24, 18), SUM(ISNULL(CONVERT(decimal(9, 6), CCW.[Weight]), CONVERT(decimal(9, 6), B.DefaultValue))))
										WHEN B.AggregateID = 2
										THEN CONVERT(decimal(24, 18), EXP(SUM(LOG(ISNULL(NULLIF(ABS(CONVERT(decimal(9, 6), ISNULL(CCW.[Weight], B.DefaultValue))), 0), 1)))))
										ELSE CONVERT(decimal(24, 18), ISNULL(MIN(B.DefaultValue), 0))
										END, 14) AS HClinCondWeight,
							B.MeasureID,
							B.MetricID,
							B.ResultRowGuid, 
							B.ResultRowID,
							CAST(0 AS decimal(24, 18)) AS TotalWeight
					INTO	#Weights
					FROM	#Risk_Base AS B
							LEFT OUTER JOIN #Risk_EntityHCC AS EH
									ON B.ResultRowID = EH.ResultRowID
							LEFT OUTER JOIN Ncqa.PCR_ClinicalConditionWeights AS CCW
									ON EH.HClinCond = CCW.ClinCond AND
										CCW.MeasureSetID = @MeasureSetID AND
										CCW.EvalTypeID = B.EvalTypeID AND
										(CCW.BitProductLines & B.BitProductLines > 0 OR CCW.BitProductLines = 0) AND           
										B.Age BETWEEN CCW.FromAge AND CCW.ToAge
					GROUP BY B.Age, B.AggregateID, B.BitProductLines, B.DSEntityID, 
							B.DSMemberID, B.EvalTypeID, B.Gender, B.MeasureID, 
							B.MetricID, B.ResultRowGuid, B.ResultRowID
					ORDER BY B.ResultRowID, B.EvalTypeID;

					UPDATE	W
					SET		BaseWeight = PLW.BaseWeight
					FROM	#Weights AS W
							INNER JOIN NCQA.PCR_ProductLineWeights AS PLW
									ON W.BitProductLines & PLW.BitProductLines > 0 AND
										PLW.MeasureSetID = @MeasureSetID AND
										PLW.EvalTypeID = W.EvalTypeID AND
										W.Age BETWEEN PLW.FromAge AND PLW.ToAge;

					UPDATE	W
					SET		DemoWeight = DW.[Weight]
					FROM	#Weights AS W
							INNER JOIN NCQA.PCR_DemographicWeights AS DW
									ON W.Age BETWEEN DW.FromAge AND DW.ToAge AND
										W.Gender = DW.Gender AND
										DW.MeasureSetID = @MeasureSetID AND
										W.EvalTypeID = DW.EvalTypeID AND
										(DW.BitProductLines & W.BitProductLines > 0 OR DW.BitProductLines = 0) AND    
										W.Age BETWEEN DW.FromAge AND DW.ToAge;
			
					UPDATE	#Weights
					SET		TotalWeight = CASE WHEN AggregateID = 1 
												THEN ROUND(BaseWeight + DemoWeight + HClinCondWeight, 4)
												WHEN AggregateID = 2 
												THEN ROUND(BaseWeight * DemoWeight * HClinCondWeight, 4)
												ELSE 0
												END;
			

					--Step #9, Record the results in RRU-Specific Measure DEtail
					DELETE FROM Result.RiskHCCDetail WHERE BatchID = @BatchID;

					INSERT INTO	Result.RiskHCCDetail
							(Age,
							BaseWeight,
							BatchID,
							DataRunID,
							DataSetID,
							DemoWeight,
							DSEntityID,
							DSMemberID,
							EvalTypeID,
							Gender,
							HClinCondWeight,
							MeasureID,
							MetricID,
							SourceRowGuid,
							SourceRowID,
							TotalWeight)
					SELECT	W.Age,
							W.BaseWeight,
							@BatchID AS BatchID,
							@DataRunID AS DataRunID,
							@DataSetID AS DataSetID,
							W.DemoWeight,
							W.DSEntityID,
							W.DSMemberID,
							W.EvalTypeID,
							W.Gender, 
							W.HClinCondWeight,
							W.MeasureID,
							W.MetricID,
							W.ResultRowGuid AS SourceRowGuid,
							W.ResultRowID AS SourceRowID,
							W.TotalWeight
					FROM	#Weights AS W
					ORDER BY W.ResultRowID, W.EvalTypeID;

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;


					--Step #10, Log "HCCs"
					DELETE FROM [Log].PCR_ClinicalConditions WHERE BatchID = @BatchID AND DataRunID = @DataRunID AND MeasureID IN (SELECT DISTINCT MeasureID FROM #RiskMetrics);

					INSERT INTO [Log].PCR_ClinicalConditions
							(BatchID, CodeID, CountCodes,
							DataRunID, DataSetID, DSClaimCodeID,
							DSClaimID, DSClaimLineID,
							DSEntityID, DSMemberID, EvalTypeID,
							HClinCond, MeasureID, OwnerID,
							SourceRowGuid, SourceRowID)
					SELECT	@BatchID AS BatchID,
							TCC.CodeID AS CodeID,
							t.CountCodes, 
							@DataRunID AS DataRunID,
							@DataSetID AS DataSetID,
							t.DSClaimCodeID, 
							TCC.DSClaimID,
							TCC.DSClaimLineID,
							B.DSEntityID, 
							B.DSMemberID, 
							B.EvalTypeID,
							t.HClinCond,
							B.MeasureID,
							@OwnerID AS OwnerID,
							B.ResultRowGuid,
							B.ResultRowID
					FROM	#Risk_EntityHCC AS t
							INNER JOIN #Risk_Base AS B
									ON t.ResultRowID = B.ResultRowID 
							LEFT OUTER JOIN Proxy.ClaimCodes AS TCC
									ON t.DSClaimCodeID = TCC.DSClaimCodeID 
					ORDER BY DSEntityID, DSClaimCodeID, HClinCond, MeasureID;
				END;
			ELSE
				SET @CountRecords = ISNULL(@CountRecords, 0);	          

			SET @LogDescr = ' - Calculating risk adjustment for BATCH ' + CAST(@BatchID AS varchar(32)) + ' succeeded.'; 
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

			SET @CountRecords = 0;
			EXEC Ncqa.RRU_CalculateCostAndFrequency @BatchID = @BatchID, @CountRecords = @CountRecords OUTPUT;

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
			SET @LogDescr = ' - Calculating risk adjustment for BATCH ' + CAST(@BatchID AS varchar(32)) + ' failed!'; 
			
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
GRANT EXECUTE ON  [Risk].[CalculateHCCs] TO [Processor]
GO
