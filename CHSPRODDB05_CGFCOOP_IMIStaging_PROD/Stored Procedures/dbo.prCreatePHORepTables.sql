SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*********************************************************************************************************************************/
/*********************************************************************************************************************************/
/***                                                                                                                           ***/
/***                                  SAINT FRANCIS OUT-OF-NETWORK CLAIMS DATA PULL                                            ***/
/***                                                  JANET LEDBETTER                                                          ***/
/***                                                 CREATED: 10/2/2014                                                        ***/
/***                                                                                                                           ***/
/***                                                                                                                           ***/
/*********************************************************************************************************************************/
/*********************************************************************************************************************************/

--USE STFran_IMIStaging_PROD

/********************************/
/***   PROVIDER INFORMATION   ***/
/********************************/

/*
select *
--into [IMICodeStore].[nppes].BillTypeDigit3
from imisql15.[IMICodeStore].[nppes].BillTypeDigit3

[nppes].[NPI_ProviderOtherIdentifier]
EXEC IMICodeStore..sp_helpindex 'nppes.NPI_Provider'


CREATE INDEX idxNPI ON IMICodeStore.[nppes].BillTypeDigit1 (BillTypeDigit1)
CREATE STATISTICS spidxNPI ON IMICodeStore.[nppes].BillTypeDigit1 (BillTypeDigit1)

*/
CREATE PROC [dbo].[prCreatePHORepTables] AS

DECLARE @bMoveToProd BIT = 1
DECLARE @vcClient VARCHAR(20) = 'CCI'

-- PROVIDER IDENTIFIERS ON CLAIM
IF 1 = 2
BEGIN
	IF object_id('tempdb..#provclaim') IS NOT NULL
		DROP TABLE #ProvClaim

	SELECT clm.ServicingProviderID
		INTO #ProvClaim
		FROM [dbo].[Claim] clm
		GROUP BY clm.ServicingProviderID

	CREATE INDEX idx ON #ProvClaim (ServicingProviderID)
	CREATE STATISTICS sp ON #ProvClaim (ServicingProviderID)

	IF OBJECT_ID('tempdb..#provider') IS NOT NULL
		DROP TABLE #provider

	SELECT DISTINCT prv.[Client],
			pc.[ServicingProviderID],
			prv.[CustomerProviderID],
			prv.[NameLast],
			prv.[NameFirst],
			prv.[NetworkID],
			prv.[BoardCertification1],
			prv.[BoardCertification2],
			prv.[SpecialtyCode1Desc],
			prv.[SpecialtyCode2Desc],
			prv.[ProviderType],
			npip.*
		INTO #Provider
		FROM [dbo].[Provider] prv
			INNER JOIN #ProvClaim pc
				ON pc.ServicingProviderID = prv.ProviderID
			LEFT OUTER JOIN [IMICodeStore].[nppes].[NPI_Provider] npip
				ON npip.[NPI] = prv.[NPI]

	CREATE INDEX idxProvNPI ON #Provider (NPI)
	CREATE STATISTICS  spidxProvNPI ON #Provider (NPI)

	--SELECT TOP 10 * FROM [IMICodeStore].[nppes].[NPI_Provider] npip

	-- OTHER PROVIDER IDENTIFIERS 

	IF OBJECT_ID('tempdb..#providerID') IS NOT NULL
		DROP TABLE #Provider

	SELECT DISTINCT clm.[Client],
			clm.[ServicingProviderID],
			prv.[CustomerProviderID],
			npip.*
		INTO #ProviderID
		FROM [dbo].[Claim] clm
			INNER JOIN [dbo].[Provider] prv
				ON clm.ServicingProviderID = prv.ProviderID
			LEFT OUTER JOIN [IMICodeStore].[nppes].[NPI_ProviderOtherIdentifier] npip
				ON npip.[NPI] = prv.[NPI]


	CREATE INDEX idxProvIDNPI ON #ProviderID (NPI)
	CREATE STATISTICS spidxProvIDNPI ON #ProviderID (NPI)

	-- PROVIDER TAXONOMY

	IF OBJECT_ID('tempdb..#taxonomy') IS NOT NULL
		DROP TABLE #taxonomy

	SELECT DISTINCT clm.[Client],
			clm.[ServicingProviderID],
			prv.[CustomerProviderID],
			npit.*
		INTO #Taxonomy
		FROM [dbo].[Claim] clm
			INNER JOIN [dbo].[Provider] prv
				ON clm.ServicingProviderID = prv.ProviderID
			LEFT OUTER JOIN [IMICodeStore].[nppes].[NPI_ProviderTaxonomy] npit
				ON npit.[NPI] = prv.[NPI]

	CREATE INDEX idxProvNPI ON #Taxonomy(NPI)

END

/**********************************/
/***   VISIT TYPE INFORMATION   ***/
/**********************************/

-- INPATIENT ADMIT INFORMATION

IF OBJECT_ID('tempdb..#ipadmit') IS NOT NULL
    DROP TABLE #ipadmit

SELECT  cli.ClaimID,
        IpAdmit = SUM(xrf.IPAdmit),
        IpDays = SUM(xrf.IPDays),
        IPTotalNetamt = SUM(cli.AmountNetPayment)
    INTO #ipadmit
    FROM ClaimLineItem cli
        INNER JOIN BrXref_ClaimLineItem xrf
            ON xrf.ClaimLineItemID = cli.ClaimLineItemID
	WHERE cli.Client = ISNULL(@vcClient,cli.client) 
    GROUP BY cli.ClaimID
    HAVING SUM(xrf.IPAdmit) > 0

CREATE INDEX idx ON #ipadmit (ClaimID)
CREATE STATISTICS spidx ON #ipadmit (ClaimID)

-- OUTPATIENT ADMIT INFORMATION

IF OBJECT_ID('tempdb..#opadmit') IS NOT NULL
    DROP TABLE #opadmit

SELECT cli.ClaimID,
        OutpatientHospVisit = SUM(xrf.OutpatientHospVisit),
        OutpatientHospTotalNetamt = SUM(cli.AmountNetPayment)
    INTO #opadmit
    FROM ClaimLineItem cli
        INNER JOIN BrXref_ClaimLineItem xrf
            ON xrf.ClaimLineItemID = cli.ClaimLineItemID
        INNER JOIN Claim clm
            ON clm.ClaimID = cli.ClaimID
	WHERE cli.Client = ISNULL(@vcClient,cli.client) 
    GROUP BY cli.ClaimID
    HAVING SUM(xrf.OutpatientHospVisit) > 0

-- ER VISIT INFORMATION

IF OBJECT_ID('tempdb..#EDVisit') IS NOT NULL
    DROP TABLE #EDVisit

SELECT  cli.ClaimID,
        EDVisit = SUM(xrf.EDVisit),
		TotalClaimNetAmtwithEDVisit = SUM(cli.AmountNetPayment)
    INTO #EDVisit
    FROM ClaimLineItem cli
        INNER JOIN BrXref_ClaimLineItem xrf
            ON xrf.ClaimLineItemID = cli.ClaimLineItemID
	WHERE cli.Client = ISNULL(@vcClient,cli.client) 
    GROUP BY cli.ClaimID
    HAVING SUM(xrf.EDVisit) > 0

-- OFFICE VISIT INFORMATION

IF OBJECT_ID('tempdb..#officevisit') IS NOT NULL
    DROP TABLE #officevisit

SELECT  cli.ClaimID,
        OfficeVisit = SUM(xrf.OfficeVisit),
		TotalClaimNetAmtwithOfficeVisit = SUM(cli.AmountNetPayment)
    INTO #officevisit
    FROM ClaimLineItem cli
        INNER JOIN BrXref_ClaimLineItem xrf
            ON xrf.ClaimLineItemID = cli.ClaimLineItemID
	WHERE cli.Client = ISNULL(@vcClient,cli.client) 
    GROUP BY cli.ClaimID
    HAVING SUM(xrf.OfficeVisit) > 0

-- OTHER VISIT INFORMATION

IF OBJECT_ID('tempdb..#OtherVisit') IS NOT NULL
    DROP TABLE #OtherVisit

SELECT cli.ClaimID,
        OtherVisit = SUM(xrf.OtherVisit),
        TotalClaimNetAmtwithOtherVisit = SUM(cli.AmountNetPayment)
    INTO #OtherVisit
    FROM ClaimLineItem cli
        INNER JOIN BrXref_ClaimLineItem xrf
            ON xrf.ClaimLineItemID = cli.ClaimLineItemID
	WHERE cli.Client = ISNULL(@vcClient,cli.client) 
    GROUP BY cli.ClaimID
    HAVING SUM(xrf.OtherVisit) > 0

-- Join Results
IF OBJECT_ID('tempdb..#claimline') IS NOT NULL 
	DROP TABLE #claimline

SELECT cli.ClaimID,
		ClaimDetailLineCount = COUNT(*)
	INTO #claimline
	FROM dbo.ClaimLineItem cli
	GROUP BY cli.ClaimID
	ORDER BY cli.ClaimID

CREATE INDEX fk ON #claimline (claimid, ClaimDetailLineCount)
CREATE STATISTICS sp ON #claimline (claimid, ClaimDetailLineCount)


IF OBJECT_ID('tempdb..#ClaimSummary') IS NOT NULL 
	DROP TABLE #ClaimSummary

SELECT c.Claimid,
		c.Client,
		p.npi,
		ProviderFullName = ISNULL(p.ProviderFullName,'Provider Not Defined'),
		NewPHOIndicator = ISNULL(px.NewPHOIndicator,'PHO Indicator Not Defined'),
        ServiceYear = DATEPART(YEAR, c.[DateServiceBegin]),
        ServiceMonth = DATEPART(MONTH, c.[DateServiceBegin]),
        c.[DateServiceBegin],
        c.[PlaceOfService],
        pos.PLACEOFSERVICE_SHORT_DESC,
        pos.PLACEOFSERVICE_LONG_DESC,
        c.[BillType],
        BillTypeFacility = bt.FacilityDesc,
        BillTypeBillClass = bt.BilLClassDesc,
        c.[ClaimType],
        c.DataSource,
		ip.IpAdmit,
		ip.IpDays,
		ip.IPTotalNetamt,
		op.OutpatientHospVisit,
		op.OutpatientHospTotalNetamt,
		ed.EDVisit,
		ed.TotalClaimNetAmtwithEDVisit,
		ov.OfficeVisit,
		ov.TotalClaimNetAmtwithOfficeVisit,
		ot.OtherVisit,
		ot.TotalClaimNetAmtwithOtherVisit,
		cli.ClaimDetailLineCount
	INTO #ClaimSummary
	FROM claim c
		INNER JOIN #claimline cli
			ON cli.ClaimID = c.ClaimID
		LEFT JOIN provider p
			ON c.ServicingProviderID = p.ProviderID
		LEFT JOIN dbo.BrXref_Provider px
			ON c.ServicingProviderID = px.ProviderID
		LEFT JOIN #ipadmit ip
			ON c.ClaimID = ip.ClaimID
		LEFT JOIN #opadmit op
			ON c.ClaimID = op.ClaimID
		LEFT JOIN #EDVisit ed
			ON c.ClaimID = ed.ClaimID
		LEFT JOIN #officevisit ov
			ON c.ClaimID = ov.ClaimID
		LEFT JOIN #OtherVisit ot
			ON c.claimid= ot.ClaimID
        LEFT OUTER JOIN [IMICodeStore].[dbo].[OTHER_PlaceOfService] pos
            ON pos.[PLACEOFSERVICE_CD] = c.[PlaceOfService]
        LEFT OUTER JOIN [IMICodeStore].dbo.Billtype bt
            ON c.BillType = bt.BillType



/*****************************/
/***   CLAIM INFORMATION   ***/
/*****************************/

--  MOVE PROCEDURE DIM INFO TO CODESTORE 

--SELECT *
--INTO IMICodeStore.NPPES.ProcedureCode
--FROM [IMI_IHDS_DW01].[dbo].[procedure_dim]

--  PROCEDURE CODE INFORMATION 
BEGIN
	IF OBJECT_ID('tempdb..#PHO_ProcedureCode') IS NOT NULL
		DROP TABLE #PHO_ProcedureCode

	SELECT  xp.NewPHOIndicator,
			ServiceYearMonth = LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			cli.CPTProcedureCode,
			cpt.[procedure_desc],
			cpt.[procedure_category],
			cpt.[procedure_grouping1_desc],
			cpt.[procedure_betos_desc],
			Units = SUM(cli.Units),
			ClaimCount = COUNT(DISTINCT cli.ClaimId),
			ClaimDetailLineCount = COUNT(DISTINCT cli.[ClaimLineItemID]),
			TotalNetPaid = SUM(cli.AmountNetPayment)
		INTO #PHO_ProcedureCode
		FROM [dbo].[ClaimLineItem] cli
			INNER JOIN [dbo].[Claim] clm
				ON clm.ClaimID = cli.ClaimID
			LEFT OUTER JOIN [dbo].[Provider] prv
				ON clm.ServicingProviderID = prv.ProviderID
			LEFT OUTER JOIN [IMICodeStore].[nppes].[ProcedureCode] cpt
				ON cpt.[procedure_code] = cli.CPTProcedureCode
	        INNER JOIN BrXref_Provider xp
		        ON xp.ProviderID = clm.ServicingProviderID
		WHERE clm.Client = ISNULL(@vcClient,clm.client) 
			AND ISNULL(cli.CPTProcedureCode,'') <> ''
		GROUP BY xp.NewPHOIndicator,
			LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			cli.CPTProcedureCode,
			cpt.[procedure_desc],
			cpt.[procedure_category],
			cpt.[procedure_grouping1_desc],
			cpt.[procedure_betos_desc]

	CREATE INDEX idxProcedureNPI ON #PHO_ProcedureCode (NewPHOIndicator, ServiceYearMonth)

	IF OBJECT_ID('tempdb..#NPI_ProcedureCode') IS NOT NULL
		DROP TABLE #NPI_ProcedureCode

	SELECT  prv.NPI,
			xp.NewPHOIndicator,
			ServiceYearMonth = LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			cli.CPTProcedureCode,
			cpt.[procedure_desc],
			cpt.[procedure_category],
			cpt.[procedure_grouping1_desc],
			cpt.[procedure_betos_desc],
			Units = SUM(cli.Units),
			ClaimCount = COUNT(DISTINCT cli.ClaimId),
			ClaimDetailLineCount = COUNT(DISTINCT cli.[ClaimLineItemID]),
			TotalNetPaid = SUM(cli.AmountNetPayment)
		INTO #NPI_ProcedureCode
		FROM [dbo].[ClaimLineItem] cli
			INNER JOIN [dbo].[Claim] clm
				ON clm.ClaimID = cli.ClaimID
			LEFT OUTER JOIN [dbo].[Provider] prv
				ON clm.ServicingProviderID = prv.ProviderID
			LEFT OUTER JOIN [IMICodeStore].[nppes].[ProcedureCode] cpt
				ON cpt.[procedure_code] = cli.CPTProcedureCode
	        INNER JOIN BrXref_Provider xp
		        ON xp.ProviderID = clm.ServicingProviderID
		WHERE cli.client = ISNULL(@vcClient,cli.client) 
			AND ISNULL(cli.CPTProcedureCode,'') <> ''
		GROUP BY prv.NPI,
			xp.NewPHOIndicator,
			LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			cli.CPTProcedureCode,
			cpt.[procedure_desc],
			cpt.[procedure_category],
			cpt.[procedure_grouping1_desc],
			cpt.[procedure_betos_desc]

	CREATE INDEX idx ON #NPI_ProcedureCode (NPI, NewPHOIndicator, ServiceYearMonth)
	CREATE STATISTICS sp ON #NPI_ProcedureCode (NPI, NewPHOIndicator, ServiceYearMonth)


END

--  DIAGNOSIS CODE INFORMATION
BEGIN

	IF OBJECT_ID('tempdb..#PHO_Diagnosis') IS NOT NULL
		DROP TABLE #PHO_Diagnosis

	SELECT xp.NewPHOIndicator,
			ServiceYearMonth = LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			clm.DiagnosisCode1,
			dxcat.DxCategory,
			dxsub.DxSubCategory,
			Units = SUM(cli.Units),
			ClaimCount = COUNT(DISTINCT cli.ClaimId),
			ClaimDetailLineCount = COUNT(DISTINCT cli.[ClaimLineItemID]),
			TotalNetPaid = SUM(cli.AmountNetPayment)
		INTO #PHO_Diagnosis
		FROM [dbo].[Claim] clm
			INNER JOIN [dbo].[ClaimLineItem] cli
				ON clm.ClaimID = cli.ClaimID
			INNER JOIN [dbo].[Provider] prv
				ON clm.ServicingProviderID = prv.ProviderID
	        INNER JOIN BrXref_Provider xp
		        ON xp.ProviderID = clm.ServicingProviderID
			LEFT OUTER JOIN [IMICodeStore].[dbo].[ICD9_DxCategory] dxcat
				ON clm.DiagnosisCode1 BETWEEN dxcat.[DxCategoryBegin]
									  AND     dxcat.[DxCategoryEnd]
			LEFT OUTER JOIN [IMICodeStore].[dbo].[ICD9_DxSubCategory] dxsub
				ON clm.DiagnosisCode1 BETWEEN dxsub.[DxSubCategoryBegin]
									  AND     dxsub.[DxSubCategoryEnd]
		WHERE clm.Client = ISNULL(@vcClient,clm.client) 
			AND ISNULL(clm.DiagnosisCode1,'') <> ''
		GROUP BY xp.NewPHOIndicator,
			LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			clm.DiagnosisCode1,
			dxcat.DxCategory,
			dxsub.DxSubCategory

	CREATE INDEX idx ON #PHO_Diagnosis (NewPHOIndicator, ServiceYearMonth, DiagnosisCode1)

	IF OBJECT_ID('tempdb..#NPI_Diagnosis') IS NOT NULL
		DROP TABLE #NPI_Diagnosis

	SELECT prv.Npi,
			xp.NewPHOIndicator,
			ServiceYearMonth = LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			clm.DiagnosisCode1,
			dxcat.DxCategory,
			dxsub.DxSubCategory,
			Units = SUM(cli.Units),
			ClaimCount = COUNT(DISTINCT cli.ClaimId),
			ClaimDetailLineCount = COUNT(DISTINCT cli.[ClaimLineItemID]),
			TotalNetPaid = SUM(cli.AmountNetPayment)
		INTO #NPI_Diagnosis
		FROM [dbo].[Claim] clm
			INNER JOIN [dbo].[ClaimLineItem] cli
				ON clm.ClaimID = cli.ClaimID
			INNER JOIN [dbo].[Provider] prv
				ON clm.ServicingProviderID = prv.ProviderID
	        INNER JOIN BrXref_Provider xp
		        ON xp.ProviderID = clm.ServicingProviderID
			LEFT OUTER JOIN [IMICodeStore].[dbo].[ICD9_DxCategory] dxcat
				ON clm.DiagnosisCode1 BETWEEN dxcat.[DxCategoryBegin]
									  AND     dxcat.[DxCategoryEnd]
			LEFT OUTER JOIN [IMICodeStore].[dbo].[ICD9_DxSubCategory] dxsub
				ON clm.DiagnosisCode1 BETWEEN dxsub.[DxSubCategoryBegin]
									  AND     dxsub.[DxSubCategoryEnd]
		WHERE clm.Client = ISNULL(@vcClient,clm.client) 
			AND ISNULL(clm.DiagnosisCode1,'') <> ''
		GROUP BY prv.Npi,
			xp.NewPHOIndicator,
			LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			clm.DiagnosisCode1,
			dxcat.DxCategory,
			dxsub.DxSubCategory

	CREATE INDEX idx ON #NPI_Diagnosis (NPI, NewPHOIndicator, ServiceYearMonth, DiagnosisCode1)


END

--  DIAGNOSIS RELATED GROUP INFORMATION
BEGIN
	IF OBJECT_ID('tempdb..#PHO_DRG') IS NOT NULL
		DROP TABLE #PHO_DRG

	SELECT xp.NewPHOIndicator,
			ServiceYearMonth = LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			clm.[DiagnosisRelatedGroup],
			clm.[DiagnosisRelatedGroupType],
			drg.DRG_CD,
			drg.DRG_TYPE,
			drg.DRG_DESC,
			Units = SUM(cli.Units),
			ClaimCount = COUNT(DISTINCT cli.ClaimId),
			ClaimDetailLineCount = COUNT(DISTINCT cli.[ClaimLineItemID]),
			TotalNetPaid = SUM(cli.AmountNetPayment)
		INTO #PHO_DRG
		FROM [dbo].[Claim] clm
			INNER JOIN [dbo].[ClaimLineItem] cli
				ON clm.ClaimID = cli.ClaimID
			LEFT OUTER JOIN [dbo].[Provider] prv
				ON clm.ServicingProviderID = prv.ProviderID
			LEFT OUTER JOIN [IMICodeStore].[dbo].[DRG] drg
				ON drg.[DRG_CD] = clm.DiagnosisRelatedGroup
	        INNER JOIN BrXref_Provider xp
		        ON xp.ProviderID = clm.ServicingProviderID
		WHERE clm.Client = ISNULL(@vcClient,clm.client) 
			AND ISNULL(clm.DiagnosisRelatedGroup,'') <> ''
		GROUP BY xp.NewPHOIndicator,
			LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			clm.[DiagnosisRelatedGroup],
			clm.[DiagnosisRelatedGroupType],
			drg.DRG_CD,
			drg.DRG_TYPE,
			drg.DRG_DESC

	CREATE INDEX idx ON #PHO_DRG (NewPHOIndicator, ServiceYearMonth, DRG_CD)


	IF OBJECT_ID('tempdb..#NPI_DRG') IS NOT NULL
		DROP TABLE #NPI_DRG

	SELECT	prv.Npi,
			xp.NewPHOIndicator,
			ServiceYearMonth = LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			clm.[DiagnosisRelatedGroup],
			clm.[DiagnosisRelatedGroupType],
			drg.DRG_CD,
			drg.DRG_TYPE,
			drg.DRG_DESC,
			Units = SUM(cli.Units),
			ClaimCount = COUNT(DISTINCT cli.ClaimId),
			ClaimDetailLineCount = COUNT(DISTINCT cli.[ClaimLineItemID]),
			TotalNetPaid = SUM(cli.AmountNetPayment)
		INTO #NPI_DRG
		FROM [dbo].[Claim] clm
			INNER JOIN [dbo].[ClaimLineItem] cli
				ON clm.ClaimID = cli.ClaimID
			LEFT OUTER JOIN [dbo].[Provider] prv
				ON clm.ServicingProviderID = prv.ProviderID
			LEFT OUTER JOIN [IMICodeStore].[dbo].[DRG] drg
				ON drg.[DRG_CD] = clm.DiagnosisRelatedGroup
	        INNER JOIN BrXref_Provider xp
		        ON xp.ProviderID = clm.ServicingProviderID
		WHERE clm.Client = ISNULL(@vcClient,clm.client) 
			AND ISNULL(clm.DiagnosisRelatedGroup,'') <> ''
		GROUP BY prv.npi,
			xp.NewPHOIndicator,
			LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			clm.[DiagnosisRelatedGroup],
			clm.[DiagnosisRelatedGroupType],
			drg.DRG_CD,
			drg.DRG_TYPE,
			drg.DRG_DESC

	CREATE INDEX idx ON #NPI_DRG (NewPHOIndicator, ServiceYearMonth, DRG_CD)


END
-- Revenue Codes

BEGIN
	IF OBJECT_ID('tempdb..#revcodes') IS NOT NULL 
		DROP TABLE #revcodes
	
	SELECT rev.*
		INTO #revcodes
		FROM [IMICodeStore].[dbo].[UB04_RevenueCode] rev
			INNER JOIN (SELECT rev.Revenue_Code, 
							MaxCodeSet = MAX(rev.CodeSetVersion) 
						FROM [IMICodeStore].[dbo].[UB04_RevenueCode] rev
						GROUP BY rev.Revenue_Code
						) flt
				ON rev.Revenue_Code = flt.Revenue_Code
				AND rev.CodeSetVersion = flt.MaxCodeSet


	IF OBJECT_ID('tempdb..#PHO_RevCode') IS NOT NULL
		DROP TABLE #PHO_RevCode

	SELECT  xp.NewPHOIndicator,
			ServiceYearMonth = LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			cli.RevenueCode,
			rev.Revenue_Category,
			rev.Revenue_SubCategory,
			rev.Revenue_Description,
			Units = SUM(cli.Units),
			ClaimCount = COUNT(DISTINCT cli.ClaimId),
			ClaimDetailLineCount = COUNT(DISTINCT cli.[ClaimLineItemID]),
			TotalNetPaid = SUM(cli.AmountNetPayment)
		INTO #PHO_RevCode
		FROM [dbo].[ClaimLineItem] cli
			INNER JOIN [dbo].[Claim] clm
				ON clm.ClaimID = cli.ClaimID
			LEFT OUTER JOIN [dbo].[Provider] prv
				ON clm.ServicingProviderID = prv.ProviderID
	        LEFT OUTER JOIN #revcodes rev
		        ON SUBSTRING(rev.[Revenue_Code], 2, 3) = cli.RevenueCode
	        INNER JOIN BrXref_Provider xp
		        ON xp.ProviderID = clm.ServicingProviderID
		WHERE clm.Client = ISNULL(@vcClient,clm.client) 
			AND ISNULL(cli.CPTProcedureCode,'') <> ''
		GROUP BY xp.NewPHOIndicator,
			LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			cli.RevenueCode,
			rev.Revenue_Category,
			rev.Revenue_SubCategory,
			rev.Revenue_Description

	CREATE INDEX idx ON #PHO_RevCode (NewPHOIndicator, ServiceYearMonth)


	IF OBJECT_ID('tempdb..#NPI_RevCode') IS NOT NULL
		DROP TABLE #NPI_RevCode

	SELECT  prv.npi,
			xp.NewPHOIndicator,
			ServiceYearMonth = LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			cli.RevenueCode,
			rev.Revenue_Category,
			rev.Revenue_SubCategory,
			rev.Revenue_Description,
			Units = SUM(cli.Units),
			ClaimCount = COUNT(DISTINCT cli.ClaimId),
			ClaimDetailLineCount = COUNT(DISTINCT cli.[ClaimLineItemID]),
			TotalNetPaid = SUM(cli.AmountNetPayment)
		INTO #NPI_RevCode
		FROM [dbo].[ClaimLineItem] cli
			INNER JOIN [dbo].[Claim] clm
				ON clm.ClaimID = cli.ClaimID
			LEFT JOIN [dbo].[Provider] prv
				ON clm.ServicingProviderID = prv.ProviderID
	        LEFT JOIN #revcodes rev
		        ON SUBSTRING(rev.[Revenue_Code], 2, 3) = cli.RevenueCode
	        INNER JOIN BrXref_Provider xp
		        ON xp.ProviderID = clm.ServicingProviderID
		WHERE clm.Client = ISNULL(@vcClient,clm.client) 
			AND ISNULL(cli.CPTProcedureCode,'') <> ''
		GROUP BY prv.npi,
			xp.NewPHOIndicator,
			LEFT(CONVERT(VARCHAR(8),clm.DateServiceBegin,112),6),
			cli.RevenueCode,
			rev.Revenue_Category,
			rev.Revenue_SubCategory,
			rev.Revenue_Description

	CREATE INDEX idx ON #NPI_RevCode (npi, NewPHOIndicator, ServiceYearMonth)

END


IF @bMoveToProd = 1
BEGIN

	DECLARE @vcCmd VARCHAR(MAX)
	DECLARE @vcTab VARCHAR(100)

	DECLARE @tList TABLE (TabName VARCHAR(100))

	INSERT INTO @tList SELECT 'PHO_ProcedureCode'
	INSERT INTO @tList SELECT 'NPI_ProcedureCode'
	INSERT INTO @tList SELECT 'PHO_Diagnosis'
	INSERT INTO @tList SELECT 'NPI_Diagnosis'
	INSERT INTO @tList SELECT 'PHO_DRG'
	INSERT INTO @tList SELECT 'NPI_DRG'
	INSERT INTO @tList SELECT 'PHO_RevCode'
	INSERT INTO @tList SELECT 'NPI_RevCode'
	INSERT INTO @tList SELECT 'ClaimSummary'

	SELECT @vcTab = MIN(TabName)
		FROM @tList

	WHILE @vcTab IS NOT NULL 
	BEGIN

		SELECT @vcCmd = 'PHOREP.' + @vcTab
		IF OBJECT_ID(@vcCmd) IS NOT NULL 
		BEGIN
			SET @vcCmd = 'DROP TABLE ' + @vcCmd
			PRINT @vcCMd
			EXEC (@vcCmd)
		END
		SET @vcCmd= 'SELECT * INTO PHOREP.'+@vcTab + ' FROM #' + @vcTab
		PRINT @vcCmd
		EXEC (@vcCmd)

		SELECT @vcTab = MIN(TabName)
			FROM @tList
			WHERE TabName > @vcTab

	END



	



END




/*
--  OTHER CLAIM INFORMATION

IF OBJECT_ID('tempdb..#otherclaiminfo') IS NOT NULL
    DROP TABLE #otherclaiminfo

SELECT clm.[Client],
        cli.ClaimID,
        clm.MemberID,
        prv.NPI,
        clm.[ServicingProviderID],
        ServiceYear = DATEPART(YEAR, clm.[DateServiceBegin]),
        ServiceMonth = DATEPART(MONTH, clm.[DateServiceBegin]),
        clm.[DateServiceBegin],
        clm.[PlaceOfService],
        cli.[PlaceOfServiceCode],
        pos.PLACEOFSERVICE_SHORT_DESC,
        pos.PLACEOFSERVICE_LONG_DESC,
        cli.[RevenueCode],
        rev.Revenue_Description,
        rev.Revenue_Category,
        rev.Revenue_SubCategory,
        clm.[BillType],
        bt1.[TypeOfFacility],
        bt2.[BillClassification],
        cli.[TypeOfService],
        clm.[ClaimType],
        cli.DataSource,
        Units = SUM(cli.Units),
        ClaimItems = COUNT(DISTINCT cli.[ClaimLineItemID]),
        TotalNetPaid = SUM(cli.AmountNetPayment)
    INTO #otherclaiminfo
    FROM [dbo].[Claim] clm
        INNER JOIN [dbo].[ClaimLineItem] cli
            ON clm.ClaimID = cli.ClaimID
        LEFT OUTER JOIN [dbo].[Provider] prv
            ON clm.ServicingProviderID = prv.ProviderID
        LEFT OUTER JOIN [IMICodeStore].[dbo].[OTHER_PlaceOfService] pos
            ON pos.[PLACEOFSERVICE_CD] = cli.[PlaceOfServiceCode]
        LEFT OUTER JOIN [IMICodeStore].[dbo].[UB04_RevenueCode] rev
            ON SUBSTRING(rev.[Revenue_Code], 2, 3) = cli.RevenueCode
        LEFT OUTER JOIN [IMICodeStore].[nppes].BillTypeDigit1 bt1
            ON bt1.[BillTypeDigit1] = SUBSTRING(clm.[BillType], 1, 1)
        LEFT OUTER JOIN [IMICodeStore].[nppes].BillTypeDigit2 bt2
            ON bt2.[BillTypeDigit2] = SUBSTRING(clm.[BillType], 2, 1)
	WHERE clm.Client = 'CCI'
    GROUP BY clm.[Client],
        cli.ClaimID,
        clm.MemberID,
        prv.NPI,
        clm.[ServicingProviderID],
        clm.[DateServiceBegin],
        clm.[PlaceOfService],
        cli.[PlaceOfServiceCode],
        pos.PLACEOFSERVICE_SHORT_DESC,
        pos.PLACEOFSERVICE_LONG_DESC,
        cli.[RevenueCode],
        rev.Revenue_Description,
        rev.Revenue_Category,
        rev.Revenue_SubCategory,
        clm.[BillType],
        bt1.[TypeOfFacility],
        bt2.[BillClassification],
        cli.[TypeOfService],
        clm.[ClaimType],
        cli.DataSource

CREATE INDEX idxOtherNPI ON #otherclaiminfo (NPI)
CREATE INDEX idxOtherClaim ON #otherclaiminfo (Client, ClaimID)

*/

/*  NOTES

GROUP BY:
 City, AND SPECIALTY:in order, use SFHCP credentialing DB specialty, NPI DB, Pro-Health NPI list,
Attributed PCP, Procedure group DESCRIPTION, Service type (location): ip, home, SNF, etc., Facility name, DRG, DRG description, Claims category 1,
No. of office visits, admissions, etc. (unique combination of policy numb+service date+location?)
PHO Claims $ vs. Non-PHO claims (leakage), Services not offered

Weighted Avg risk:  need to be able to compare between providers, adjust $ as needed

Tasks
-	ON IMISQl15.STFran_IMIStaging_PROD
-	Look at the Encounter table for HEDIS markers.  Ask Michelle for help.
-	Look at the non standard values for CTP. 
o	Client    CPT code             count
o	CCI        COBC         15694
o	CCI        COBM         39100
o	CCI        INTER        3462
o	CCI        INVAL        9146
o	CCI        TAX          102


*/
GO
