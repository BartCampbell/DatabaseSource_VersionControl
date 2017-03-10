SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/22/2011
-- Description:	Calculates the detailed results of the PCR measure.
--				(Original Version: HEDIS 2011)
-- =============================================
CREATE PROCEDURE [Ncqa].[PCR_CalculateMeasureDetail_v1]
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
		SET @LogObjectName = 'PCR_CalculateMeasureDetail'; 
		SET @LogObjectSchema = 'Ncqa'; 
		
		BEGIN TRY;
			--Apply Code IDs to the PCR Clinical Conditions Table--------------------------------
			INSERT INTO Claim.Codes
					(Code,
					 CodeTypeID)
			SELECT DISTINCT
					PCR_CC.Code, PCR_CC.CodeTypeID
			FROM	Ncqa.PCR_ClinicalConditions AS PCR_CC
					LEFT OUTER JOIN Claim.Codes AS CC
							ON PCR_CC.Code = CC.Code AND
								PCR_CC.CodeTypeID = CC.CodeTypeID
			WHERE	(CC.CodeID IS NULL);

			UPDATE	PCR_CC
			SET		CodeID = CC.CodeID
			FROM	Ncqa.PCR_ClinicalConditions AS PCR_CC
					INNER JOIN Claim.Codes AS CC
							ON PCR_CC.Code = CC.Code AND
								PCR_CC.CodeTypeID = CC.CodeTypeID
			WHERE	(PCR_CC.CodeID IS NULL) OR (PCR_CC.CodeID <> CC.CodeID);


			--Identify PCR Entities-------------------------------------------------------------
			DECLARE @PCR_MetricID int;

			SELECT	@PCR_MetricID = MetricID 
			FROM	Measure.Metrics AS MC 
					INNER JOIN Measure.Measures AS MM 
							ON MC.MeasureID = MM.MeasureID 
			WHERE	(MC.Abbrev = 'PCR') AND 
					(MM.MeasureSetID = @MeasureSetID)

			SELECT	RMD.Age,
					TE.BeginDate, 
					TC.DSClaimID,
					RMD.DSEntityID, 
					TC.DSMemberID, 
					TE.EndDate, 
					RMD.EnrollGroupID,
					RMD.Gender,
					RMD.IsIndicator AS HasSurgery,
					RMD.ProductLineID
			INTO	#PCR_Base
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN Proxy.Entities AS TE
							ON RMD.DSEntityID = TE.DSEntityID AND
								RMD.EntityID = TE.EntityID AND
								RMD.MetricID = @PCR_MetricID AND
								RMD.ResultTypeID = 1
					INNER JOIN Proxy.Claims AS TC 
							ON TE.EndDate = TC.EndDate AND
								TE.DSMemberID = TC.DSMemberID AND
								TC.ClaimTypeID = 1 AND
								TC.EndDate IS NOT NULL
			WHERE	(RMD.BatchID = @BatchID);

			CREATE CLUSTERED INDEX IX_PCR_Base ON #PCR_Base (DSEntityID, ProductLineID, Age, Gender);


			--Identify the Discharge Clinical Condition------------------------------------------
			SELECT DISTINCT
					MIN(PCR_CC.ClinCondID) AS ClinCondID, t.DSEntityID
			INTO	#PCR_DCC
			FROM	#PCR_Base AS t
					INNER JOIN Proxy.ClaimLines AS TCL
							ON t.DSClaimID = TCL.DSClaimID 
					INNER JOIN Proxy.ClaimCodes AS TCC
							ON t.DSClaimID = TCC.DSClaimID AND
								TCL.DSClaimID = TCC.DSClaimID AND
								TCL.DSClaimLineID = TCC.DSClaimLineID AND
								TCL.IsPaid = 1
					INNER JOIN Ncqa.PCR_ClinicalConditions AS PCR_CC
							ON TCC.CodeID = PCR_CC.CodeID AND
								TCC.Code = PCR_CC.Code AND
								TCC.CodeTypeID = PCR_CC.CodeTypeID AND 
								TCC.IsPrimary = 1 AND
								PCR_CC.MeasureSetID = @MeasureSetID AND
								PCR_CC.EvalTypeID = 1
			GROUP BY t.DSEntityID 
			ORDER BY DSEntityID 

			CREATE UNIQUE CLUSTERED INDEX IX_PCR_DCC ON #PCR_DCC (DSEntityID);

			UPDATE	RMD
			SET		ClinCondID = ISNULL(DCC.ClinCondID, 0)
			FROM	Result.MeasureDetail AS RMD
					LEFT OUTER JOIN #PCR_DCC AS DCC
							ON RMD.DSEntityID = DCC.DSEntityID AND
								RMD.MetricID = @PCR_MetricID AND
								RMD.BatchID = @BatchID 

			--Identify the Comorbid Weight and Adjusted Probability of Readmission----------------
			DECLARE @CodeType1 tinyint; --CPT
			DECLARE @CodeTypeD tinyint; --ICD-9 Diagnosis Code
			DECLARE @CodeTypeR tinyint; --UB-92 Revenue Code

			SELECT @CodeType1 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '1';
			SELECT @CodeTypeD = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'D';
			SELECT @CodeTypeR = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'R';

			DECLARE @CPTs TABLE ( Code varchar(16) NOT NULL, IsAcute bit NOT NULL, IsInpatient bit NOT NULL );
			DECLARE @RevCodes TABLE ( Code varchar(16) NOT NULL, IsAcute bit NOT NULL, IsInpatient bit NOT NULL );

			INSERT INTO @CPTs (Code, IsAcute, IsInpatient) SELECT Code, IsAcute, IsInpatient FROM Ncqa.PCR_TableB WHERE (CodeTypeID = @CodeType1) AND (MeasureSetID = 1);
			INSERT INTO @RevCodes (Code, IsAcute, IsInpatient) SELECT Code, IsAcute, IsInpatient FROM Ncqa.PCR_TableB WHERE (CodeTypeID = @CodeTypeR) AND (MeasureSetID = 1);

			--Step #1, Identify the valid Comorbid Claims
			SELECT DISTINCT
					CASE WHEN t.DSClaimID = TCL.DSClaimID THEN 0 ELSE 1 END AS AllowPrimary, 
					t.DSClaimID, t.DSEntityID, t.EndDate, TCL.CPT AS RefCPT,
					ISNULL(TCL.EndDate, TCL.BeginDate) AS RefDate, 
					TCL.DSClaimID AS RefDSClaimID, 
					TCL.DSClaimLineID AS RefDSClaimLineID, TCL.Rev AS RefRevCode
			INTO	#PCR_Comorbid_Claims
			FROM	#PCR_Base AS t
					INNER JOIN Proxy.ClaimLines AS TCL
							ON t.DSMemberID = TCL.DSMemberID AND
								TCL.IsPaid = 1 AND
								((TCL.EndDate IS NULL AND TCL.BeginDate BETWEEN DATEADD(dd, -365, t.EndDate) AND t.EndDate) OR
								(TCL.EndDate IS NOT NULL AND TCL.EndDate BETWEEN DATEADD(dd, -365, t.EndDate) AND t.EndDate)) AND
								((TCL.CPT IN (SELECT Code FROM @CPTs)) OR (TCL.Rev IN (SELECT Code FROM @RevCodes)))
			ORDER BY DSEntityID, DSClaimID

			--Step #2, Identify the valid diagnoses on the Comorbid Claims
			SELECT	PCR_CC.ClinCond, PCR_CC.ClinCondID, t.*, 
					TCC.DSClaimCodeID AS RefDSClaimCodeID,
					TCC.Code AS RefCode, 
					TCC.CodeID AS RefCodeID, 
					TCC.IsPrimary AS RefIsPrimary
			INTO	#PCR_Comorbid_Codes
			FROM	#PCR_Comorbid_Claims AS t
					INNER JOIN Proxy.ClaimCodes AS TCC
							ON t.RefDSClaimLineID = TCC.DSClaimLineID AND
								TCC.CodeTypeID = @CodeTypeD AND
								((t.AllowPrimary = 1) OR ((t.AllowPrimary = 0) AND (TCC.IsPrimary = 0)))
					INNER JOIN Ncqa.PCR_ClinicalConditions AS PCR_CC
							ON TCC.CodeID = PCR_CC.CodeID AND
								TCC.Code = PCR_CC.Code AND
								TCC.CodeTypeID = PCR_CC.CodeTypeID AND
								PCR_CC.MeasureSetID = @MeasureSetID AND
								PCR_CC.EvalTypeID = 2 
								
			--Step #3, Apply the "HCC-PCRs"
			SELECT  t.ClinCond, 
					COUNT(DISTINCT t.RefDSClaimCodeID) AS CountCodes, 
					MIN(t.RefDSClaimCodeID) AS DSClaimCodeID, 
					t.DSEntityID, 
					ISNULL(R.HClinCond, t.ClinCond) AS HClinCond, 
					ISNULL(R.RankGrpID, -1) AS RankGrpID, ISNULL(R.RankOrder, 1) AS RankOrder
			INTO	#PCR_HCC
			FROM	#PCR_Comorbid_Codes AS t
					LEFT OUTER JOIN Ncqa.PCR_Ranks AS R
							ON t.ClinCond = R.ClinCond AND
								R.MeasureSetID = @MeasureSetID
			GROUP BY t.ClinCond, t.DSEntityID, 
					ISNULL(R.HClinCond, t.ClinCond), 
					ISNULL(R.RankGrpID, -1), 
					ISNULL(R.RankOrder, 1)
			ORDER BY DSEntityID, RankGrpID, RankOrder;

			--Step #4, Determine the lowest rank for each "HCC-PCR"
			WITH BestRank AS
			(
				SELECT	t.DSEntityID, t.RankGrpID, MIN(RankOrder) AS RankOrder
				FROM	#PCR_HCC AS t
				GROUP BY t.DSEntityID, t.RankGrpID 
			)
			SELECT DISTINCT
					SUM(t.CountCodes) AS CountCodes, 
					MIN(t.DSClaimCodeID) AS DSClaimCodeID,
					t.DSEntityID, t.HClinCond
			INTO	#PCR_EntityHCC
			FROM	#PCR_HCC AS t
					INNER JOIN BestRank AS BR
							ON t.DSEntityID = BR.DSEntityID AND
								t.RankGrpID = BR.RankGrpID AND
								t.RankOrder = BR.RankOrder
			GROUP BY t.DSEntityID, t.HClinCond
			ORDER BY DSEntityID, HClinCond; 

			--Step #5, Identify Combos
			WITH Combos AS
			(
				SELECT	COUNT(DISTINCT HClinCond) AS CountHClinCond, HCombo, OptionNbr, MeasureSetID
				FROM	Ncqa.PCR_HCC_Combinations 
				WHERE	MeasureSetID = @MeasureSetID
				GROUP BY HCombo, OptionNbr, MeasureSetID
			)
			SELECT DISTINCT
					t.DSEntityID, CBO.HCombo
			INTO	#PCR_HCC_Combos
			FROM	#PCR_EntityHCC AS t
					INNER JOIN Ncqa.PCR_HCC_Combinations AS CBO
							ON t.HClinCond = CBO.HClinCond AND
								CBO.MeasureSetID = @MeasureSetID
					INNER JOIN Combos AS C
							ON CBO.HCombo = C.HCombo AND
								CBO.MeasureSetID = C.MeasureSetID AND
								CBO.OptionNbr = C.OptionNbr
			GROUP BY C.CountHClinCond, t.DSEntityID, CBO.OptionNbr, CBO.HCombo
			HAVING (COUNT(DISTINCT t.HClinCond) >= C.CountHClinCond)
			ORDER BY DSEntityID, HCombo;
						
			--Step #6, Delete Child Combos		
			SELECT	t2.*
			INTO	#DeleteCombos
			FROM	#PCR_HCC_Combos AS t1
					INNER JOIN #PCR_HCC_Combos AS t2
							ON t1.DSEntityID = t2.DSEntityID
					INNER JOIN Ncqa.PCR_HCC_CombinationHierarchy AS H
							ON t1.HCombo = H.ParentHCombo AND
								t2.HCombo = H.ChildHCombo AND
								H.MeasureSetID = @MeasureSetID
							
			DELETE	t
			FROM	#PCR_HCC_Combos AS t
					INNER JOIN #DeleteCombos AS d
							ON t.HCombo = d.HCombo AND
								t.DSEntityID  = d.DSEntityID
								
			DROP TABLE #DeleteCombos;

			--Step #7, Add Valid Combos to Entity/HCC List
			INSERT INTO #PCR_EntityHCC 
					(DSEntityID, HClinCond)
			SELECT	DSEntityID, HCombo
			FROM	#PCR_HCC_Combos;
								
			CREATE UNIQUE CLUSTERED INDEX IX_PCR_EntityHCC ON #PCR_EntityHCC (DSEntityID, HClinCond);

			--Step #8, Calculate Weights
			SELECT	CAST(NULL AS decimal(18,12)) AS AdjProbability,
					B.Age,
					CAST(NULL AS decimal(18,12)) AS BaseWeight,
					CAST(NULL AS decimal(18,12)) AS DccWeight,
					CAST(NULL AS decimal(18,12)) AS DemoWeight,
					B.DSEntityID, 
					B.DSMemberID,
					B.Gender,
					B.HasSurgery,
					SUM(ISNULL(CCW.[Weight], 0)) AS HClinCondWeight,
					B.ProductLineID, 
					CAST(NULL AS decimal(18,12)) AS SurgeryWeight,
					CAST(NULL AS decimal(18,12)) AS TotalWeight
			INTO	#Weights
			FROM	#PCR_Base AS B
					LEFT OUTER JOIN #PCR_EntityHCC AS EH
							ON B.DSEntityID = EH.DSEntityID
					LEFT OUTER JOIN Ncqa.PCR_ClinicalConditionWeights AS CCW
							ON EH.HClinCond = CCW.ClinCond AND
								B.ProductLineID = CCW.ProductLineID AND
								CCW.MeasureSetID = @MeasureSetID AND
								CCW.EvalTypeID = 2 AND
								B.Age BETWEEN CCW.FromAge AND CCW.ToAge
			GROUP BY B.Age, B.DSEntityID, B.DSMemberID, B.Gender, B.HasSurgery, B.ProductLineID
			ORDER BY DSEntityID, ProductLineID

			CREATE UNIQUE CLUSTERED INDEX IX_Weights ON #Weights (DSEntityID, ProductLineID);

			UPDATE	W
			SET		BaseWeight = PLW.BaseWeight,
					SurgeryWeight = CASE WHEN W.HasSurgery = 1 THEN PLW.SurgeryWeight ELSE 0 END
			FROM	#Weights AS W
					INNER JOIN NCQA.PCR_ProductLineWeights AS PLW
							ON W.ProductLineID = PLW.ProductLineID AND
								PLW.MeasureSetID = @MeasureSetID AND
								--Added for HEDIS 2012 Compliance
								W.Age BETWEEN PLW.FromAge AND PLW.ToAge;

			UPDATE	W
			SET		DccWeight = ISNULL(CCW.[Weight], 0)
			FROM	#Weights AS W
					LEFT OUTER JOIN #PCR_DCC AS DCC
							ON W.DSEntityID = DCC.DSEntityID	
					LEFT OUTER JOIN Ncqa.PCR_ClinicalConditions AS CC
							ON DCC.ClinCondID = CC.ClinCondID
					LEFT OUTER JOIN Ncqa.PCR_ClinicalConditionWeights AS CCW
							ON CC.ClinCond = CCW.ClinCond AND
								CC.EvalTypeID = CCW.EvalTypeID AND				
								CC.MeasureSetID = CCW.MeasureSetID AND
								W.ProductLineID = CCW.ProductLineID AND
								CCW.MeasureSetID = @MeasureSetID AND
								CCW.EvalTypeID = 1 AND
								--Added for HEDIS 2012 Compliance
								W.Age BETWEEN CCW.FromAge AND CCW.ToAge;
				

			UPDATE	W
			SET		DemoWeight = DW.[Weight]
			FROM	#Weights AS W
					INNER JOIN NCQA.PCR_DemographicWeights AS DW
							ON W.Age BETWEEN DW.FromAge AND DW.ToAge AND
								W.Gender = DW.Gender AND
								W.ProductLineID = DW.ProductLineID AND
								DW.MeasureSetID = @MeasureSetID AND
								--Added for HEDIS 2012 Compliance
								W.Age BETWEEN DW.FromAge AND DW.ToAge;

			UPDATE	#Weights
			SET		AdjProbability = ((exp(BaseWeight + DemoWeight + DccWeight + HClinCondWeight + SurgeryWeight)) / (1 + exp(BaseWeight + DemoWeight + DccWeight + HClinCondWeight + SurgeryWeight))),
					TotalWeight = BaseWeight + DemoWeight + DccWeight + HClinCondWeight + SurgeryWeight;

			UPDATE	RMD
			SET		[Weight] = W.HClinCondWeight
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN #Weights AS W
							ON RMD.DSEntityID = W.DSEntityID AND
								RMD.ProductLineID = W.ProductLineID AND
								RMD.MetricID = @PCR_MetricID AND
								RMD.BatchID = @BatchID;

			--Step #9, Record the results	
			DELETE FROM Result.MeasureDetail_PCR WHERE BatchID = @BatchID;

			INSERT INTO	Result.MeasureDetail_PCR
					(AdjProbability, Age, BaseWeight, BatchID, ClinCondID,
					DataRunID, DataSetID, DccWeight, DemoWeight, DSEntityID,
					DSMemberID, Gender, HClinCondWeight, OwnerID, ProductLineID,
					SurgeryWeight, TotalWeight)
			SELECT	W.AdjProbability,
					W.Age,
					W.BaseWeight,
					@BatchID AS BatchID,
					DCC.ClinCondID,
					@DataRunID AS DataRunID,
					@DataSetID AS DataSetID,
					W.DccWeight,
					W.DemoWeight,
					W.DSEntityID,
					W.DSMemberID,
					W.Gender, 
					W.HClinCondWeight,
					@OwnerID AS OwnerID,
					W.ProductLineID,
					W.SurgeryWeight,
					W.TotalWeight
			FROM	#Weights AS W
					INNER JOIN Proxy.Members AS M
							ON W.DSMemberID = M.DSMemberID
					LEFT OUTER JOIN #PCR_DCC AS DCC
							ON W.DSEntityID = DCC.DSEntityID
			ORDER BY DSEntityID, ProductLineID;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--Step #10, Log "HCC-PCRs"
			DELETE FROM [Log].PCR_ClinicalConditions WHERE BatchID = @BatchID;

			INSERT INTO [Log].PCR_ClinicalConditions
					(BatchID, CodeID, CountCodes,
					DataRunID, DataSetID, DSClaimCodeID,
					DSClaimID, DSClaimLineID,
					DSEntityID, DSMemberID, HClinCond,
					OwnerID)
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
					@OwnerID AS OwnerID
			FROM	#PCR_EntityHCC AS t
					INNER JOIN Proxy.Entities AS TE
							ON t.DSEntityID = TE.DSEntityID
					LEFT OUTER JOIN Proxy.ClaimCodes AS TCC
							ON t.DSClaimCodeID = TCC.DSClaimCodeID 
			ORDER BY DSEntityID, DSClaimCodeID, HClinCond;
			
			SET @LogDescr = ' - Calculating PCR measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' succeeded.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
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
			SET @LogDescr = ' - Calculating PCR measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' failed!'; 
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
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
GRANT VIEW DEFINITION ON  [Ncqa].[PCR_CalculateMeasureDetail_v1] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[PCR_CalculateMeasureDetail_v1] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[PCR_CalculateMeasureDetail_v1] TO [Processor]
GO
