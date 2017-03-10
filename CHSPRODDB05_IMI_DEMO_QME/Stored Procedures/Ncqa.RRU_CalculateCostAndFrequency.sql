SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/20/2014
-- Description:	Calculates the cost and frequency portions of the RRU measures.
-- =============================================
CREATE PROCEDURE [Ncqa].[RRU_CalculateCostAndFrequency]
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
		SET @LogObjectName = 'RRU_CalculateCostAndFrequency'; 
		SET @LogObjectSchema = 'Ncqa'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
						
			IF EXISTS (SELECT TOP 1 1 FROM Result.MeasureDetail_RRU WHERE BatchID = @BatchID)
				BEGIN;

					-----------------------------------------------------------------------------------------------------------
					--Retrieve Claim Types... 
					DECLARE @ClaimTypeE tinyint;
					DECLARE @ClaimTypeL tinyint;
					DECLARE @ClaimTypeP tinyint;

					SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
					SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';
					SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';

					--Retrieve Code Types...
					DECLARE @CodeType1 tinyint;
					DECLARE @CodeType2 tinyint;
					DECLARE @CodeType0 tinyint;
					DECLARE @CodeTypeR tinyint;
					DECLARE @CodeTypeB tinyint;
					DECLARE @CodeTypeD tinyint;
					DECLARE @CodeTypeI tinyint;
					DECLARE @CodeTypeP tinyint;
					DECLARE @CodeTypeC tinyint;
					DECLARE @CodeTypeM tinyint;
					DECLARE @CodeTypeH tinyint;
					DECLARE @CodeTypeS tinyint;
					DECLARE @CodeTypeX tinyint;
					DECLARE @CodeTypeN tinyint;
					DECLARE @CodeTypeL tinyint;
		
					SELECT @CodeType1 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '1';
					SELECT @CodeType2 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '2';
					SELECT @CodeType0 = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '0';
					SELECT @CodeTypeR = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'R';
					SELECT @CodeTypeB = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'B';
					SELECT @CodeTypeD = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'D';
					SELECT @CodeTypeI = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'I';
					SELECT @CodeTypeP = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'P';
					SELECT @CodeTypeC = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'C';
					SELECT @CodeTypeM = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'M';
					SELECT @CodeTypeH = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'H';
					SELECT @CodeTypeS = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'S';
					SELECT @CodeTypeX = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'X';
					SELECT @CodeTypeN = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'N';
					SELECT @CodeTypeL = CodeTypeID FROM Claim.CodeTypes WHERE CodeType = 'L';
			
					--Retrieve Claim Attributes... 
					DECLARE @ClaimAttribIN bigint;
					DECLARE @ClaimAttribAIN bigint;
					DECLARE @ClaimAttribNIN bigint;
					DECLARE @ClaimAttribED bigint;
					DECLARE @ClaimAttribOUT bigint;

					SELECT @ClaimAttribIN = BitValue FROM Claim.Attributes WHERE Abbrev = 'IN';
					SELECT @ClaimAttribAIN = BitValue FROM Claim.Attributes WHERE Abbrev = 'AIN';
					SELECT @ClaimAttribNIN = BitValue FROM Claim.Attributes WHERE Abbrev = 'NIN';
					SELECT @ClaimAttribED = BitValue FROM Claim.Attributes WHERE Abbrev = 'ED';
					SELECT @ClaimAttribOUT = BitValue FROM Claim.Attributes WHERE Abbrev = 'OUT';

					DECLARE @ClaimAttribID_IN bigint;
					DECLARE @ClaimAttribID_ED bigint;

					SELECT @ClaimAttribID_IN = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'IN';
					SELECT @ClaimAttribID_ED = ClaimAttribID FROM Claim.Attributes WHERE Abbrev = 'ED';

					--Retrieve Provider Specialties...
					DECLARE @SpecialtyAnesth bigint;
					SELECT @SpecialtyAnesth = BitValue FROM Provider.Specialties WHERE Abbrev = 'Anesth';

					--Retreive Measure Classes...
					DECLARE @MeasClassRRU smallint;
					SELECT @MeasClassRRU = MeasClassID FROM Measure.MeasureClasses WHERE Abbrev = 'RRU';

					--Retrieve Benefits...
					DECLARE @BenefitDrug bigint;
					DECLARE @BenefitMed bigint;

					SELECT @BenefitDrug = BitValue FROM Product.Benefits WHERE Abbrev = 'Drug';
					SELECT @BenefitMed = BitValue FROM Product.Benefits WHERE Abbrev = 'Med';

					--Retrieve Scoring Types...
					DECLARE @ScoreTypeC smallint;
					SELECT @ScoreTypeC = ScoreTypeID FROM Measure.ScoreTypes WHERE Abbrev = 'C';

					--Retrieve RRU Pricing Categories...
					DECLARE @PriceCtgyPharm tinyint;
					DECLARE @PriceCtgyEM tinyint;
					DECLARE @PriceCtgyProc tinyint;
					DECLARE @PriceCtgyLab tinyint;
					DECLARE @PriceCtgyImg tinyint;
					DECLARE @PriceCtgyN1 tinyint;
					DECLARE @PriceCtgyN2 tinyint;
					DECLARE @PriceCtgyG1 tinyint;
					DECLARE @PriceCtgyG2 tinyint;
					DECLARE @PriceCtgyIEM tinyint;
					DECLARE @PriceCtgyOEM tinyint;
					DECLARE @PriceCtgyIProc tinyint;
					DECLARE @PriceCtgyOProc tinyint;

					SELECT @PriceCtgyPharm = PriceCtgyID FROM [Ncqa].[RRU_PriceCategories] WHERE (Abbrev = 'Pharm');
					SELECT @PriceCtgyEM = PriceCtgyID FROM [Ncqa].[RRU_PriceCategories] WHERE (Abbrev = 'EM');
					SELECT @PriceCtgyProc = PriceCtgyID FROM [Ncqa].[RRU_PriceCategories] WHERE (Abbrev = 'Proc');
					SELECT @PriceCtgyLab = PriceCtgyID FROM [Ncqa].[RRU_PriceCategories] WHERE (Abbrev = 'Lab');
					SELECT @PriceCtgyImg = PriceCtgyID FROM [Ncqa].[RRU_PriceCategories] WHERE (Abbrev = 'Img');
					SELECT @PriceCtgyN1 = PriceCtgyID FROM [Ncqa].[RRU_PriceCategories] WHERE (Abbrev = 'N1');
					SELECT @PriceCtgyN2 = PriceCtgyID FROM [Ncqa].[RRU_PriceCategories] WHERE (Abbrev = 'N2');
					SELECT @PriceCtgyG1 = PriceCtgyID FROM [Ncqa].[RRU_PriceCategories] WHERE (Abbrev = 'G1');
					SELECT @PriceCtgyG2 = PriceCtgyID FROM [Ncqa].[RRU_PriceCategories] WHERE (Abbrev = 'G2');
					SELECT @PriceCtgyIEM = PriceCtgyID FROM [Ncqa].[RRU_PriceCategories] WHERE (Abbrev = 'IEM');
					SELECT @PriceCtgyOEM = PriceCtgyID FROM [Ncqa].[RRU_PriceCategories] WHERE (Abbrev = 'OEM');
					SELECT @PriceCtgyIProc = PriceCtgyID FROM [Ncqa].[RRU_PriceCategories] WHERE (Abbrev = 'IProc');
					SELECT @PriceCtgyOProc = PriceCtgyID FROM [Ncqa].[RRU_PriceCategories] WHERE (Abbrev = 'OProc');

					--Retrieve MISA Default ADSC...
					DECLARE @ADSC_MISA smallint;
					SELECT @ADSC_MISA = ADSCID FROM Ncqa.RRU_ADSC WHERE Abbrev = 'MISA';

					--Retrieve RRU Value Types...
					DECLARE @RRUValTypeCostEMInpatient tinyint;
					DECLARE @RRUValTypeCostEMOutpatient tinyint;
					DECLARE @RRUValTypeCostImaging tinyint;
					DECLARE @RRUValTypeCostInpatient tinyint;
					DECLARE @RRUValTypeCostLab tinyint;
					DECLARE @RRUValTypeCostPharmacy tinyint;
					DECLARE @RRUValTypeCostProcInpatient tinyint;
					DECLARE @RRUValTypeCostProcOutpatient tinyint;
					DECLARE @RRUValTypeDaysAcuteInpatient tinyint;
					DECLARE @RRUValTypeDaysAcuteInpatientNotSurg tinyint;
					DECLARE @RRUValTypeDaysAcuteInpatientSurg tinyint;
					DECLARE @RRUValTypeDaysNonacuteInpatient tinyint;
					DECLARE @RRUValTypeFreqAcuteInpatient tinyint;
					DECLARE @RRUValTypeFreqAcuteInpatientNotSurg tinyint;
					DECLARE @RRUValTypeFreqAcuteInpatientSurg tinyint;
					DECLARE @RRUValTypeFreqED tinyint;
					DECLARE @RRUValTypeFreqNonacuteInpatient tinyint;
					DECLARE @RRUValTypeFreqPharmG1 tinyint;
					DECLARE @RRUValTypeFreqPharmG2 tinyint;
					DECLARE @RRUValTypeFreqPharmN1 tinyint;
					DECLARE @RRUValTypeFreqPharmN2 tinyint;
					DECLARE @RRUValTypeFreqProcCABG tinyint;
					DECLARE @RRUValTypeFreqProcCAD tinyint;
					DECLARE @RRUValTypeFreqProcCardiacCath tinyint;
					DECLARE @RRUValTypeFreqProcCAS tinyint;
					DECLARE @RRUValTypeFreqProcCAT tinyint;
					DECLARE @RRUValTypeFreqProcEndarter tinyint;
					DECLARE @RRUValTypeFreqProcPCI tinyint;

					SELECT @RRUValTypeCostEMInpatient = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'CostEMInpatient');
					SELECT @RRUValTypeCostEMOutpatient = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'CostEMOutpatient');
					SELECT @RRUValTypeCostImaging = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'CostImaging');
					SELECT @RRUValTypeCostInpatient = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'CostInpatient');
					SELECT @RRUValTypeCostLab = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'CostLab');
					SELECT @RRUValTypeCostPharmacy = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'CostPharmacy');
					SELECT @RRUValTypeCostProcInpatient = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'CostProcInpatient');
					SELECT @RRUValTypeCostProcOutpatient = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'CostProcOutpatient');
					SELECT @RRUValTypeDaysAcuteInpatient = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'DaysAcuteInpatient');
					SELECT @RRUValTypeDaysAcuteInpatientNotSurg = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'DaysAcuteInpatientNotSurg');
					SELECT @RRUValTypeDaysAcuteInpatientSurg = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'DaysAcuteInpatientSurg');
					SELECT @RRUValTypeDaysNonacuteInpatient = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'DaysNonacuteInpatient');
					SELECT @RRUValTypeFreqAcuteInpatient = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqAcuteInpatient');
					SELECT @RRUValTypeFreqAcuteInpatientNotSurg = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqAcuteInpatientNotSurg');
					SELECT @RRUValTypeFreqAcuteInpatientSurg = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqAcuteInpatientSurg');
					SELECT @RRUValTypeFreqED = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqED');
					SELECT @RRUValTypeFreqNonacuteInpatient = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqNonacuteInpatient');
					SELECT @RRUValTypeFreqPharmG1 = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqPharmG1');
					SELECT @RRUValTypeFreqPharmG2 = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqPharmG2');
					SELECT @RRUValTypeFreqPharmN1 = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqPharmN1');
					SELECT @RRUValTypeFreqPharmN2 = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqPharmN2');
					SELECT @RRUValTypeFreqProcCABG = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqProcCABG');
					SELECT @RRUValTypeFreqProcCAD = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqProcCAD');
					SELECT @RRUValTypeFreqProcCardiacCath = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqProcCardiacCath');
					SELECT @RRUValTypeFreqProcCAS = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqProcCAS');
					SELECT @RRUValTypeFreqProcCAT = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqProcCAT');
					SELECT @RRUValTypeFreqProcEndarter = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqProcEndarter');
					SELECT @RRUValTypeFreqProcPCI = RRUValTypeID FROM [Ncqa].[RRU_ValueTypes] WHERE (ColumnName = 'FreqProcPCI');
					-----------------------------------------------------------------------------------------------------------
					
					--1) Build base-level tables...
					--1a) Select list of members to calculate...
					SELECT DISTINCT
							DSMemberID	
					INTO	#RRU_Base                  
					FROM	Result.MeasureDetail_RRU
					WHERE	(BatchID = @BatchID) AND
							(DataRunID = @DataRunID) AND
							(DataSetID = @DataSetID);

					CREATE UNIQUE CLUSTERED INDEX IX_#RRU_Base ON #RRU_Base (DSMemberID);

					--1b) Select relevant claim source for the members...
					SELECT	PCS.BeginDate,
					        PCS.BitClaimAttribs,
							CONVERT(bigint, 0) AS BitClaimAttribsByLine,
					        PCS.BitClaimSrcTypes,
					        PCS.BitSpecialties,
					        PCS.ClaimBeginDate,
					        PCS.ClaimCompareDate,
					        PCS.ClaimEndDate,
					        PCS.ClaimTypeID,
					        PCS.Code,
					        PCS.CodeID,
					        PCS.CodeTypeID,
					        PCS.CompareDate,
					        PCS.DataSourceID,
					        PCS.[Days],
							PCS.DaysPaid,
					        PCS.DOB,
					        PCS.DSClaimCodeID,
					        PCS.DSClaimID,
					        PCS.DSClaimLineID,
					        PCS.DSMemberID,
					        PCS.DSProviderID,
					        PCS.EndDate,
					        PCS.Gender,
					        PCS.IsEnrolled,
					        PCS.IsLab,
					        PCS.IsOnly,
					        --PCS.IsPaid,
					        PCS.IsPositive,
					        PCS.IsPrimary,
					        PCS.LabValue,
					        PCS.Qty,
					        PCS.QtyDispensed,
					        PCS.ServDate
					INTO	#ClaimSource
					FROM	Proxy.ClaimSource AS PCS WITH(NOLOCK)
							INNER JOIN #RRU_Base AS B
									ON PCS.DSMemberID = B.DSMemberID AND
										(
											(PCS.BeginDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) OR 
											(PCS.ClaimBeginDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) OR
											(PCS.ClaimCompareDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) OR                                          
											(PCS.ClaimEndDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) OR
											(PCS.CompareDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) OR                                          
											(PCS.EndDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate)                                        
										)
					WHERE	(PCS.IsPaid = 1) AND
							(PCS.IsSupplemental = 0) AND
							(PCS.ClaimTypeID IN (@ClaimTypeE, @ClaimTypeP));    
								
					CREATE UNIQUE CLUSTERED INDEX IX_#ClaimSource ON #ClaimSource (DSClaimCodeID);
					CREATE NONCLUSTERED INDEX IX_#ClaimSource_CodeID ON #ClaimSource (CodeID) INCLUDE (BeginDate, Code, CodeTypeID, DSClaimID, DSClaimLineID, EndDate);
					CREATE NONCLUSTERED INDEX IX_#ClaimSource_Dates ON #ClaimSource (BeginDate, EndDate) INCLUDE (BitClaimAttribs, BitSpecialties, DSClaimLineID);
					CREATE NONCLUSTERED INDEX IX_#ClaimSource_DSClaimID ON #ClaimSource (ClaimTypeID, DSClaimID) INCLUDE (BeginDate, BitClaimAttribs, Code, CodeID, CodeTypeID, DSMemberID, EndDate);
					CREATE NONCLUSTERED INDEX IX_#ClaimSource_DSClaimLineID ON #ClaimSource (DSClaimLineID) INCLUDE (BeginDate, Code, CodeID, CodeTypeID, DSClaimID, DSMemberID, EndDate);   			                  

					--1c) Determine primary diagnosis for inpatient claims...
					SELECT SUM(DISTINCT CA.BitValue) AS BitClaimAttribs, DSClaimLineID INTO #InpatientClaimLines FROM Proxy.ClaimAttributes AS PCA INNER JOIN Claim.Attributes AS CA ON PCA.ClaimAttribID = CA.ClaimAttribID GROUP BY DSClaimLineID;
					CREATE UNIQUE CLUSTERED INDEX IX_#InpatientClaimLines ON #InpatientClaimLines (DSClaimLineID);

					UPDATE	CS
					SET		BitClaimAttribsByLine = ICL.BitClaimAttribs
					FROM	#ClaimSource AS CS
							INNER JOIN #InpatientClaimLines AS ICL
									ON CS.DSClaimLineID = ICL.DSClaimLineID;                  

					SELECT	CS.CodeID,
							COUNT(DISTINCT CS.DSClaimCodeID) AS CountCodes,
							CS.DSClaimID
					INTO	#InpatientClaimsPrimaryDiags
					FROM	#ClaimSource AS CS
					WHERE	(CS.CodeTypeID IN (@CodeTypeD, @CodeTypeI)) AND
							(CS.IsPrimary = 1) AND
							(@ClaimAttribAIN | @ClaimAttribIN | @ClaimAttribNIN & CS.BitClaimAttribsByLine > 0)                        
					GROUP BY CS.CodeID, 
							CS.DSClaimID;

					--DELETE FROM #InpatientClaimsPrimaryDiags WHERE (CountCodes = 1);
					CREATE UNIQUE CLUSTERED INDEX IX_#InpatientClaimsPrimaryDiags ON #InpatientClaimsPrimaryDiags (DSClaimID, CodeID);

					SELECT MAX(CountCodes) AS CountCodes, DSClaimID INTO #InpatientClaimsPrimaryDiagsMaxCnt FROM #InpatientClaimsPrimaryDiags GROUP BY DSClaimID;
					CREATE UNIQUE CLUSTERED INDEX IX_#InpatientClaimsPrimaryDiagsMaxCnt ON #InpatientClaimsPrimaryDiagsMaxCnt (DSClaimID);

					DELETE ICPD FROM #InpatientClaimsPrimaryDiags AS ICPD INNER JOIN #InpatientClaimsPrimaryDiagsMaxCnt AS ICPDMC ON ICPD.DSClaimID = ICPDMC.DSClaimID WHERE (ICPD.CountCodes < ICPDMC.CountCodes);
					DELETE FROM #InpatientClaimsPrimaryDiags WHERE (DSClaimID IN (SELECT DSClaimID FROM #InpatientClaimsPrimaryDiags GROUP BY DSClaimID HAVING (COUNT(DISTINCT CodeID) > 1)));
					ALTER INDEX ALL ON #InpatientClaimsPrimaryDiags REBUILD;

					DROP TABLE #InpatientClaimsPrimaryDiagsMaxCnt;

					--1d) Summarize claim source (claim lines/codes) into claims...
					SELECT	@ADSC_MISA AS ADSCID,
							CS.BitClaimAttribs, 
							COALESCE(MIN(CASE WHEN @ClaimAttribAIN | @ClaimAttribIN | @ClaimAttribNIN & CS.BitClaimAttribsByLine ^ @ClaimAttribED > 0 THEN CS.BeginDate END), 
									MIN(CASE WHEN @ClaimAttribAIN | @ClaimAttribIN | @ClaimAttribNIN & CS.BitClaimAttribsByLine > 0 THEN CS.BeginDate END), 
									MIN(CS.ClaimBeginDate)) AS ClaimBeginDate, 
							COALESCE(MAX(CASE WHEN @ClaimAttribAIN | @ClaimAttribIN | @ClaimAttribNIN & CS.BitClaimAttribsByLine > 0 THEN CS.ClaimEndDate END), 
									MAX(CS.ClaimEndDate)) AS ClaimEndDate, 
							CASE WHEN COUNT(DISTINCT CASE WHEN CS.IsPrimary = 1 AND CS.CodeTypeID IN (@CodeTypeD, @CodeTypeI) THEN CS.CodeID END) = 1 
								THEN MIN(CASE WHEN CS.IsPrimary = 1 AND CS.CodeTypeID IN (@CodeTypeD, @CodeTypeI) THEN CS.CodeID END)
								END AS CodeID,  --Primary ICD9 Diagnosis
							MAX(CS.[Days]) AS DaysCalc,
							MAX(CS.[Days]) AS DaysMax,
							MIN(CS.[Days]) AS DaysMin,
							SUM(CS.[Days]) AS DaysSum,
							MAX(CS.DaysPaid) AS DaysPaidCalc,
							MAX(CS.DaysPaid) AS DaysPaidMax,
							MIN(CS.DaysPaid) AS DaysPaidMin,
							SUM(CS.DaysPaid) AS DaysPaidSum,
							CS.DSClaimID, 
							MIN(CS.DSClaimLineID) AS DSClaimLineID,
							CS.DSMemberID,
							CONVERT(bit, CASE WHEN @ClaimAttribIN | @ClaimAttribAIN | @ClaimAttribNIN & CS.BitClaimAttribs > 0 AND
												@ClaimAttribNIN & BitClaimAttribs = 0
											THEN 1
											ELSE 0
											END) AS IsAcute,                          
							CONVERT(bit, CASE WHEN @ClaimAttribIN | @ClaimAttribAIN | @ClaimAttribNIN & CS.BitClaimAttribs = 0 AND
												@ClaimAttribED & BitClaimAttribs > 0
											THEN 1
											ELSE 0 
											END) AS IsED,                   
							CONVERT(bit, CASE WHEN @ClaimAttribIN | @ClaimAttribAIN | @ClaimAttribNIN & CS.BitClaimAttribs > 0 
											THEN 1
											ELSE 0 
											END) AS IsInpatient,
							CONVERT(bit, MAX(CASE WHEN MS.RRUMajSurgID IS NOT NULL THEN 1 ELSE 0 END)) AS IsMajSurg,
							CONVERT(int, 0) AS [PriceDays]
					INTO	#Claims 
					FROM	#ClaimSource AS CS
							LEFT OUTER JOIN Ncqa.RRU_MajorSurgery AS MS
									ON CS.CodeID = MS.CodeID AND
										MS.MeasureSetID = @MeasureSetID                                  
					WHERE	(CS.ClaimTypeID = @ClaimTypeE) 
					GROUP BY CS.BitClaimAttribs, CS.DSClaimID, CS.DSMemberID;

					CREATE UNIQUE CLUSTERED INDEX IX_#Claims ON #Claims (DSClaimID);
					CREATE NONCLUSTERED INDEX IX_#Claims_CodeID ON #Claims (CodeID);
					CREATE NONCLUSTERED INDEX IX_#Claims_ClaimBeginDate ON #Claims (ClaimBeginDate, ClaimEndDate) INCLUDE (IsAcute, IsED, IsInpatient);
					CREATE NONCLUSTERED INDEX IX_#Claims_DSMemberID ON #Claims (DSMemberID, ClaimBeginDate, ClaimEndDate) INCLUDE (IsAcute, IsED, IsInpatient);

					UPDATE	C
					SET		CodeID = ICPD.CodeID
					FROM	#Claims AS C
							INNER JOIN #InpatientClaimsPrimaryDiags AS ICPD
									ON C.DSClaimID = ICPD.DSClaimID;

					DROP TABLE #InpatientClaimLines;
					DROP TABLE #InpatientClaimsPrimaryDiags;

					UPDATE	C
					SET		ADSCID = A.ADSCID
					FROM	#Claims AS C
							INNER JOIN Ncqa.RRU_ADSCCodes AS A
									ON C.CodeID = A.CodeID AND
										A.MeasureSetID = @MeasureSetID;                

					UPDATE	#Claims
					SET		PriceDays = DaysPaidCalc +
										CASE 
											WHEN ClaimBeginDate < @BeginInitSeedDate AND DATEADD(dd, DaysPaidCalc - 1, ClaimBeginDate) > @BeginInitSeedDate  
											THEN DATEDIFF(dd, DATEADD(dd, DaysPaidCalc - 1, ClaimBeginDate), @BeginInitSeedDate) * -1
											WHEN ClaimEndDate > @EndInitSeedDate AND ClaimBeginDate < @EndInitSeedDate AND DATEADD(dd, DaysPaidCalc - 1, ClaimBeginDate) > @EndInitSeedDate
											THEN DATEDIFF(dd, DATEADD(dd, DaysPaidCalc - 1, ClaimBeginDate), @EndInitSeedDate)
											ELSE 0
											END
					WHERE	IsInpatient = 1;        

					--1e) Identify CPT modifiers by claim line...
					SELECT DISTINCT                  
							DSClaimLineID,
							Code AS Modifier
					INTO	#ClaimCptModifiers               
					FROM    #ClaimSource
					WHERE	(CodeTypeID = @CodeType0);
					
					CREATE UNIQUE CLUSTERED INDEX IX_#ClaimCptModifiers ON #ClaimCptModifiers (DSClaimLineID, Modifier);  
					
					--1f) Identify member months
					SELECT	RMMD.DSMemberID,
							SUM(CASE WHEN RMMD.BitBenefits & @BenefitMed > 0 THEN RMMD.CountMonths ELSE 0 END) AS MM,
							SUM(CASE WHEN RMMD.BitBenefits & @BenefitDrug > 0 THEN RMMD.CountMonths ELSE 0 END) AS MMP
					INTO	#MemberMonths
					FROM	Result.MemberMonthDetail AS RMMD
							INNER JOIN #RRU_Base AS B
									ON RMMD.DSMemberID = B.DSMemberID
					WHERE	RMMD.BatchID = @BatchID AND
							RMMD.DataRunID = @DataRunID AND
							RMMD.DataSetID = @DataSetID                  
					GROUP BY RMMD.DSMemberID;

					--2) Calculate cost, ALOS, and frequency for RRU measures...
					--Define #RRU_Services temp table...
					CREATE TABLE #RRU_Services
					(
						ADSCID smallint NULL,
						BeginDate datetime NOT NULL,
						CodeID int NULL,
						[Days] int NULL,
						DSClaimCodeID bigint NULL,
						DSClaimLineID bigint NULL,
						DSEntityID bigint NULL,
						DSMemberID bigint NULL,
						EndDate datetime NULL,
						ID int IDENTITY(1,1) NOT NULL,
						OptionNbr tinyint NOT NULL,
						PriceCtgyCodeID int NULL,
						PriceCtgyID tinyint NULL,
						Price decimal(18, 4) NULL,
						RRUValTypeID tinyint NOT NULL,
						Qty decimal(18, 4) NULL,
						Value decimal(18, 4) NULL
					);           

					CREATE UNIQUE CLUSTERED INDEX PK_#RRU_Services ON #RRU_Services (ID);
					
					SELECT	C.ADSCID,
					        C.ClaimBeginDate AS BeginDate,
					        C.CodeID,
					        DaysPaidCalc AS [Days],
					        C.DSClaimLineID,
					        C.DSMemberID,
					        C.ClaimEndDate AS EndDate,
					        1 AS OptionNbr,
					        CONVERT(decimal(18, 4), C.PriceDays * NRAP.Price) AS Price,
					        CASE WHEN C.IsAcute = 0 
								THEN @RRUValTypeFreqNonacuteInpatient
								WHEN C.IsMajSurg = 1
								THEN @RRUValTypeFreqAcuteInpatientSurg
								ELSE @RRUValTypeFreqAcuteInpatientNotSurg
								END AS RRUValTypeID1,
							CASE WHEN C.IsAcute = 0 
								THEN @RRUValTypeDaysNonacuteInpatient
								WHEN C.IsMajSurg = 1
								THEN @RRUValTypeDaysAcuteInpatientSurg
								ELSE @RRUValTypeDaysAcuteInpatientNotSurg
								END AS RRUValTypeID2,
							@RRUValTypeCostInpatient AS RRUValTypeID3,
					        C.PriceDays AS Qty,
					        CONVERT(decimal(18, 4), 1) AS Value1,
							CONVERT(decimal(18, 4), C.DaysPaidCalc) AS Value2,
							CONVERT(decimal(18, 4), C.PriceDays * NRAP.Price) AS Value3
					INTO	#InpatientServices
					FROM	#Claims AS C
							LEFT OUTER JOIN Ncqa.RRU_LosGroups AS LOS
									ON C.DaysPaidCalc BETWEEN LOS.FromDays AND LOS.ToDays
							LEFT OUTER JOIN Ncqa.RRU_ADSCPrices AS NRAP
									ON C.ADSCID = NRAP.ADSCID AND
										C.IsAcute = NRAP.IsAcute AND
										C.IsMajSurg = NRAP.IsMajSurg AND
										LOS.LosGroupID = NRAP.LosGroupID AND
										NRAP.MeasureSetID = @MeasureSetID
					WHERE	(C.IsInpatient = 1) AND 
							(DaysCalc > 0);      
							                 
					INSERT INTO #RRU_Services
							(ADSCID,
					        BeginDate,
					        CodeID,
					        [Days],
					        DSClaimLineID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
					        Price,
					        RRUValTypeID,
					        Qty,
					        Value)
					SELECT	ADSCID,
					        BeginDate,
					        CodeID,
					        [Days],
					        DSClaimLineID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
					        Price,
					        RRUValTypeID1,
					        Qty,
					        Value1
					FROM	#InpatientServices
					UNION ALL
  					SELECT	ADSCID,
					        BeginDate,
					        CodeID,
					        [Days],
					        DSClaimLineID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
					        Price,
					        RRUValTypeID2,
					        Qty,
					        Value2
					FROM	#InpatientServices                  
					UNION ALL
  					SELECT	ADSCID,
					        BeginDate,
					        CodeID,
					        [Days],
					        DSClaimLineID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
					        Price,
					        RRUValTypeID3,
					        Qty,
					        Value3
					FROM	#InpatientServices
					ORDER BY DSMemberID, EndDate, BeginDate;
					                  
					DROP TABLE #InpatientServices;

					--2a) Identify Costs for EM... 
					SELECT * INTO #EM_Codes FROM Ncqa.RRU_PriceCategoryCodes WHERE PriceCtgyID IN (@PriceCtgyIEM, @PriceCtgyOEM) AND (MeasureSetID = @MeasureSetID);
					CREATE UNIQUE CLUSTERED INDEX IX_#EM_Codes ON #EM_Codes (CodeID);

					INSERT INTO #RRU_Services
					        (BeginDate,
					        CodeID,
					        DSClaimCodeID,
					        DSClaimLineID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
					        PriceCtgyCodeID,
					        PriceCtgyID,
					        Price,
					        RRUValTypeID,
					        Qty,
					        Value)
					SELECT	CS.BeginDate,
							Codes.CodeID,
							CS.DSClaimCodeID,
							CS.DSClaimLineID,
							CS.DSMemberID,
							CS.EndDate,
							1 AS OptionNbr,
							Codes.PriceCtgyCodeID,
							Codes.PriceCtgyID,
							CONVERT(decimal(18, 4), ISNULL(Qty, 0)) * Codes.Price1 AS Price,
							CASE Codes.PriceCtgyID WHEN @PriceCtgyIEM THEN @RRUValTypeCostEMInpatient WHEN @PriceCtgyOEM THEN @RRUValTypeCostEMOutpatient END AS RRUValTypeID,
							CS.Qty,
							CONVERT(decimal(18, 4), ISNULL(Qty, 0)) * Codes.Price1 AS [Value] 
					FROM	#EM_Codes AS Codes
							INNER JOIN #ClaimSource AS CS
									ON Codes.CodeID = CS.CodeID
					WHERE	(
								(CS.BeginDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) OR
								(CS.EndDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate)
							);

					DROP TABLE #EM_Codes;
					
					--2b) Identify Costs for Procedures/Surgeries... 				         
					SELECT * INTO #Proc_Codes FROM Ncqa.RRU_PriceCategoryCodes WHERE PriceCtgyID IN (@PriceCtgyIProc, @PriceCtgyOProc) AND (MeasureSetID = @MeasureSetID);
					SELECT DISTINCT CodeID, CodeTypeID INTO #Proc_Codes_Distinct FROM #Proc_Codes;

					CREATE UNIQUE CLUSTERED INDEX IX_#Proc_Codes ON #Proc_Codes (CodeID, PriceCtgyID, Modifier);
					CREATE UNIQUE CLUSTERED INDEX IX_#Proc_Codes_Distinct ON #Proc_Codes_Distinct (CodeID);
					
					SELECT DISTINCT
							CS.BeginDate,
							CS.CompareDate,
							Codes.CodeID,
							Codes.CodeTypeID,
							CS.DSClaimCodeID,
							CS.DSClaimLineID,
							CS.DSMemberID,
							CS.EndDate,
							IDENTITY(int, 1, 1) AS ID,
							CASE WHEN @ClaimAttribIN | @ClaimAttribAIN | @ClaimAttribNIN & BitClaimAttribs > 0  THEN @PriceCtgyIProc ELSE @PriceCtgyOProc END AS PriceCtgyID,
							Qty
					INTO	#ServiceClaimsProc
					FROM	#Proc_Codes_Distinct AS Codes
							INNER JOIN #ClaimSource AS CS
									ON Codes.CodeID = CS.CodeID
					WHERE	(CS.BitSpecialties & @SpecialtyAnesth = 0) AND
							(
								(CS.BeginDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) OR
								(CS.EndDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate)
							);

					CREATE UNIQUE CLUSTERED INDEX IX_#ServiceClaimsProc ON #ServiceClaimsProc (DSClaimLineID); 
					
					SELECT	SC2.ID
					INTO	#DeleteServicesProc
					FROM	#ServiceClaimsProc AS SC1
							INNER JOIN #ServiceClaimsProc SC2
									ON SC1.DSClaimLineID = SC2.DSClaimLineID AND
										SC1.CodeTypeID IN (@CodeType1, @CodeTypeH) AND
										SC2.CodeTypeID = @CodeTypeR;
					
					DELETE FROM #ServiceClaimsProc WHERE ID IN (SELECT ID FROM #DeleteServicesProc);

					CREATE NONCLUSTERED INDEX IX_#ServiceClaimsProc_DSMemberID ON #ServiceClaimsProc (DSMemberID, CompareDate, PriceCtgyID);     
					
					INSERT INTO #RRU_Services
					        (BeginDate,
					        CodeID,
					        DSClaimCodeID,
					        DSClaimLineID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
							PriceCtgyCodeID,
					        PriceCtgyID,
					        Price,
					        RRUValTypeID,
					        Qty,
					        Value)
					SELECT	SC.BeginDate,
					        SC.CodeID,
					        SC.DSClaimCodeID,
					        SC.DSClaimLineID,
					        SC.DSMemberID,
					        SC.EndDate,
					        CASE WHEN LC1.PriceCtgyCodeID IS NOT NULL THEN 1 ELSE 2 END AS OptionNbr,
							ISNULL(LC1.PriceCtgyCodeID, LC2.PriceCtgyCodeID) AS PriceCtgyCodeID,
					        SC.PriceCtgyID,
					        CONVERT(decimal(18, 4), ISNULL(Qty, 0)) * ISNULL(LC1.Price1, LC2.Price1) AS Price,
					        CASE WHEN SC.PriceCtgyID = @PriceCtgyIProc 
								THEN @RRUValTypeCostProcInpatient
								WHEN  SC.PriceCtgyID = @PriceCtgyOProc 
								THEN @RRUValTypeCostProcOutpatient
								END AS RRUValTypeID,
					        SC.Qty,
					        CONVERT(decimal(18, 4), ISNULL(Qty, 0)) * ISNULL(LC1.Price1, LC2.Price1) AS Value
					FROM	#ServiceClaimsProc AS SC
							LEFT OUTER JOIN #ClaimCptModifiers AS CCM
									ON SC.DSClaimLineID = CCM.DSClaimLineID AND
										EXISTS (SELECT TOP 1 1 FROM #Proc_Codes AS t WHERE t.PriceCtgyID = SC.PriceCtgyID AND t.CodeID = SC.CodeID AND t.Modifier = CCM.Modifier)  
							OUTER APPLY (SELECT TOP 1 * FROM #Proc_Codes AS t1 WHERE t1.PriceCtgyID = SC.PriceCtgyID AND t1.CodeID = SC.CodeID AND t1.Modifier = CCM.Modifier ORDER BY Modifier) AS LC1
							OUTER APPLY (SELECT TOP 1 * FROM #Proc_Codes AS t2 WHERE t2.PriceCtgyID = SC.PriceCtgyID AND t2.CodeID = SC.CodeID AND t2.Modifier IS NULL) AS LC2
					WHERE	(LC1.PriceCtgyCodeID IS NOT NULL OR LC2.PriceCtgyCodeID IS NOT NULL);

					DROP TABLE #Proc_Codes;
					DROP TABLE #Proc_Codes_Distinct;
					DROP TABLE #ServiceClaimsProc;

					--2c) Identify Costs for Imaging...  
					SELECT * INTO #Img_Codes FROM Ncqa.RRU_PriceCategoryCodes WHERE PriceCtgyID IN (@PriceCtgyImg) AND (MeasureSetID = @MeasureSetID);
					SELECT DISTINCT CodeID, CodeTypeID INTO #Img_Codes_Distinct FROM #Img_Codes;

					CREATE UNIQUE CLUSTERED INDEX IX_#Img_Codes ON #Img_Codes (CodeID, Modifier);
					CREATE UNIQUE CLUSTERED INDEX IX_#Img_Codes_Distinct ON #Img_Codes_Distinct (CodeID);
					
					SELECT DISTINCT
							CS.BeginDate,
							Codes.CodeID,
							Codes.CodeTypeID,
							CS.DSClaimCodeID,
							CS.DSClaimLineID,
							CS.DSMemberID,
							CS.EndDate,
							IDENTITY(int, 1, 1) AS ID,
							Qty
					INTO	#ServiceClaimsImg
					FROM	#Img_Codes_Distinct AS Codes
							INNER JOIN #ClaimSource AS CS
									ON Codes.CodeID = CS.CodeID
					WHERE	(
								(CS.BeginDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) OR
								(CS.EndDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate)
							);

					CREATE UNIQUE CLUSTERED INDEX IX_#ServiceClaimsImg ON #ServiceClaimsImg (DSClaimLineID, CodeTypeID, DSClaimCodeID);

					SELECT	SC2.ID
					INTO	#DeleteServicesImg
					FROM	#ServiceClaimsImg AS SC1
							INNER JOIN #ServiceClaimsImg SC2
									ON SC1.DSClaimLineID = SC2.DSClaimLineID AND
										SC1.CodeTypeID IN (@CodeType1, @CodeTypeH) AND
										SC2.CodeTypeID = @CodeTypeR;
					
					DELETE FROM #ServiceClaimsImg WHERE ID IN (SELECT ID FROM #DeleteServicesImg);

					INSERT INTO #RRU_Services
					        (BeginDate,
					        CodeID,
					        DSClaimCodeID,
					        DSClaimLineID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
							PriceCtgyCodeID,
					        PriceCtgyID,
					        Price,
					        RRUValTypeID,
					        Qty,
					        Value)
					SELECT DISTINCT
							SC.BeginDate,
					        SC.CodeID,
					        SC.DSClaimCodeID,
					        SC.DSClaimLineID,
					        SC.DSMemberID,
					        SC.EndDate,
					        CASE WHEN LC1.PriceCtgyCodeID IS NOT NULL THEN 1 ELSE 2 END AS OptionNbr,
							ISNULL(LC1.PriceCtgyCodeID, LC2.PriceCtgyCodeID) AS PriceCtgyCodeID,
					        @PriceCtgyImg AS PriceCtgyID,
					        CONVERT(decimal(18, 4), ISNULL(Qty, 0)) * ISNULL(LC1.Price1, LC2.Price1) AS Price,
					        @RRUValTypeCostImaging AS RRUValTypeID,
					        SC.Qty,
					        CONVERT(decimal(18, 4), ISNULL(Qty, 0)) * ISNULL(LC1.Price1, LC2.Price1) AS Value
					FROM	#ServiceClaimsImg AS SC
							LEFT OUTER JOIN #ClaimCptModifiers AS CCM
									ON SC.DSClaimLineID = CCM.DSClaimLineID AND
										EXISTS (SELECT TOP 1 1 FROM #Img_Codes AS t WHERE t.CodeID = SC.CodeID AND t.Modifier = CCM.Modifier)                       
							OUTER APPLY (SELECT TOP 1 * FROM #Img_Codes AS t1 WHERE t1.CodeID = SC.CodeID AND t1.Modifier = CCM.Modifier ORDER BY Modifier) AS LC1
							OUTER APPLY (SELECT TOP 1 * FROM #Img_Codes AS t2 WHERE t2.CodeID = SC.CodeID AND t2.Modifier IS NULL) AS LC2
					WHERE	(LC1.PriceCtgyCodeID IS NOT NULL OR LC2.PriceCtgyCodeID IS NOT NULL);

					DROP TABLE #Img_Codes;
					DROP TABLE #Img_Codes_Distinct;
					DROP TABLE #ServiceClaimsImg;

					--2d) Identify Costs for Lab...   
					SELECT * INTO #Lab_Codes FROM Ncqa.RRU_PriceCategoryCodes WHERE PriceCtgyID IN (@PriceCtgyLab) AND (MeasureSetID = @MeasureSetID);
					SELECT DISTINCT CodeID, CodeTypeID INTO #Lab_Codes_Distinct FROM #Lab_Codes;

					CREATE UNIQUE CLUSTERED INDEX IX_#Lab_Codes ON #Lab_Codes (CodeID, Modifier);
					CREATE UNIQUE CLUSTERED INDEX IX_#Lab_Codes_Distinct ON #Lab_Codes_Distinct (CodeID);
					
					SELECT DISTINCT
							CS.BeginDate,
							Codes.CodeID,
							Codes.CodeTypeID,
							CS.DSClaimCodeID,
							CS.DSClaimLineID,
							CS.DSMemberID,
							CS.EndDate,
							IDENTITY(int, 1, 1) AS ID,
							Qty
					INTO	#ServiceClaimsLab
					FROM	#Lab_Codes_Distinct AS Codes
							INNER JOIN #ClaimSource AS CS
									ON Codes.CodeID = CS.CodeID
					WHERE	(
								(CS.BeginDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) OR
								(CS.EndDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate)
							);

					CREATE UNIQUE CLUSTERED INDEX IX_#ServiceClaimsLab ON #ServiceClaimsLab (DSClaimLineID, CodeTypeID, DSClaimCodeID);

					SELECT	SC2.ID
					INTO	#DeleteServicesLab
					FROM	#ServiceClaimsLab AS SC1
							INNER JOIN #ServiceClaimsLab SC2
									ON SC1.DSClaimLineID = SC2.DSClaimLineID AND
										SC1.CodeTypeID IN (@CodeType1, @CodeTypeH) AND
										SC2.CodeTypeID = @CodeTypeR;
					
					DELETE FROM #ServiceClaimsLab WHERE ID IN (SELECT ID FROM #DeleteServicesLab);

					INSERT INTO #RRU_Services
					        (BeginDate,
					        CodeID,
					        DSClaimCodeID,
					        DSClaimLineID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
							PriceCtgyCodeID,
					        PriceCtgyID,
					        Price,
					        RRUValTypeID,
					        Qty,
					        Value)
					SELECT	SC.BeginDate,
					        SC.CodeID,
					        SC.DSClaimCodeID,
					        SC.DSClaimLineID,
					        SC.DSMemberID,
					        SC.EndDate,
					        CASE WHEN LC1.PriceCtgyCodeID IS NOT NULL THEN 1 ELSE 2 END AS OptionNbr,
							ISNULL(LC1.PriceCtgyCodeID, LC2.PriceCtgyCodeID) AS PriceCtgyCodeID,
					        @PriceCtgyLab AS PriceCtgyID,
					        CONVERT(decimal(18, 4), ISNULL(Qty, 0)) * ISNULL(LC1.Price1, LC2.Price1) AS Price,
					        @RRUValTypeCostLab AS RRUValTypeID,
					        SC.Qty,
					        CONVERT(decimal(18, 4), ISNULL(Qty, 0)) * ISNULL(LC1.Price1, LC2.Price1) AS Value
					FROM	#ServiceClaimsLab AS SC
							LEFT OUTER JOIN #ClaimCptModifiers AS CCM
									ON SC.DSClaimLineID = CCM.DSClaimLineID AND
										EXISTS (SELECT TOP 1 1 FROM #Lab_Codes AS t WHERE t.CodeID = SC.CodeID AND t.Modifier = CCM.Modifier)  
							OUTER APPLY (SELECT TOP 1 * FROM #Lab_Codes AS t1 WHERE t1.CodeID = SC.CodeID AND t1.Modifier = CCM.Modifier ORDER BY Modifier) AS LC1
							OUTER APPLY (SELECT TOP 1 * FROM #Lab_Codes AS t2 WHERE t2.CodeID = SC.CodeID AND t2.Modifier IS NULL) AS LC2
					WHERE	(LC1.PriceCtgyCodeID IS NOT NULL OR LC2.PriceCtgyCodeID IS NOT NULL);

					DROP TABLE #Lab_Codes;
					DROP TABLE #Lab_Codes_Distinct;
					DROP TABLE #ServiceClaimsLab;

					--2e) Identify Costs for Pharmacy...   
					SELECT * INTO #Pharmacy_Codes FROM Ncqa.RRU_PriceCategoryCodes WHERE PriceCtgyID IN (@PriceCtgyG1, @PriceCtgyG2, @PriceCtgyN1, @PriceCtgyN2) AND (MeasureSetID = @MeasureSetID);
					CREATE UNIQUE CLUSTERED INDEX IX_#Pharmacy_Codes ON #Pharmacy_Codes (CodeID);
					
					SELECT	CS.BeginDate,
							Codes.CodeID,
							CS.[Days],
							CS.DSClaimCodeID,
							CS.DSClaimLineID,
							CS.DSMemberID,
							CS.EndDate,
							CASE WHEN CS.Qty IS NOT NULL THEN 1 WHEN CS.[Days] IS NOT NULL THEN 2 ELSE 0 END AS OptionNbr,
							Codes.PriceCtgyCodeID,
							Codes.PriceCtgyID,
							CONVERT(decimal(18, 4), COALESCE(CONVERT(decimal(18, 4), NULLIF(Qty, 0)) * Codes.Price1, CONVERT(decimal(18, 4), CS.[Days]) * Codes.Price2)) AS Price,
							CASE Codes.PriceCtgyID 
								WHEN @PriceCtgyG1 THEN @RRUValTypeFreqPharmG1 
								WHEN @PriceCtgyG2 THEN @RRUValTypeFreqPharmG2 
								WHEN @PriceCtgyN1 THEN @RRUValTypeFreqPharmN1
								WHEN @PriceCtgyN2 THEN @RRUValTypeFreqPharmN2                            
								END AS RRUValTypeID,
							CONVERT(decimal(18, 4), CASE WHEN CS.[Days] BETWEEN 1 AND 30 THEN 1 WHEN CS.[Days] > 30 THEN FLOOR(CONVERT(decimal(18,6), CS.[Days]) / CONVERT(decimal(18,6), 30)) WHEN CS.Qty > 0 THEN 1 ELSE 0 END) AS Qty,
							CONVERT(decimal(18, 4), CASE WHEN CS.[Days] BETWEEN 1 AND 30 THEN 1 WHEN CS.[Days] > 30 THEN FLOOR(CONVERT(decimal(18,6), CS.[Days]) / CONVERT(decimal(18,6), 30)) WHEN CS.Qty > 0 THEN 1 ELSE 0 END) AS [Value]
					INTO	#PharmacyServices
					FROM	#Pharmacy_Codes AS Codes
							INNER JOIN #ClaimSource AS CS
									ON Codes.CodeID = CS.CodeID
					WHERE	(CS.BeginDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) AND
							(CS.ClaimTypeID = @ClaimTypeP);

					INSERT INTO #RRU_Services
					        (BeginDate,
					        CodeID,
							[Days],
					        DSClaimCodeID,
					        DSClaimLineID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
					        PriceCtgyCodeID,
					        PriceCtgyID,
					        Price,
					        RRUValTypeID,
					        Qty,
					        Value)
					SELECT	BeginDate,
					        CodeID,
							[Days],
					        DSClaimCodeID,
					        DSClaimLineID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
					        PriceCtgyCodeID,
					        PriceCtgyID,
					        Price,
					        RRUValTypeID,
					        Qty,
					        Value
					FROM	#PharmacyServices
					UNION ALL
					SELECT	BeginDate,
					        CodeID,
							[Days],
					        DSClaimCodeID,
					        DSClaimLineID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
					        PriceCtgyCodeID,
					        PriceCtgyID,
					        Price,
					        @RRUValTypeCostPharmacy AS RRUValTypeID,
					        Qty,
					        Price AS Value
					FROM	#PharmacyServices;                  

					DROP TABLE #Pharmacy_Codes;
					DROP TABLE #PharmacyServices;

					--2f) Identify ED visits and Misc. Procedures...
					SELECT	MX.Abbrev,
							MX.Descr,
							MX.MeasureID,
							MX.MetricID,
							MX.MetricXrefID,
							MX.ScoreTypeID, 
							NRVT.ColumnName, 
							NRVT.RRUValTypeID
					INTO	#MetricValueTypeKey
					FROM	Measure.Measures AS MM
							INNER JOIN Measure.Metrics AS MX
									ON MM.MeasureID = MX.MeasureID
							LEFT OUTER JOIN Ncqa.RRU_ValueTypes AS NRVT
									ON (MX.Abbrev LIKE '%Freq%') AND      
										(NRVT.ColumnName LIKE 'Freq%') AND
										(                  
											(RIGHT(MX.Abbrev, LEN(MX.Abbrev) - 3) = NRVT.ColumnName) OR
											(LEFT(RIGHT(MX.Abbrev, LEN(MX.Abbrev) - 3), 8) = LEFT(REPLACE(NRVT.ColumnName, 'Proc', ''), 8))
										)      
					WHERE	(MM.MeasClassID = @MeasClassRRU) AND
							(MM.MeasureSetID = @MeasureSetID) AND
							(MM.IsEnabled = 1) AND
							(MX.IsEnabled = 1) AND
							(MX.ScoreTypeID = @ScoreTypeC);
		                   
					CREATE UNIQUE CLUSTERED INDEX IX_#MetricValueTypeKey ON #MetricValueTypeKey (MetricID);

					INSERT INTO #RRU_Services
					        (BeginDate,
					        DSEntityID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
					        RRUValTypeID,
					        Qty,
					        Value)
					SELECT DISTINCT
							RMD.BeginDate,
					        RMD.DSEntityID,
					        RMD.DSMemberID,
					        RMD.EndDate,
					        1 AS OptionNbr,
					        MVTK.RRUValTypeID,
					        RMD.Qty AS Qty,
					        RMD.Qty AS Value
					FROM	Result.MeasureDetail AS RMD
							INNER JOIN #RRU_Base AS B
									ON RMD.DSMemberID = B.DSMemberID
							INNER JOIN #MetricValueTypeKey AS MVTK
									ON RMD.MetricID = MVTK.MetricID
					WHERE	(RMD.BatchID = @BatchID) AND
							(RMD.DataRunID = @DataRunID) AND
							(RMD.DataSetID = @DataSetID); 

					DROP TABLE #MetricValueTypeKey;

					--3) Apply Parent ValueTypes to #RRU_Services
					CREATE NONCLUSTERED INDEX IX_#RRU_Services_RRUValTypeID ON #RRU_Services (RRUValTypeID);

					INSERT INTO #RRU_Services
					        (ADSCID,
							BeginDate,
					        CodeID,
							[Days],
					        DSClaimCodeID,
					        DSClaimLineID,
							DSEntityID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
							PriceCtgyCodeID,
					        PriceCtgyID,
					        Price,
					        RRUValTypeID,
					        Qty,
					        Value)
					SELECT	ADSCID,
							BeginDate,
					        CodeID,
							[Days],
					        DSClaimCodeID,
					        DSClaimLineID,
							DSEntityID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
							PriceCtgyCodeID,
					        PriceCtgyID,
					        Price,
					        ParentID AS RRUValTypeID,
					        Qty,
					        Value
					FROM	#RRU_Services AS S
							INNER JOIN Ncqa.RRU_ValueTypes AS NRVT
									ON S.RRUValTypeID = NRVT.RRUValTypeID  
					WHERE	(NRVT.ParentID IS NOT NULL);                

					--4) Log #RRU_Services
					INSERT INTO	Log.RRU_Services 
							(ADSCID,
							BatchID,
							BeginDate,
							CodeID,
							DataRunID,
							DataSetID,
							[Days],
							DSClaimCodeID,
							DSClaimLineID,
							DSEntityID,
							DSMemberID,
							EndDate,
							OptionNbr,
							PriceCtgyCodeID,
							PriceCtgyID,
							Price,
							RRUValTypeID,
							Qty,
							Value)
					SELECT	ADSCID,
							@BatchID AS BatchID,
							BeginDate,
					        CodeID,
							@DataRunID AS DataRunID,
							@DataSetID AS DataSetID,
					        [Days],
							DSClaimCodeID,
					        DSClaimLineID,
							DSEntityID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
							PriceCtgyCodeID,
					        PriceCtgyID,
					        Price,
					        RRUValTypeID,
					        Qty,
					        ISNULL(Value, 0) AS Value   
					FROM	#RRU_Services    
					ORDER BY DSMemberID, RRUValTypeID, DSClaimLineID, DSClaimCodeID;   
					

					--5) Insert RRU Services: ED visits that lead to an unpaid inpatient stay (New for HEDIS 2015)...
					--(Possible alternative, if needed in the future:  Create new claim attribute for "Paid ED Visit leading to unpaid stay")
					DECLARE @EDCombineDays smallint;

					SELECT	@EDCombineDays = BDO.EDCombineDays 
					FROM	Batch.DataOwners AS BDO WITH(NOLOCK)
					WHERE	(BDO.OwnerID = @OwnerID);

					IF @EDCombineDays IS NULL
						SET @EDCombineDays = 3;
					
					SELECT	PCL.BatchID,
							PCL.DataRunID,
							PCL.DataSetID,
							PCL.DSClaimID,
							PCL.DSClaimLineID,
							PCL.DSMemberID,
							PCL.DSProviderID,
							ISNULL(PCL.EndDate, PCL.BeginDate) AS EvalBeginDate,
							DATEADD(dd, @EDCombineDays, ISNULL(PCL.EndDate, PCL.BeginDate)) AS EvalEndDate
					INTO	#EDClaims
					FROM	Proxy.ClaimLines AS PCL
							INNER JOIN Proxy.ClaimAttributes AS PCA
									ON PCA.BatchID = PCL.BatchID AND
										PCA.DataRunID = PCL.DataRunID AND
										PCA.DataSetID = PCL.DataSetID AND
										PCA.DSClaimLineID = PCL.DSClaimLineID AND
										PCA.DSMemberID = PCL.DSMemberID
					WHERE	(PCL.IsPaid) = 1 AND
							(PCL.ServDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) AND
							(PCA.ClaimAttribID = @ClaimAttribID_ED) AND
							(PCL.DSMemberID IN (SELECT DISTINCT DSMemberID FROM #RRU_Base))
					ORDER BY PCL.DSClaimLineID;

					CREATE UNIQUE CLUSTERED INDEX IX_#EDClaims ON #EDClaims (DSClaimLineID);
					CREATE NONCLUSTERED INDEX IX_#EDClaims_DSClaimID ON #EDClaims (DSClaimID);
					CREATE NONCLUSTERED INDEX IX_#EDClaims_DSMemberID ON #EDClaims (DSMemberID);

					SELECT	ED.DSClaimLineID, ED.DSMemberID, MIN(ED.EvalBeginDate) AS BeginDate, MAX(PCL.EndDate) AS EndDate
					INTO	#EDClaimsToCount
					FROM	#EDClaims AS ED
							INNER JOIN Proxy.ClaimLines AS PCL
									ON PCL.BatchID = ED.BatchID AND
										PCL.DataRunID = ED.DataRunID AND
										PCL.DataSetID = ED.DataSetID AND
										PCL.DSClaimID = ED.DSClaimID --AND
										--PCL.BeginDate BETWEEN ED.EvalBeginDate AND ED.EvalEndDate
							INNER JOIN Proxy.ClaimAttributes AS PCA
									ON PCA.BatchID = PCL.BatchID AND
										PCA.DataRunID = PCL.DataRunID AND
										PCA.DataSetID = PCL.DataSetID AND
										PCA.DSClaimLineID = PCL.DSClaimLineID AND
										PCA.DSMemberID = PCL.DSMemberID
					WHERE	PCA.ClaimAttribID = @ClaimAttribID_IN
					GROUP BY ED.DSClaimLineID, ED.DSMemberID
					HAVING (MAX(CONVERT(tinyint, PCL.IsPaid)) = 0);

					CREATE UNIQUE CLUSTERED INDEX IX_#EDClaimsToCount ON #EDClaimsToCount (DSClaimLineID);
					CREATE NONCLUSTERED INDEX IX_#EDClaimsToCount_DSMemberID ON #EDClaimsToCount (DSMemberID);

					WITH CountsToAdd AS
					(
						SELECT	MIN(ED.BeginDate) AS BeginDate,
								ED.DSMemberID,
								MAX(ED.EndDate) AS EndDate,
								COUNT(DISTINCT ED.BeginDate) AS Qty
						FROM	#EDClaimsToCount AS ED
						GROUP BY ED.DSMemberID
					)
					INSERT INTO #RRU_Services
					        (BeginDate,
					        DSEntityID,
					        DSMemberID,
					        EndDate,
					        OptionNbr,
					        RRUValTypeID,
					        Qty,
					        Value)
					SELECT DISTINCT
							A.BeginDate,
					        NULL AS DSEntityID,
					        A.DSMemberID,
					        A.EndDate,
					        1 AS OptionNbr,
					        @RRUValTypeFreqED AS RRUValTypeID,
					        A.Qty AS Qty,
					        A.Qty AS Value
					FROM	CountsToAdd AS A; 

					------------------------------------------------------------------------------------------------------------------
					--6) Update MeasureDetail_RRU based on identified services...
					--6a) Create Dynamic Pivot of #RRU_Services using RRUValTypeID...
					DECLARE @ColumnList nvarchar(max);
					DECLARE @ColumnListWithDefaults nvarchar(max);
					DECLARE @ColumnListUpdateCaps nvarchar(max);
					DECLARE @CrLf nvarchar(2);
					DECLARE @SqlCmd nvarchar(max);

					SET @CrLf = CHAR(13) + CHAR(10);

					SELECT	@ColumnList = ISNULL(@ColumnList + ', ', '') + QUOTENAME(ColumnName),
							@ColumnListWithDefaults = ISNULL(@ColumnListWithDefaults + ', ', '') + 'ISNULL(' + QUOTENAME(ColumnName) + ', 0) AS ' + QUOTENAME(ColumnName),
							@ColumnListUpdateCaps = ISNULL(ISNULL(@ColumnListUpdateCaps + ', ' + @CrLf, '') + QUOTENAME(ColumnNameCapped) + ' = ' + FuncPrefix + 'CASE WHEN ' + QUOTENAME(ColumnName) + ' > ' + CONVERT(nvarchar(max), NRVTPC.PriceCap) + ' THEN ' + CONVERT(nvarchar(max), NRVTPC.PriceCap) + ' ELSE ' + QUOTENAME(ColumnName) + ' END' + FuncSuffix, @ColumnListUpdateCaps)
					FROM	Ncqa.RRU_ValueTypes AS NRVT
							LEFT OUTER JOIN Ncqa.RRU_ValueTypePriceCaps AS NRVTPC
									ON NRVT.RRUValTypeID = NRVTPC.RRUValTypeID
					ORDER BY ColumnName;

					--PRINT 'UPDATE #RRU_Services SET ' + @CrLf + @ColumnListUpdateCaps;

					SET @SqlCmd =	'SELECT	DSMemberID, ' + @ColumnListWithDefaults + @CrLf + 
									'FROM	(' + @CrLf +
									'			SELECT	ColumnName, DSMemberID, Value ' + @CrLf +
									'			FROM	#RRU_Services AS S ' + @CrLf +
									'					INNER JOIN Ncqa.RRU_ValueTypes AS NRVT ' + @CrLf +
									'							ON S.RRUValTypeID = NRVT.RRUValTypeID ' + @CrLf +
									'		) AS p ' + @CrLf +
									'		PIVOT ' + @CrLf +
									'		(' + @CrLf +
									'			SUM(Value) FOR ColumnName IN (' + @ColumnList + ')' + @CrLf +
									'		) as pvt';

					IF OBJECT_ID('tempdb..#RRU_ServicesPivot') IS NOT NULL
						DROP TABLE #RRU_ServicesPivot;

					CREATE TABLE #RRU_ServicesPivot
					(
						[DSMemberID] [bigint] NULL,
						[CostEMInpatient] [decimal](18, 4) NOT NULL,
						[CostEMInpatientCapped] [decimal](18, 4) NULL,
						[CostEMOutpatient] [decimal](18, 4) NOT NULL,
						[CostEMOutpatientCapped] [decimal](18, 4) NULL,
						[CostImaging] [decimal](18, 4) NOT NULL,
						[CostImagingCapped] [decimal](18, 4) NULL,
						[CostInpatient] [decimal](18, 4) NOT NULL,
						[CostInpatientCapped] [decimal](18, 4) NULL,
						[CostLab] [decimal](18, 4) NOT NULL,
						[CostLabCapped] [decimal](18, 4) NULL,
						[CostPharmacy] [decimal](18, 4) NOT NULL,
						[CostPharmacyCapped] [decimal](18, 4) NULL,
						[CostProcInpatient] [decimal](18, 4) NOT NULL,
						[CostProcInpatientCapped] [decimal](18, 4) NULL,
						[CostProcOutpatient] [decimal](18, 4) NOT NULL,
						[CostProcOutpatientCapped] [decimal](18, 4) NULL,
						[DaysAcuteInpatient] [decimal](18, 4) NOT NULL,
						[DaysAcuteInpatientNotSurg] [decimal](18, 4) NOT NULL,
						[DaysAcuteInpatientSurg] [decimal](18, 4) NOT NULL,
						[DaysNonacuteInpatient] [decimal](18, 4) NOT NULL,
						[FreqAcuteInpatient] [decimal](18, 4) NOT NULL,
						[FreqAcuteInpatientNotSurg] [decimal](18, 4) NOT NULL,
						[FreqAcuteInpatientSurg] [decimal](18, 4) NOT NULL,
						[FreqED] [decimal](18, 4) NOT NULL,
						[FreqNonacuteInpatient] [decimal](18, 4) NOT NULL,
						[FreqPharmG1] [decimal](18, 4) NOT NULL,
						[FreqPharmG2] [decimal](18, 4) NOT NULL,
						[FreqPharmN1] [decimal](18, 4) NOT NULL,
						[FreqPharmN2] [decimal](18, 4) NOT NULL,
						[FreqProcCABG] [decimal](18, 4) NOT NULL,
						[FreqProcCAD] [decimal](18, 4) NOT NULL,
						[FreqProcCardiacCath] [decimal](18, 4) NOT NULL,
						[FreqProcCAS] [decimal](18, 4) NOT NULL,
						[FreqProcCAT] [decimal](18, 4) NOT NULL,
						[FreqProcEndarter] [decimal](18, 4) NOT NULL,
						[FreqProcPCI] [decimal](18, 4) NOT NULL
					);

					INSERT INTO #RRU_ServicesPivot
					        (DSMemberID,
					        CostEMInpatient,
					        CostEMOutpatient,
					        CostImaging,
					        CostInpatient,
					        CostLab,
					        CostPharmacy,
					        CostProcInpatient,
					        CostProcOutpatient,
					        DaysAcuteInpatient,
					        DaysAcuteInpatientNotSurg,
					        DaysAcuteInpatientSurg,
					        DaysNonacuteInpatient,
					        FreqAcuteInpatient,
					        FreqAcuteInpatientNotSurg,
					        FreqAcuteInpatientSurg,
					        FreqED,
					        FreqNonacuteInpatient,
					        FreqPharmG1,
					        FreqPharmG2,
					        FreqPharmN1,
					        FreqPharmN2,
					        FreqProcCABG,
					        FreqProcCAD,
					        FreqProcCardiacCath,
					        FreqProcCAS,
					        FreqProcCAT,
					        FreqProcEndarter,
					        FreqProcPCI)
					EXEC (@SqlCmd);

					SET @SqlCmd = 'UPDATE #RRU_ServicesPivot SET ' + @CrLf + @ColumnListUpdateCaps;
					EXEC (@SqlCmd);

					CREATE UNIQUE CLUSTERED INDEX IX_#RRU_ServicesPivot ON #RRU_ServicesPivot (DSMemberID);

					--6b) Use Pivot to Populate MeasureDetail_RRU...
					UPDATE	RRU
					SET		CostEMInpatient = ISNULL(SP.CostEMInpatient, 0), 
							CostEMInpatientCapped = ISNULL(SP.CostEMInpatientCapped, 0), 
							CostEMOutpatient = ISNULL(SP.CostEMOutpatient, 0), 
							CostEMOutpatientCapped = ISNULL(SP.CostEMOutpatientCapped, 0), 
							CostImaging = ISNULL(SP.CostImaging, 0), 
							CostImagingCapped = ISNULL(SP.CostImagingCapped, 0), 
							CostInpatient = ISNULL(SP.CostInpatient, 0), 
							CostInpatientCapped = ISNULL(SP.CostInpatientCapped, 0), 
							CostLab = ISNULL(SP.CostLab, 0), 
							CostLabCapped = ISNULL(SP.CostLabCapped, 0), 
							CostPharmacy = ISNULL(SP.CostPharmacy, 0), 
							CostPharmacyCapped = ISNULL(SP.CostPharmacyCapped, 0), 
							CostProcInpatient = ISNULL(SP.CostProcInpatient, 0), 
							CostProcInpatientCapped = ISNULL(SP.CostProcInpatientCapped, 0), 
							CostProcOutpatient = ISNULL(SP.CostProcOutpatient, 0), 
							CostProcOutpatientCapped = ISNULL(SP.CostProcOutpatientCapped, 0), 
							DaysAcuteInpatient = ISNULL(SP.DaysAcuteInpatient, 0), 
							DaysAcuteInpatientNotSurg = ISNULL(SP.DaysAcuteInpatientNotSurg, 0), 
							DaysAcuteInpatientSurg = ISNULL(SP.DaysAcuteInpatientSurg, 0), 
							DaysNonacuteInpatient = ISNULL(SP.DaysNonacuteInpatient, 0), 
							FreqAcuteInpatient = ISNULL(SP.FreqAcuteInpatient, 0), 
							FreqAcuteInpatientNotSurg = ISNULL(SP.FreqAcuteInpatientNotSurg, 0), 
							FreqAcuteInpatientSurg = ISNULL(SP.FreqAcuteInpatientSurg, 0), 
							FreqED = ISNULL(SP.FreqED, 0), 
							FreqNonacuteInpatient = ISNULL(SP.FreqNonacuteInpatient, 0), 
							FreqPharmG1 = ISNULL(SP.FreqPharmG1, 0), 
							FreqPharmG2 = ISNULL(SP.FreqPharmG2, 0), 
							FreqPharmN1 = ISNULL(SP.FreqPharmN1, 0), 
							FreqPharmN2 = ISNULL(SP.FreqPharmN2, 0), 
							FreqProcCABG = ISNULL(SP.FreqProcCABG, 0), 
							FreqProcCAD = ISNULL(SP.FreqProcCAD, 0), 
							FreqProcCardiacCath = ISNULL(SP.FreqProcCardiacCath, 0), 
							FreqProcCAS = ISNULL(SP.FreqProcCAS, 0), 
							FreqProcCAT = ISNULL(SP.FreqProcCAT, 0), 
							FreqProcEndarter = ISNULL(SP.FreqProcEndarter, 0), 
							FreqProcPCI = ISNULL(SP.FreqProcPCI, 0),
							MM = ISNULL(MM.MM, 0),
							MMP = ISNULL(MM.MMP, 0)
					FROM	Result.MeasureDetail_RRU AS RRU
							LEFT OUTER JOIN #RRU_ServicesPivot AS SP
									ON RRU.DSMemberID = SP.DSMemberID
							LEFT OUTER JOIN #MemberMonths AS MM
									ON RRU.DSMemberID = MM.DSMemberID
					WHERE	(RRU.BatchID = @BatchID) AND
							(RRU.DataRunID = @DataRunID) AND
							(RRU.DataSetID = @DataSetID);                   

					SET @CountRecords = ISNULL(@CountRecords, @@ROWCOUNT);  
				END;
			ELSE
				SET @CountRecords = ISNULL(@CountRecords, 0);          
			
			SET @LogDescr = ' - Calculating RRU cost and frequency for BATCH ' + CAST(@BatchID AS varchar(32)) + ' succeeded.'; 
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
			SET @LogDescr = ' - Calculating RRU cost and frequency for BATCH ' + CAST(@BatchID AS varchar(32)) + ' failed!'; 
			
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
GRANT VIEW DEFINITION ON  [Ncqa].[RRU_CalculateCostAndFrequency] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_CalculateCostAndFrequency] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[RRU_CalculateCostAndFrequency] TO [Processor]
GO
