SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/19/2014
-- Description:	Calculates the detailed results of the RRU measures.
-- =============================================
CREATE PROCEDURE [Ncqa].[RRU_CalculateMeasureDetail]
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
		SET @LogObjectName = 'RRU_CalculateMeasureDetail'; 
		SET @LogObjectSchema = 'Ncqa'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
						
			--CREATED FROM Ncqa.CalcMeasureDetail_PCR---------------------------------------------
			--1) Find and Replace for "#PCR_" with "#RRU_".
			--2) Implementation of replacement for #PCR_Base as #RRU_Base. 
			--3) Remove "(IsSurg = 0) AND " from population of #CPTs, #HCPCSs, and #RevCodes
			--4) Make adjustments to final table population
			--------------------------------------------------------------------------------------

			--Identify RRU measures for the current measure set...
			SELECT	MeasureID
			INTO	#RRU_Measures
			FROM	Measure.Measures 
			WHERE	(IsEnabled = 1) AND
					(MeasClassID IN (SELECT MeasClassID FROM Measure.MeasureClasses WHERE Abbrev IN ('COC', 'RRU'))) AND
					(MeasureSetID = @MeasureSetID);         

			CREATE UNIQUE CLUSTERED INDEX IX_#RRU_Measures ON #RRU_Measures (MeasureID);

			--Identify base resultset
			SELECT	RMD.Age,
					@BeginInitSeedDate AS BeginDate, 
					RMD.BitProductLines,
					RMD.DSEntityID, 
					RMD.DSMemberID, 
					@EndInitSeedDate AS EndDate, 
					RMD.EnrollGroupID,
					RMD.Gender,
					RMD.MeasureID,
					RMD.MetricID,
					RMD.ResultRowGuid AS ResultRowGuid,
					RMD.ResultRowID
			INTO	#RRU_Base          
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN #RRU_Measures AS RM
							ON RMD.MeasureID = RM.MeasureID
					INNER JOIN Measure.Metrics AS MX
							ON RM.MeasureID = MX.MeasureID AND
								RMD.MeasureID = MX.MeasureID AND
								RMD.MetricID = MX.MetricID AND
								MX.IsShown = 1 AND
								MX.IsEnabled = 1                          
			WHERE	(RMD.BatchID = @BatchID) AND
					(RMD.DataRunID = @DataRunID) AND
					((RMD.IsDenominator = 1) OR (RMD.IsExclusion = 1));       
					
			IF EXISTS(SELECT TOP 1 1 FROM #RRU_Base)
				BEGIN;   

					CREATE UNIQUE CLUSTERED INDEX IX_#RRU_Base ON #RRU_Base (ResultRowID);
					CREATE UNIQUE NONCLUSTERED INDEX IX_#RRU_Base_DSEntityID ON #RRU_Base (DSEntityID) INCLUDE (Age, Gender);
					CREATE NONCLUSTERED INDEX IX_#RRU_Base_DSMemberID ON #RRU_Base (DSMemberID) INCLUDE (BeginDate, EndDate);

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

					CREATE TABLE #CPTs (Code varchar(16) NOT NULL, IsAcute bit NOT NULL, IsInpatient bit NOT NULL);
					CREATE TABLE #HCPCSs (Code varchar(16) NOT NULL, IsAcute bit NOT NULL, IsInpatient bit NOT NULL);
					CREATE TABLE #RevCodes (Code varchar(16) NOT NULL, IsAcute bit NOT NULL, IsInpatient bit NOT NULL);

					--HCC_Codes formerly PCR Table-B)
					INSERT INTO #CPTs (Code, IsAcute, IsInpatient) SELECT Code, IsAcute, IsInpatient FROM Ncqa.PCR_HCC_Codes WHERE (CodeTypeID = @CodeType1) AND (MeasureSetID = @MeasureSetID);
					INSERT INTO #HCPCSs (Code, IsAcute, IsInpatient) SELECT Code, IsAcute, IsInpatient FROM Ncqa.PCR_HCC_Codes WHERE (CodeTypeID = @CodeTypeH) AND (MeasureSetID = @MeasureSetID);
					INSERT INTO #RevCodes (Code, IsAcute, IsInpatient) SELECT Code, IsAcute, IsInpatient FROM Ncqa.PCR_HCC_Codes WHERE (CodeTypeID = @CodeTypeR) AND (MeasureSetID = @MeasureSetID);

					CREATE UNIQUE CLUSTERED INDEX IX_#CPTs ON #CPTs (Code);
					CREATE UNIQUE CLUSTERED INDEX IX_#HCPCSs ON #HCPCSs (Code);
					CREATE UNIQUE CLUSTERED INDEX IX_#RevCodes ON #RevCodes (Code);
            
					--Step #1, Identify the valid Comorbid Claims
					SELECT DISTINCT
							1 AS AllowPrimary,		--Set to 1 for RRU
							--t.DSClaimID,			--Not valid for RRU
							t.DSEntityID, 
							t.EndDate, 
							IDENTITY(bigint, 1, 1) AS ID,
							t.MeasureID,
							TCL.CPT AS RefCPT,
							ISNULL(TCL.EndDate, TCL.BeginDate) AS RefDate, 
							TCL.DSClaimID AS RefDSClaimID, 
							TCL.DSClaimLineID AS RefDSClaimLineID, 
							TCL.HCPCS AS RefHCPCS,
							TCL.Rev AS RefRevCode
					INTO	#RRU_Comorbid_Claims
					FROM	#RRU_Base AS t
							INNER JOIN Proxy.ClaimLines AS TCL
									ON t.DSMemberID = TCL.DSMemberID AND
										--TCL.IsPaid = 1 AND
										TCL.IsSupplemental = 0 AND
										((TCL.EndDate IS NULL AND TCL.BeginDate BETWEEN t.BeginDate AND t.EndDate) OR
										(TCL.EndDate IS NOT NULL AND TCL.EndDate BETWEEN t.BeginDate AND t.EndDate)) AND
										((TCL.CPT IN (SELECT Code FROM #CPTs)) OR (TCL.HCPCS IN (SELECT Code FROM #HCPCSs)) OR (TCL.Rev IN (SELECT Code FROM #RevCodes)))
					ORDER BY DSEntityID, DSClaimID;

					CREATE UNIQUE CLUSTERED INDEX IX_#RRU_Comorbid_Claims ON #RRU_Comorbid_Claims (RefDSClaimLineID, ID);

					--Step #2, Identify the valid diagnoses on the Comorbid Claims
					SELECT	PCR_CC.ClinCond, 
							PCR_CC.ClinCondID, 
							t.*, 
							TCC.DSClaimCodeID AS RefDSClaimCodeID,
							TCC.Code AS RefCode, 
							TCC.CodeID AS RefCodeID, 
							TCC.IsPrimary AS RefIsPrimary
					INTO	#RRU_Comorbid_Codes
					FROM	#RRU_Comorbid_Claims AS t
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
								
					CREATE UNIQUE CLUSTERED INDEX IX_#RRU_Comorbid_Codes ON #RRU_Comorbid_Codes (ClinCond, RefDSClaimCodeID, ID);

					--Step #3, Apply the "HCCs"
					SELECT  t.ClinCond, 
							COUNT(DISTINCT t.RefDSClaimCodeID) AS CountCodes, 
							MIN(t.RefDSClaimCodeID) AS DSClaimCodeID, 
							t.DSEntityID, 
							ISNULL(R.HClinCond, t.ClinCond) AS HClinCond, 
							ISNULL(R.RankGrpID, -1) AS RankGrpID, 
							ISNULL(R.RankOrder, 1) AS RankOrder
					INTO	#RRU_HCC
					FROM	#RRU_Comorbid_Codes AS t
							LEFT OUTER JOIN Ncqa.PCR_Ranks AS R
									ON t.ClinCond = R.ClinCond AND
										R.MeasureSetID = @MeasureSetID
					GROUP BY t.ClinCond, 
							t.DSEntityID, 
							ISNULL(R.HClinCond, t.ClinCond), 
							ISNULL(R.RankGrpID, -1), 
							ISNULL(R.RankOrder, 1)
					ORDER BY DSEntityID, RankGrpID, RankOrder;

					CREATE UNIQUE CLUSTERED INDEX IX_#RRU_HCC ON #RRU_HCC (DSEntityID, RankGrpID, RankOrder, HClinCond);

					--Step #4, Determine the lowest rank for each "HCC-PCR"
					WITH BestRank AS
					(
						SELECT	t.DSEntityID, t.RankGrpID, MIN(RankOrder) AS RankOrder
						FROM	#RRU_HCC AS t
						GROUP BY t.DSEntityID, t.RankGrpID 
					)
					SELECT DISTINCT
							SUM(t.CountCodes) AS CountCodes, 
							MIN(t.DSClaimCodeID) AS DSClaimCodeID,
							t.DSEntityID, 
							t.HClinCond
					INTO	#RRU_EntityHCC
					FROM	#RRU_HCC AS t
							INNER JOIN BestRank AS BR
									ON t.DSEntityID = BR.DSEntityID AND
										t.RankGrpID = BR.RankGrpID AND
										t.RankOrder = BR.RankOrder
					GROUP BY t.DSEntityID, t.HClinCond
					ORDER BY DSEntityID, HClinCond; 

					--Step #5, Identify Combos
					SELECT	COUNT(DISTINCT HClinCond) AS CountHClinCond, HCombo, OptionNbr
					INTO	#Combos
					FROM	Ncqa.PCR_HCC_Combinations 
					WHERE	MeasureSetID = @MeasureSetID
					GROUP BY HCombo, OptionNbr;

					CREATE UNIQUE CLUSTERED INDEX IX_#Combos ON #Combos (HCombo, OptionNbr);
			
					SELECT DISTINCT
							t.DSEntityID, 
							CBO.HCombo
					INTO	#RRU_HCC_Combos
					FROM	#RRU_EntityHCC AS t
							INNER JOIN Ncqa.PCR_HCC_Combinations AS CBO
									ON t.HClinCond = CBO.HClinCond
							INNER JOIN #Combos AS C
									ON CBO.HCombo = C.HCombo AND
										CBO.OptionNbr = C.OptionNbr
					WHERE	(CBO.MeasureSetID = @MeasureSetID)
					GROUP BY C.CountHClinCond, 
							t.DSEntityID, 
							CBO.OptionNbr, 
							CBO.HCombo
					HAVING (COUNT(DISTINCT t.HClinCond) >= C.CountHClinCond)
					ORDER BY DSEntityID, HCombo;
						
					CREATE UNIQUE CLUSTERED INDEX IX_#RRU_HCC_Combos ON #RRU_HCC_Combos(DSEntityID, HCombo);

					--Step #6, Delete Child Combos		
					SELECT	t2.*
					INTO	#DeleteCombos
					FROM	#RRU_HCC_Combos AS t1
							INNER JOIN #RRU_HCC_Combos AS t2
									ON t1.DSEntityID = t2.DSEntityID
							INNER JOIN Ncqa.PCR_HCC_CombinationHierarchy AS H
									ON t1.HCombo = H.ParentHCombo AND
										t2.HCombo = H.ChildHCombo AND
										H.MeasureSetID = @MeasureSetID;
								
					CREATE UNIQUE CLUSTERED INDEX IX_#DeleteCombos ON #DeleteCombos(DSEntityID, HCombo);
					
					DELETE	t
					FROM	#RRU_HCC_Combos AS t
							INNER JOIN #DeleteCombos AS d
									ON t.HCombo = d.HCombo AND
										t.DSEntityID  = d.DSEntityID;
								
					DROP TABLE #DeleteCombos;

					--Step #7, Add Valid Combos to Entity/HCC List
					INSERT INTO #RRU_EntityHCC 
							(DSEntityID, HClinCond)
					SELECT	DSEntityID, HCombo
					FROM	#RRU_HCC_Combos;
								
					CREATE UNIQUE CLUSTERED INDEX IX_#RRU_EntityHCC ON #RRU_EntityHCC (DSEntityID, HClinCond);

					--Step #8, Calculate Weights
					SELECT	B.Age,
							CAST(0 AS decimal(18, 12)) AS DemoWeight,
							B.DSEntityID, 
							B.DSMemberID,
							B.Gender,
							SUM(ISNULL(CCW.[Weight], 0)) AS HClinCondWeight,
							B.ResultRowGuid, 
							B.ResultRowID,
							CAST(NULL AS tinyint) AS RiskCtgyID,
							CAST(0 AS decimal(18, 12)) AS TotalWeight
					INTO	#Weights
					FROM	#RRU_Base AS B
							LEFT OUTER JOIN #RRU_EntityHCC AS EH
									ON B.DSEntityID = EH.DSEntityID
							LEFT OUTER JOIN Ncqa.PCR_ClinicalConditionWeights AS CCW
									ON EH.HClinCond = CCW.ClinCond AND
										CCW.MeasureSetID = @MeasureSetID AND
										CCW.EvalTypeID = 3 AND
										CCW.BitProductLines = 0 AND                              
										B.Age BETWEEN CCW.FromAge AND CCW.ToAge
					GROUP BY B.Age, B.DSEntityID, B.DSMemberID, B.Gender,
							B.ResultRowGuid, B.ResultRowID
					ORDER BY DSEntityID;

					UPDATE	W
					SET		DemoWeight = DW.[Weight]
					FROM	#Weights AS W
							INNER JOIN NCQA.PCR_DemographicWeights AS DW
									ON W.Age BETWEEN DW.FromAge AND DW.ToAge AND
										W.Gender = DW.Gender AND
										DW.MeasureSetID = @MeasureSetID AND
										DW.EvalTypeID = 3 AND
										DW.BitProductLines = 0 AND
										W.Age BETWEEN DW.FromAge AND DW.ToAge;
			
					UPDATE	#Weights
					SET		TotalWeight = ROUND(DemoWeight + HClinCondWeight, 4);
			
					UPDATE	W
					SET		RiskCtgyID = NRRC.RiskCtgyID
					FROM	#Weights AS W
							INNER JOIN Ncqa.RRU_RiskCategories AS NRRC
									ON W.TotalWeight BETWEEN NRRC.FromWeight AND NRRC.ToWeight;

					--Step #9a, Record the results in Measure Detail
					UPDATE	RMD
					SET		[Weight] = W.HClinCondWeight
					FROM	Result.MeasureDetail AS RMD
							INNER JOIN #Weights AS W
									ON RMD.DSEntityID = W.DSEntityID AND
										RMD.ResultRowID = W.ResultRowID
					WHERE	(RMD.BatchID = @BatchID) AND
							(RMD.MeasureID IN (SELECT MeasureID FROM #RRU_Measures));					

					--Step #9b, Record the results in RRU-Specific Measure DEtail
					DELETE FROM Result.MeasureDetail_RRU WHERE BatchID = @BatchID;

					INSERT INTO	Result.MeasureDetail_RRU
							(Age,
							BatchID,
							DataRunID,
							DataSetID,
							DemoWeight,
							DSEntityID,
							DSMemberID,
							Gender,
							HClinCondWeight,
							RiskCtgyID,
							SourceRowGuid,
							SourceRowID,
							TotalWeight)
					SELECT	W.Age,
							@BatchID AS BatchID,
							@DataRunID AS DataRunID,
							@DataSetID AS DataSetID,
							W.DemoWeight,
							W.DSEntityID,
							W.DSMemberID,
							W.Gender, 
							W.HClinCondWeight,
							W.RiskCtgyID,
							W.ResultRowGuid AS SourceRowGuid,
							W.ResultRowID AS SourceRowID,
							W.TotalWeight
					FROM	#Weights AS W
					ORDER BY DSEntityID;

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;


					--Step #10, Log "HCCs"
					DELETE FROM [Log].PCR_ClinicalConditions WHERE BatchID = @BatchID AND MeasureID IN (SELECT MeasureID FROM #RRU_Measures);

					INSERT INTO [Log].PCR_ClinicalConditions
							(BatchID, CodeID, CountCodes,
							DataRunID, DataSetID, DSClaimCodeID,
							DSClaimID, DSClaimLineID,
							DSEntityID, DSMemberID, HClinCond,
							MeasureID, OwnerID)
					SELECT	@BatchID AS BatchID,
							TCC.CodeID AS CodeID,
							t.CountCodes, 
							@DataRunID AS DataRunID,
							@DataSetID AS DataSetID,
							t.DSClaimCodeID, 
							TCC.DSClaimID,
							TCC.DSClaimLineID,
							t.DSEntityID, 
							TE.DSMemberID, 
							t.HClinCond,
							B.MeasureID,
							@OwnerID AS OwnerID
					FROM	#RRU_EntityHCC AS t
							INNER JOIN #RRU_Base AS B
									ON t.DSEntityID = B.DSEntityID 
							INNER JOIN Proxy.Entities AS TE
									ON t.DSEntityID = TE.DSEntityID
							LEFT OUTER JOIN Proxy.ClaimCodes AS TCC
									ON t.DSClaimCodeID = TCC.DSClaimCodeID 
					ORDER BY DSEntityID, DSClaimCodeID, HClinCond, MeasureID;
				END;
			ELSE
				SET @CountRecords = ISNULL(@CountRecords, 0);	          

			SET @LogDescr = ' - Calculating RRU measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' succeeded.'; 
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
			SET @LogDescr = ' - Calculating RRU measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' failed!'; 
			
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
GRANT EXECUTE ON  [Ncqa].[RRU_CalculateMeasureDetail] TO [Processor]
GO
