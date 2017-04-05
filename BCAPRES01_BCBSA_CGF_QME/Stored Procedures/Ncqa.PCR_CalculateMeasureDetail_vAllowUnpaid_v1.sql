SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/3/2016
-- Description:	Calculates the detailed results of the PCR measure.
-- =============================================
CREATE PROCEDURE [Ncqa].[PCR_CalculateMeasureDetail_vAllowUnpaid_v1]
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
		SET @LogObjectName = 'PCR_CalculateMeasureDetail_vAllowUnpaid'; 
		SET @LogObjectSchema = 'Ncqa'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
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
			DECLARE @MeasureID int;
			DECLARE @MetricID int;

			SELECT @MeasureID = MeasureID FROM Measure.Measures WHERE (Abbrev = 'PCR') AND (MeasureSetID = @MeasureSetID);
			SELECT @MetricID = MetricID FROM Measure.Metrics WHERE (MeasureID = @MeasureID);

			--This #Payers step may now be obsolete.  NOT NEEDED FOR HEDIS, BUT MAYBE FOR CGF
			SELECT 	PP.PayerID, MAX(PPL.ProductLineID) AS ProductLineID	
			INTO	#Payers
			FROM	Product.Payers AS PP
					INNER JOIN Product.PayerProductLines AS PPPL
							ON PP.PayerID = PPPL.PayerID
					INNER JOIN Product.ProductLines AS PPL
							ON PPL.ProductLineID = PPPL.ProductLineID
					INNER JOIN Ncqa.PCR_ProductLineWeights AS NPPLW
							ON PPL.BitValue & NPPLW.BitProductLines > 0
			WHERE	(NPPLW.MeasureSetID = @MeasureSetID)
			GROUP BY PP.PayerID
			UNION
			SELECT	PayerID, ProductLineID
			FROM	Product.Payers 
			WHERE	(PayerID = 0);

			CREATE UNIQUE CLUSTERED INDEX IX_#Payers ON #Payers (PayerID, ProductLineID);

			SELECT	RMD.Age,
					MIN(TE.BeginDate) AS BeginDate, 
					RMD.BitProductLines,
					MIN(TC.DSClaimID) AS DSClaimID,
					RMD.DSEntityID, 
					RMD.DSMemberID, 
					MAX(TE.EndDate) AS EndDate, 
					RMD.EnrollGroupID,
					RMD.Gender,
					RMD.IsIndicator AS HasSurgery,
					P.ProductLineID,
					RMD.ResultRowGuid AS ResultRowGuid,
					RMD.ResultRowID
			INTO	#PCR_Base
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN #Payers AS P
							ON RMD.PayerID = P.PayerID
					INNER JOIN Proxy.Entities AS TE
							ON RMD.BatchID = TE.BatchID AND
								RMD.DataRunID = TE.DataRunID AND
								RMD.DataSetID = TE.DataSetID AND
								RMD.DSEntityID = TE.DSEntityID AND
								RMD.EntityID = TE.EntityID AND
								RMD.MeasureID = @MeasureID AND                              
								RMD.MetricID = @MetricID AND
								RMD.ResultTypeID = 1
					INNER JOIN Proxy.Claims AS TC 
							ON TE.BatchID = TC.BatchID AND
								TE.DataRunID = TC.DataRunID AND
								TE.DataSetID = TC.DataSetID AND
								TE.EndDate = TC.EndDate AND
								TE.DSMemberID = TC.DSMemberID AND
								TC.ClaimTypeID = 1 AND
								TC.EndDate IS NOT NULL
			WHERE	(RMD.BatchID = @BatchID)
			GROUP BY 
					P.ProductLineID, 
					RMD.Age, 
					RMD.BitProductLines,
					RMD.DSEntityID, 
					RMD.DSMemberID, 
					RMD.EnrollGroupID,
					RMD.Gender,
					RMD.IsIndicator,
					RMD.ResultRowGuid,
					RMD.ResultRowID;

			CREATE UNIQUE CLUSTERED INDEX IX_#PCR_Base ON #PCR_Base (DSEntityID, ProductLineID, Age, Gender, ResultRowID);
			
			IF EXISTS (SELECT TOP 1 1 FROM #PCR_Base)
				BEGIN;

					IF EXISTS (SELECT TOP 1 1 FROM #PCR_Base WHERE ProductLineID = 0)
						BEGIN;

							CREATE NONCLUSTERED INDEX IX_#PCR_Base2 ON #PCR_Base (DSMemberID, EndDate) WHERE (ProductLineID = 0);

							SELECT DISTINCT
									DSMemberID, EndDate
							INTO	#MembersMissingProductLines
							FROM	#PCR_Base
							WHERE	(ProductLineID = 0);

							CREATE UNIQUE CLUSTERED INDEX IX_#MembersMissingProductLines ON #MembersMissingProductLines (DSMemberID, EndDate);

							SELECT	t.DSMemberID,
									t.EndDate,
									MAX(n.ProductLineID) AS ProductLineID
							INTO	#MembersFoundProductLines
							FROM	#MembersMissingProductLines AS t
									CROSS APPLY (
													SELECT TOP 1 
															MAX(P.ProductLineID) AS ProductLineID
													FROM	Proxy.Enrollment AS PN WITH(NOLOCK)
															INNER JOIN Proxy.EnrollmentKey AS PNK WITH(NOLOCK)
																	ON PN.BatchID = PNK.BatchID AND
																		PN.DataRunID = PNK.DataRunID AND
																		PN.DataSetID = PNK.DataSetID AND
																		PN.EnrollGroupID = PNK.EnrollGroupID AND
																		PN.BitBenefits & 1 > 0                                                              
															INNER JOIN #Payers AS P
																	ON PNK.PayerID = P.PayerID 
													WHERE	(PN.DSMemberID = t.DSMemberID) AND
															(PN.BeginDate <= t.EndDate)
													GROUP BY CASE WHEN PN.EndDate >= t.EndDate THEN 1 ELSE 0 END,
															PN.EndDate,
															PN.BeginDate
													ORDER BY CASE WHEN PN.EndDate >= t.EndDate THEN 1 ELSE 0 END DESC,
															PN.EndDate DESC, 
															PN.BeginDate DESC
												) AS n      
							GROUP BY t.DSMemberID,
									t.EndDate;

							CREATE UNIQUE CLUSTERED INDEX IX_#MembersFoundProductLiness ON #MembersFoundProductLines (DSMemberID, EndDate);

							UPDATE	PCR
							SET		ProductLineID = t.ProductLineID
							FROM	#PCR_Base AS PCR
									INNER JOIN #MembersFoundProductLines AS t
											ON PCR.DSMemberID = t.DSMemberID AND
												PCR.EndDate = t.EndDate
							WHERE	(PCR.ProductLineID = 0);                                  

						END;              


					--Identify the Discharge Clinical Condition(s)---------------------------------------
					DECLARE @ClaimAttribIN tinyint;
					SELECT @ClaimAttribIN = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'IN';

					SELECT DISTINCT 
							PCL.DSClaimID, PCL.DSClaimLineID, PCL.DSMemberID, PCL.IsPaid, PCL.IsSupplemental
					INTO	#InpatientClaimLines 
					FROM	Proxy.ClaimAttributes AS PCA
							INNER JOIN Proxy.ClaimLines AS PCL
									ON PCL.DSClaimLineID = PCA.DSClaimLineID AND
										PCL.DSMemberID = PCA.DSMemberID
					WHERE	ClaimAttribID = @ClaimAttribIN AND
							PCL.DSClaimID IN (SELECT DISTINCT DSClaimID FROM #PCR_Base);
							
					CREATE UNIQUE CLUSTERED INDEX IX_#InpatientClaimLines ON #InpatientClaimLines (DSClaimID, DSClaimLineID);

					SELECT DISTINCT
							--MIN(PCR_CC.ClinCondID) AS ClinCondID, t.DSEntityID,
							PCR_CC.ClinCond, PCR_CC.ClinCondID, t.DSEntityID
					INTO	#PCR_DCC_Base
					FROM	#PCR_Base AS t
							INNER JOIN #InpatientClaimLines AS TCL
									ON t.DSClaimID = TCL.DSClaimID 
							INNER JOIN Proxy.ClaimCodes AS TCC
									ON t.DSClaimID = TCC.DSClaimID AND
										TCL.DSClaimID = TCC.DSClaimID AND
										TCL.DSClaimLineID = TCC.DSClaimLineID AND
										TCL.IsPaid = 1 AND 
										TCL.IsSupplemental = 0
							INNER JOIN Ncqa.PCR_ClinicalConditions AS PCR_CC
									ON TCC.CodeID = PCR_CC.CodeID AND
										TCC.Code = PCR_CC.Code AND
										TCC.CodeTypeID = PCR_CC.CodeTypeID AND 
										TCC.IsPrimary = 1 AND
										PCR_CC.MeasureSetID = @MeasureSetID AND
										PCR_CC.EvalTypeID = 1
					--GROUP BY t.DSEntityID 
					ORDER BY DSEntityID, PCR_CC.ClinCondID;

					CREATE UNIQUE CLUSTERED INDEX IX_#PCR_DCC_Base ON #PCR_DCC_Base (ClinCondID, DSEntityID);

					SELECT	[1] AS ClinCondID,
							[1] AS ClinCondID1,
							[2] AS ClinCondID2,
							[3] AS ClinCondID3,
							[4] AS ClinCondID4,
							DSEntityID
					INTO	#PCR_DCC
					FROM	(	
								SELECT	PCR.ClinCondID,
										PCR.DSEntityID,
										ROW_NUMBER() OVER (PARTITION BY PCR.DSEntityID ORDER BY PCR.ClinCond) AS SortOrder
								FROM	#PCR_DCC_Base AS PCR
							) AS t
							PIVOT
							(
								MAX(ClinCondID)
								FOR SortOrder IN ([1], [2], [3], [4])
							) AS p;

					CREATE UNIQUE CLUSTERED INDEX IX_#PCR_DCC ON #PCR_DCC (DSEntityID);

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
					INSERT INTO #CPTs (Code, IsAcute, IsInpatient) SELECT Code, IsAcute, IsInpatient FROM Ncqa.PCR_HCC_Codes WHERE (CodeTypeID = @CodeType1) AND (IsSurg = 0) AND (MeasureSetID = @MeasureSetID);
					INSERT INTO #HCPCSs (Code, IsAcute, IsInpatient) SELECT Code, IsAcute, IsInpatient FROM Ncqa.PCR_HCC_Codes WHERE (CodeTypeID = @CodeTypeH) AND (IsSurg = 0) AND (MeasureSetID = @MeasureSetID);
					INSERT INTO #RevCodes (Code, IsAcute, IsInpatient) SELECT Code, IsAcute, IsInpatient FROM Ncqa.PCR_HCC_Codes WHERE (CodeTypeID = @CodeTypeR) AND (IsSurg = 0) AND (MeasureSetID = @MeasureSetID);

					CREATE UNIQUE CLUSTERED INDEX IX_#CPTs ON #CPTs (Code);
					CREATE UNIQUE CLUSTERED INDEX IX_#HCPCSs ON #HCPCSs (Code);
					CREATE UNIQUE CLUSTERED INDEX IX_#RevCodes ON #RevCodes (Code);
            
					--Step #1, Identify the valid Comorbid Claims
					SELECT DISTINCT
							CASE WHEN t.DSClaimID = TCL.DSClaimID AND ICL.DSClaimLineID IS NOT NULL THEN 0 ELSE 1 END AS AllowPrimary, 
							t.DSClaimID, t.DSEntityID, t.EndDate, 
							IDENTITY(bigint, 1, 1) AS ID,
							TCL.CPT AS RefCPT,
							ISNULL(TCL.EndDate, TCL.BeginDate) AS RefDate, 
							TCL.DSClaimID AS RefDSClaimID, 
							TCL.DSClaimLineID AS RefDSClaimLineID, 
							TCL.HCPCS AS RefHCPCS,
							TCL.Rev AS RefRevCode
					INTO	#PCR_Comorbid_Claims
					FROM	#PCR_Base AS t
							INNER JOIN Proxy.ClaimLines AS TCL
									ON t.DSMemberID = TCL.DSMemberID AND
										TCL.IsSupplemental = 0 AND
										--TCL.IsPaid = 1 AND
										((TCL.EndDate IS NULL AND TCL.BeginDate BETWEEN DATEADD(dd, -365, t.EndDate) AND t.EndDate) OR
										(TCL.EndDate IS NOT NULL AND TCL.EndDate BETWEEN DATEADD(dd, -365, t.EndDate) AND t.EndDate)) AND
										((TCL.CPT IN (SELECT Code FROM #CPTs)) OR (TCL.HCPCS IN (SELECT Code FROM #HCPCSs)) OR (TCL.Rev IN (SELECT Code FROM #RevCodes)))
							LEFT OUTER JOIN #InpatientClaimLines AS ICL WITH(INDEX(1))
									ON ICL.DSClaimLineID = TCL.DSClaimLineID AND
										ICL.DSClaimID = TCL.DSClaimID
					ORDER BY DSEntityID, DSClaimID;

					CREATE UNIQUE CLUSTERED INDEX IX_#PCR_Comorbid_Claims ON #PCR_Comorbid_Claims (RefDSClaimLineID, ID);
					DROP TABLE #InpatientClaimLines;

					--Step #2, Identify the valid diagnoses on the Comorbid Claims
					SELECT	PCR_CC.ClinCond, PCR_CC.ClinCondID, 
							t.*, 
							TCC.DSClaimCodeID AS RefDSClaimCodeID,
							TCC.Code AS RefCode, 
							TCC.CodeID AS RefCodeID, 
							TCC.IsPrimary AS RefIsPrimary
					INTO	#PCR_Comorbid_Codes
					FROM	#PCR_Comorbid_Claims AS t
							INNER JOIN Proxy.ClaimCodes AS TCC
									ON t.RefDSClaimLineID = TCC.DSClaimLineID AND
										TCC.CodeTypeID IN (@CodeTypeD, @CodeTypeI) AND
										((t.AllowPrimary = 1) OR ((t.AllowPrimary = 0) AND (TCC.IsPrimary = 0)))
							INNER JOIN Ncqa.PCR_ClinicalConditions AS PCR_CC
									ON TCC.CodeID = PCR_CC.CodeID AND
										TCC.Code = PCR_CC.Code AND
										TCC.CodeTypeID = PCR_CC.CodeTypeID AND
										PCR_CC.MeasureSetID = @MeasureSetID AND
										PCR_CC.EvalTypeID = 2 
								
					CREATE UNIQUE CLUSTERED INDEX IX_#PCR_Comorbid_Codes ON #PCR_Comorbid_Codes (ClinCond, RefDSClaimCodeID, ID);

					--Step #3, Apply the "HCCs"
					SELECT  t.ClinCond, 
							COUNT(DISTINCT t.RefDSClaimCodeID) AS CountCodes, 
							MIN(t.RefDSClaimCodeID) AS DSClaimCodeID, 
							t.DSEntityID, 
							ISNULL(R.HClinCond, t.ClinCond) AS HClinCond, 
							ISNULL(R.RankGrpID, -1) AS RankGrpID, 
							ISNULL(R.RankOrder, 1) AS RankOrder
					INTO	#PCR_HCC
					FROM	#PCR_Comorbid_Codes AS t
							LEFT OUTER JOIN Ncqa.PCR_Ranks AS R
									ON t.ClinCond = R.ClinCond AND
										R.MeasureSetID = @MeasureSetID
					GROUP BY t.ClinCond, 
							t.DSEntityID, 
							ISNULL(R.HClinCond, t.ClinCond), 
							ISNULL(R.RankGrpID, -1), 
							ISNULL(R.RankOrder, 1)
					ORDER BY DSEntityID, RankGrpID, RankOrder;

					CREATE UNIQUE CLUSTERED INDEX IX_#PCR_HCC ON #PCR_HCC (DSEntityID, RankGrpID, RankOrder, HClinCond);

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
							t.DSEntityID, 
							t.HClinCond
					INTO	#PCR_EntityHCC
					FROM	#PCR_HCC AS t
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
					INTO	#PCR_HCC_Combos
					FROM	#PCR_EntityHCC AS t
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
						
					CREATE UNIQUE CLUSTERED INDEX IX_#PCR_HCC_Combos ON #PCR_HCC_Combos(DSEntityID, HCombo);

					--Step #6, Delete Child Combos		
					SELECT	t2.*
					INTO	#DeleteCombos
					FROM	#PCR_HCC_Combos AS t1
							INNER JOIN #PCR_HCC_Combos AS t2
									ON t1.DSEntityID = t2.DSEntityID
							INNER JOIN Ncqa.PCR_HCC_CombinationHierarchy AS H
									ON t1.HCombo = H.ParentHCombo AND
										t2.HCombo = H.ChildHCombo AND
										H.MeasureSetID = @MeasureSetID;
								
					CREATE UNIQUE CLUSTERED INDEX IX_#DeleteCombos ON #DeleteCombos(DSEntityID, HCombo);
					
					DELETE	t
					FROM	#PCR_HCC_Combos AS t
							INNER JOIN #DeleteCombos AS d
									ON t.HCombo = d.HCombo AND
										t.DSEntityID  = d.DSEntityID;
								
					DROP TABLE #DeleteCombos;

					--Step #7, Add Valid Combos to Entity/HCC List
					INSERT INTO #PCR_EntityHCC 
							(DSEntityID, HClinCond)
					SELECT	DSEntityID, HCombo
					FROM	#PCR_HCC_Combos;
								
					CREATE UNIQUE CLUSTERED INDEX IX_#PCR_EntityHCC ON #PCR_EntityHCC (DSEntityID, HClinCond);

					--Step #8, Calculate Weights
					DECLARE @DccWeight decimal(18,12);

					SELECT	CAST(NULL AS decimal(18,12)) AS AdjProbability,
							B.Age,
							CAST(NULL AS decimal(18,12)) AS BaseWeight,
							B.BitProductLines,
							CAST(NULL AS decimal(18,12)) AS DccWeight,
							CAST(0 AS decimal(18,12)) AS DccWeight1,
							CAST(0 AS decimal(18,12)) AS DccWeight2,
							CAST(0 AS decimal(18,12)) AS DccWeight3,
							CAST(0 AS decimal(18,12)) AS DccWeight4,
							CAST(NULL AS decimal(18,12)) AS DemoWeight,
							B.DSEntityID, 
							B.DSMemberID,
							B.Gender,
							B.HasSurgery,
							SUM(ISNULL(CCW.[Weight], 0)) AS HClinCondWeight,
							B.ProductLineID,
							B.ResultRowGuid, 
							B.ResultRowID,
							CAST(NULL AS decimal(18,12)) AS SurgeryWeight,
							CAST(NULL AS decimal(18,12)) AS TotalWeight,
							CAST(NULL AS decimal(18,12)) AS Variance
					INTO	#Weights
					FROM	#PCR_Base AS B
							LEFT OUTER JOIN #PCR_EntityHCC AS EH
									ON B.DSEntityID = EH.DSEntityID
							LEFT OUTER JOIN Ncqa.PCR_ClinicalConditionWeights AS CCW
									ON EH.HClinCond = CCW.ClinCond AND
										B.BitProductLines & CCW.BitProductLines > 0 AND
										CCW.MeasureSetID = @MeasureSetID AND
										CCW.EvalTypeID = 2 AND
										B.Age BETWEEN CCW.FromAge AND CCW.ToAge
					GROUP BY B.Age, B.BitProductLines, B.DSEntityID, B.DSMemberID, B.Gender, B.HasSurgery, B.ProductLineID,
							B.ResultRowGuid, B.ResultRowID
					ORDER BY DSEntityID, ProductLineID

					CREATE UNIQUE CLUSTERED INDEX IX_#Weights ON #Weights (DSEntityID, ProductLineID);

					UPDATE	W
					SET		BaseWeight = PLW.BaseWeight,
							SurgeryWeight = CASE WHEN W.HasSurgery = 1 THEN PLW.SurgeryWeight ELSE 0 END
					FROM	#Weights AS W
							INNER JOIN NCQA.PCR_ProductLineWeights AS PLW
									ON W.BitProductLines & PLW.BitProductLines > 0 AND
										PLW.MeasureSetID = @MeasureSetID AND
										PLW.EvalTypeID = 1 AND
										W.Age BETWEEN PLW.FromAge AND PLW.ToAge;

					UPDATE	W
					SET		DccWeight1 = ISNULL(CCW.[Weight], 0)
					FROM	#Weights AS W
							INNER JOIN #PCR_DCC AS DCC
									ON W.DSEntityID = DCC.DSEntityID	
							INNER JOIN Ncqa.PCR_ClinicalConditions AS CC
									ON DCC.ClinCondID1 = CC.ClinCondID
							INNER JOIN Ncqa.PCR_ClinicalConditionWeights AS CCW
									ON CC.ClinCond = CCW.ClinCond AND
										CC.EvalTypeID = CCW.EvalTypeID AND				
										CC.MeasureSetID = CCW.MeasureSetID AND
										W.BitProductLines & CCW.BitProductLines > 0 AND
										CCW.MeasureSetID = @MeasureSetID AND
										CCW.EvalTypeID = 1 AND
										W.Age BETWEEN CCW.FromAge AND CCW.ToAge;
				
					UPDATE	W
					SET		DccWeight2 = ISNULL(CCW.[Weight], 0)
					FROM	#Weights AS W
							INNER JOIN #PCR_DCC AS DCC
									ON W.DSEntityID = DCC.DSEntityID	
							INNER JOIN Ncqa.PCR_ClinicalConditions AS CC
									ON DCC.ClinCondID2 = CC.ClinCondID
							INNER JOIN Ncqa.PCR_ClinicalConditionWeights AS CCW
									ON CC.ClinCond = CCW.ClinCond AND
										CC.EvalTypeID = CCW.EvalTypeID AND				
										CC.MeasureSetID = CCW.MeasureSetID AND
										W.BitProductLines & CCW.BitProductLines > 0 AND
										CCW.MeasureSetID = @MeasureSetID AND
										CCW.EvalTypeID = 1 AND
										W.Age BETWEEN CCW.FromAge AND CCW.ToAge;

					UPDATE	W
					SET		DccWeight3 = ISNULL(CCW.[Weight], 0)
					FROM	#Weights AS W
							INNER JOIN #PCR_DCC AS DCC
									ON W.DSEntityID = DCC.DSEntityID	
							INNER JOIN Ncqa.PCR_ClinicalConditions AS CC
									ON DCC.ClinCondID3 = CC.ClinCondID
							INNER JOIN Ncqa.PCR_ClinicalConditionWeights AS CCW
									ON CC.ClinCond = CCW.ClinCond AND
										CC.EvalTypeID = CCW.EvalTypeID AND				
										CC.MeasureSetID = CCW.MeasureSetID AND
										W.BitProductLines & CCW.BitProductLines > 0 AND
										CCW.MeasureSetID = @MeasureSetID AND
										CCW.EvalTypeID = 1 AND
										W.Age BETWEEN CCW.FromAge AND CCW.ToAge;

					UPDATE	W
					SET		DccWeight4 = ISNULL(CCW.[Weight], 0)
					FROM	#Weights AS W
							INNER JOIN #PCR_DCC AS DCC
									ON W.DSEntityID = DCC.DSEntityID	
							INNER JOIN Ncqa.PCR_ClinicalConditions AS CC
									ON DCC.ClinCondID4 = CC.ClinCondID
							INNER JOIN Ncqa.PCR_ClinicalConditionWeights AS CCW
									ON CC.ClinCond = CCW.ClinCond AND
										CC.EvalTypeID = CCW.EvalTypeID AND				
										CC.MeasureSetID = CCW.MeasureSetID AND
										W.BitProductLines & CCW.BitProductLines > 0 AND
										CCW.MeasureSetID = @MeasureSetID AND
										CCW.EvalTypeID = 1 AND
										W.Age BETWEEN CCW.FromAge AND CCW.ToAge;

					UPDATE	W
					SET		DemoWeight = DW.[Weight]
					FROM	#Weights AS W
							INNER JOIN NCQA.PCR_DemographicWeights AS DW
									ON W.Age BETWEEN DW.FromAge AND DW.ToAge AND
										W.Gender = DW.Gender AND
										W.BitProductLines & DW.BitProductLines > 0 AND
										DW.MeasureSetID = @MeasureSetID AND
										DW.EvalTypeID = 1 AND
										W.Age BETWEEN DW.FromAge AND DW.ToAge;


					UPDATE	#Weights
					SET		@DccWeight = DccWeight = DccWeight1 + DccWeight2 + DccWeight3 + DccWeight4,
							AdjProbability = ((exp(BaseWeight + DemoWeight + @DccWeight + HClinCondWeight + SurgeryWeight)) / (1 + exp(BaseWeight + DemoWeight + @DccWeight + HClinCondWeight + SurgeryWeight))),
							TotalWeight = BaseWeight + DemoWeight + @DccWeight + HClinCondWeight + SurgeryWeight;
					
					UPDATE	#Weights
					SET		Variance = [AdjProbability] * (1 - [AdjProbability]);
			
					--Step #9a, Record the results in Measure Detail
					UPDATE	RMD
					SET		ClinCondID = ISNULL(DCC.ClinCondID, 0),
							[Weight] = W.HClinCondWeight
					FROM	Result.MeasureDetail AS RMD
							INNER JOIN #Weights AS W
									ON RMD.DSEntityID = W.DSEntityID AND
										RMD.ResultRowID = W.ResultRowID
							LEFT OUTER JOIN #PCR_DCC AS DCC
									ON W.DSEntityID = DCC.DSEntityID
					WHERE	(RMD.BatchID = @BatchID) AND
							(RMD.MetricID = @MetricID);					

					--Step #9b, Record the results in PCR-Specific Measure DEtail
					DELETE FROM Result.MeasureDetail_PCR WHERE BatchID = @BatchID;

					INSERT INTO	Result.MeasureDetail_PCR
							(AdjProbability, Age, BaseWeight, BatchID, ClinCondID, 
							ClinCondID1, ClinCondID2, ClinCondID3, ClinCondID4,
							DataRunID, DataSetID, DccWeight, DccWeight1, DccWeight2, 
							DccWeight3, DccWeight4,	DemoWeight, DSEntityID,
							DSMemberID, Gender, HClinCondWeight, OwnerID, ProductLineID,
							SourceRowGuid, SourceRowID, SurgeryWeight, TotalWeight, Variance)
					SELECT	W.AdjProbability,
							W.Age,
							W.BaseWeight,
							@BatchID AS BatchID,
							DCC.ClinCondID,
							DCC.ClinCondID1,
							DCC.ClinCondID2,
							DCC.ClinCondID3,
							DCC.ClinCondID4,
							@DataRunID AS DataRunID,
							@DataSetID AS DataSetID,
							W.DccWeight,
							W.DccWeight1,
							W.DccWeight2,
							W.DccWeight3,
							W.DccWeight4,
							W.DemoWeight,
							W.DSEntityID,
							W.DSMemberID,
							W.Gender, 
							W.HClinCondWeight,
							@OwnerID AS OwnerID,
							W.ProductLineID,
							W.ResultRowGuid AS SourceRowGuid,
							W.ResultRowID AS SourceRowID,
							W.SurgeryWeight,
							W.TotalWeight,
							W.Variance
					FROM	#Weights AS W
							LEFT OUTER JOIN #PCR_DCC AS DCC
									ON W.DSEntityID = DCC.DSEntityID
					ORDER BY DSEntityID, ProductLineID;

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

					--Step #10, Log "HCCs"
					DELETE FROM [Log].PCR_ClinicalConditions WHERE BatchID = @BatchID AND MeasureID = @MeasureID;

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
							@MeasureID AS MeasureID,
							@OwnerID AS OwnerID
					FROM	#PCR_EntityHCC AS t
							INNER JOIN Proxy.Entities AS TE
									ON t.DSEntityID = TE.DSEntityID
							LEFT OUTER JOIN Proxy.ClaimCodes AS TCC
									ON t.DSClaimCodeID = TCC.DSClaimCodeID 
					ORDER BY DSEntityID, DSClaimCodeID, HClinCond;
			
					--This is a safety clean-up for client data, this statement should not actually need to run.
					UPDATE	RMD
					SET		IsDenominator = 0,
							IsIndicator = 0, 
							IsNumerator = 0
					FROM	Result.MeasureDetail AS RMD
							LEFT OUTER JOIN #Weights AS W
									ON RMD.DSEntityID = W.DSEntityID AND
										RMD.ResultRowID = W.ResultRowID
					WHERE	(RMD.BatchID = @BatchID) AND
							(RMD.MetricID = @MetricID) AND	
							(W.ResultRowID IS NULL) AND
							(RMD.BitProductLines > 0);
				END;
				ELSE
					SET @CountRecords = ISNULL(@CountRecords, 0);

			SET @LogDescr = ' - Calculating PCR measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' succeeded.'; 
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
			SET @LogDescr = ' - Calculating PCR measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' failed!'; 
			
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
