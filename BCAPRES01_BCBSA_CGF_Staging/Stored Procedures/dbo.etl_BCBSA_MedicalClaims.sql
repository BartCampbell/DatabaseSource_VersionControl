SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*************************************************************************************
Procedure:	etl_BCBSA_MedicalClaims
Author:		Leon Dowling
Copyright:	© 2015
Date:		2015.10.17
Purpose:	To load BCBSA Provider data into Staging
Parameters:	@iLoadInstanceID	int.........IMIAdmin..ClientProcessInstance.LoadInstanceID
Depends On:	
Calls:		IMIAdmin..fxSetMetrics
			IMIAdmin..fxSetStatus
Called By:	dbo.IHDSBuildMaster
Returns:	None
Notes:		None
Process:	
Change Log:


Test Script:	
	
		truncate table claim
		truncate table claimlineitem

		EXEC dbo.etl_BCBSA_MedicalClaims 1
		
		SELECT DataSource, COUNT(*) 
			FROM dbo.Claim 
			GROUP BY DataSource 

		SELECT COUNT(*) FROM dbo.Claim 
		SELECT COUNT(*) FROM dbo.ClaimLineItem	

		select count(*) from RDSM.Claim a
			LEFT JOIN dbo.MedicalClaim_Rejected mcr
					ON mcr.RowID = a.RowID
					AND mcr.Client = 'BCBSA'
					AND mcr.SrcTabDB = 'BCBSA_RDSM'
					AND mcr.SrcTabSchema = 'BCBSA_GDIT'
					AND mcr.SrcTabName = 'Claim'
			WHERE mcr.RowID IS NULL

		SELECT count(*) from RDSM.Claim a
			LEFT JOIN dbo.MedicalClaim_Rejected mcr
					ON mcr.RowID = a.RowID
					AND mcr.Client = 'BCBSA'
					AND mcr.SrcTabDB = 'BCBSA_RDSM'
					AND mcr.SrcTabSchema = 'BCBSA_GDIT'
					AND mcr.SrcTabName = 'Claim'
			WHERE mcr.RowID IS NULL



ToDo:		

*************************************************************************************/

--/*
CREATE PROCEDURE [dbo].[etl_BCBSA_MedicalClaims] 
(
	@iLoadInstanceID        INT        
)
WITH RECOMPILE
AS
BEGIN TRY
--*/

--DECLARE @iLoadInstanceID INT = 1
/*************************************************************************************
        1.	Declare/initialize variables
*************************************************************************************/
DECLARE @iExpectedCnt INT
DECLARE @sysMe sysname

SET @sysMe = OBJECT_NAME(@@PROCID)

EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Started'

/*************************************************************************************
        2.  Delete temp tables if they already exist.
*************************************************************************************/
BEGIN 

	SELECT @iExpectedCnt = COUNT(*)
	FROM Claim

	--DELETE FROM dbo.Claim 
	--	WHERE Client = 'BCBSA'
	--		AND DataSource = 'BCBSA_GDIT.Claim'

    EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Deleted',
        @iExpectedCnt, 'etl_BCBSA_MedicalClaims', 'Claim', @iExpectedCnt

	TRUNCATE TABLE claim 

	SELECT @iExpectedCnt = COUNT(*)
		FROM Claimlineitem

    EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Deleted',
        @iExpectedCnt, 'etl_BCBSA_MedicalClaims', 'ClaimLineItem',
        @iExpectedCnt

  --  DELETE FROM dbo.ClaimLineItem 
		--WHERE Client = 'BCBSA'
		--	AND DataSource = 'BCBSA_GDIT.Claim'
	TRUNCATE TABLE dbo.ClaimLineItem

END 

/*************************************************************************************
		3.  Claim from BCBSA.MedicalClaimHeader
*************************************************************************************/
BEGIN 

	-- Claim HEader and Detail filter
	BEGIN

		TRUNCATE TABLE MedicalClaim_Rejected
		--DELETE FROM MedicalClaim_Rejected WHERE client = 'BCBSA'

		--INSERT INTO dbo.MedicalClaim_Rejected
		--        (Client,
		--         SrcTabDB,
		--         SrcTabSchema,
		--         SrcTabName,
		--         RowID,
		--         RowFileID,
		--         LoadInstanceID,
		--         LoadInstanceFileID,
		--         RejecteReason
		--        )
		--SELECT   
		--		 Client = 'BCBSA',
		--         SrcTabDB = 'BCBSA_RDSM',
		--         SrcTabSchema = 'BCBSA_GDIT',
		--         SrcTabName = 'Claim',
		--         RowID = a.Rowid,
		--         RowFileID = a.RowFileID,
		--         LoadInstanceID = a.LoadInstanceID,
		--         LoadInstanceFileID = a.LoadInstanceFileID,
		--         RejecteReason = 'Dup on ClaimNumber Or NULL'
		--	FROM RDSM.Claim a
		--		LEFT JOIN (SELECT ClaimNumber,
		--						MaxRowID = MAX(RowID)
		--					FROM RDSM.Claim
		--					GROUP BY ClaimNumber
		--					) b
		--			ON a.RowID = b.MaxRowID
		--	WHERE b.MaxRowID IS NULL
		--		OR a.ClaimNumber IS NULL



		INSERT INTO dbo.MedicalClaim_Rejected
		        (Client,
		         SrcTabDB,
		         SrcTabSchema,
		         SrcTabName,
		         RowID,
		         RowFileID,
		         LoadInstanceID,
		         LoadInstanceFileID,
		         RejecteReason
		        )
		SELECT 
				 Client = 'BCBSA',
		         SrcTabDB = 'BCBSA_RDSM',
		         SrcTabSchema = 'BCBSA_GDIT',
		         SrcTabName = 'Claim',
		         RowID = a.Rowid,
		         RowFileID = a.RowFileID,
		         LoadInstanceID = a.LoadInstanceID,
		         LoadInstanceFileID = a.LoadInstanceFileID,
		         RejecteReason = 'Member not in Member table'
			FROM RDSM.Claim a
				LEFT JOIN dbo.mpi_output_member mom
					ON mom.src_db_name = 'BCBSA_RDSM'
					AND mom.src_schema_name = 'BCBSA_GDIT'
					AND mom.src_table_name = 'Claim'
					AND mom.src_rowid = a.RowID
				LEFT JOIN Member m
					ON mom.ihds_member_id= m.ihds_member_id
				LEFT JOIN dbo.MedicalClaim_Rejected mcr
					ON mcr.RowID = a.RowID
					AND mcr.Client = 'BCBSA'
					AND mcr.SrcTabDB = 'BCBSA_RDSM'
					AND mcr.SrcTabSchema = 'BCBSA_GDIT'
					AND mcr.SrcTabName = 'Claim'
			WHERE m.MemberID IS NULL 
				AND mcr.RowID IS NULL 


		IF OBJECT_ID('tempdb..#ClaimFlt') IS NOT NULL 
			DROP TABLE #ClaimFlt

		SELECT 
				ClaimNumber,
				MaxRowID = MAX(a.RowID)
			INTO #ClaimFlt
			FROM RDSM.Claim a
				LEFT JOIN dbo.MedicalClaim_Rejected mcr
					ON mcr.RowID = a.RowID
					AND mcr.Client = 'BCBSA'
					AND mcr.SrcTabDB = 'BCBSA_RDSM'
					AND mcr.SrcTabSchema = 'BCBSA_GDIT'
					AND mcr.SrcTabName = 'Claim'
			WHERE mcr.RowID IS NULL 
			GROUP BY ClaimNumber

		CREATE INDEX idx1 ON #ClaimFlt (ClaimNumber, MaxRowID)
		CREATE STATISTICS spidx1 ON #ClaimFlt (ClaimNumber, MaxRowID)
		
		CREATE INDEX idx2 ON #ClaimFlt (MaxRowID)
		CREATE STATISTICS spidx2 ON #ClaimFlt (MaxRowID)    				

		--DELETE FROM MedicalClaim_Rejected
		--	WHERE Client = 'BCBSA'
		--    AND SrcTabDB = 'BCBSA_RDSM'
		--    AND SrcTabSchema = 'BCBSA_GDIT'
		--    AND SrcTabName = 'Claim'

		--INSERT INTO dbo.MedicalClaim_Rejected
		--        (Client,
		--         SrcTabDB,
		--         SrcTabSchema,
		--         SrcTabName,
		--         RowID,
		--         RowFileID,
		--         LoadInstanceID,
		--         LoadInstanceFileID,
		--         RejecteReason
		--        )
		--SELECT 
		--		 Client = 'BCBSA',
		--         SrcTabDB = 'BCBSA_RDSM',
		--         SrcTabSchema = 'BCBSA_GDIT',
		--         SrcTabName = 'Claim',
		--         RowID = cd.Rowid,
		--         RowFileID = cd.RowFileID,
		--         LoadInstanceID = cd.LoadInstanceID,
		--         LoadInstanceFileID = cd.LoadInstanceFileID,
		--         RejecteReason = mcr.RejecteReason
		--	FROM RDSM.Claim cd
		--		INNER JOIN MedicalClaim_Rejected mcr
		--			ON cd.RowID = mcr.RowID


		--SELECT srctabname, COUNT(*) FROM dbo.MedicalClaim_Rejected group BY SrcTabName

		IF OBJECT_ID('tempdb..#ClaimDtlFlt') IS NOT NULL 
			DROP TABLE #ClaimDtlFlt

		SELECT 
				a.RowID
			INTO #ClaimDtlFlt
			FROM RDSM.Claim a
				LEFT JOIN dbo.MedicalClaim_Rejected mcr
					ON mcr.RowID = a.RowID
					AND mcr.Client = 'BCBSA'
					AND mcr.SrcTabDB = 'BCBSA_RDSM'
					AND mcr.SrcTabSchema = 'BCBSA_GDIT'
					AND mcr.SrcTabName = 'Claim'
			WHERE mcr.RowID IS NULL 

		CREATE INDEX idx ON #ClaimDtlFlt (RowID)
		CREATE STATISTICS spcidx ON #ClaimDtlFlt (RowID)

	END

	--	Claim

	--	Min and Max Service Date 
    IF OBJECT_ID('tempdb..#MinMaxServDate') IS NOT NULL
        DROP TABLE #MinMaxServDate

    SELECT 
			PayerClaimID = mc.ClaimNumber,
            MinServBeginDate = MIN(ClaimFromDate),
            MaxServEndDate = MAX(ClaimThroughDate)
        INTO #MinMaxServDate
        FROM RDSM.Claim mc
            INNER JOIN #ClaimFlt c
                ON mc.RowID = c.MaxRowID
        GROUP BY mc.ClaimNumber

    CREATE INDEX fk ON #MinMaxServDate (PayerClaimID, MinServBeginDate, MaxServEndDate)
    CREATE STATISTICS sp ON #MinMaxServDate (PayerClaimID, MinServBeginDate, MaxServEndDate)

	
	---- ClaimStatus on MedicalClaimHeader was null.  Rule: if any line on MedicalClaimDetail is 1 THEN entire claim is 1
	--IF OBJECT_ID('tempdb..#ClaimStatus1') IS NOT NULL 
	--	DROP TABLE #ClaimStatus1
	
	--SELECT 
	--		ClaimNumber
	--	INTO #ClaimStatus1
	--	FROM RDSM.Claim mcd
	--	WHERE mcd.Denied = '1' --TODO Needs Review
	--	GROUP BY ClaimNumber

	--CREATE INDEX idx ON #ClaimStatus1 (ClaimNumber)
	--CREATE STATISTICS sp ON #ClaimStatus1 (ClaimNumber)


    INSERT INTO dbo.Claim (
				BillingProviderID,
				BillType,
				ClaimDisallowReason,
				ClaimType,
				ClaimTypeIndicator,
				ClaimStatus,
				Client,
				DataSource,
				DateClaimPaid,
				DateServiceBegin,
				DateServiceEnd,
				DiagnosisCode1,
				DiagnosisCode2,
				DiagnosisCode3,
				DiagnosisCode4,
				DiagnosisCode5,
				DiagnosisCode6,
				DiagnosisCode7,
				DiagnosisCode8,
				DiagnosisCode9,
				DiagnosisCode10,
				DiagnosisCode11,
				DiagnosisCode12,
				DiagnosisCode13,
				DiagnosisCode14,
				DiagnosisCode15,
				DiagnosisCode16,
				DiagnosisCode17,
				DiagnosisCode18,
				DiagnosisCode19,
				DiagnosisCode20,
				DischargeStatus,
				DiagnosisRelatedGroup,
				DiagnosisRelatedGroupType,
				HealthPlanID,
				HedisMeasureID,
				ihds_member_id,
				ihds_prov_id_attending,
				ihds_prov_id_billing,
				ihds_prov_id_med_group,
				ihds_prov_id_pcp,
				ihds_prov_id_referring,
				ihds_prov_id_servicing,
				ihds_prov_id_vendor,
				InstanceID,
				MedicarePaidIndicator,
				MemberID,
				PatientStatus,
				PayerClaimID,
				PayerClaimIDSuffix,
				PayerID,
				PlaceOfService,
				RecordType,
				ReferringProviderID,
				ServicingProviderID,
				SurgicalProcedure1,
				SurgicalProcedure2,
				SurgicalProcedure3,
				SurgicalProcedure4,
				SurgicalProcedure5,
				SurgicalProcedure6,
				SurgicalProcedure7,
				SurgicalProcedure8,
				SurgicalProcedure9,
				SurgicalProcedure10,
				SurgicalProcedure11,
				SurgicalProcedure12,
				SurgicalProcedure13,
				SurgicalProcedure14,
				SurgicalProcedure15,
				SurgicalProcedure16,
				SurgicalProcedure17,
				SurgicalProcedure18,
				SurgicalProcedure19,
				SurgicalProcedure20,
				LoadInstanceFileID,
				RowFileID,
				DateAdmitted,
				DateDischarged,
				rowid,
				MemberAge,
				CustomerMemberID,
				CustomerBillingProvID,
				CustomerServicingProvID,
				SupplementalDataCategory,
				SupplementalDataFlag,
				ICDCodeType,
				SupplementalDataCode
			)
        SELECT 
					BillingProviderID = NULL,
				BillType = mc.TypeBillCode,
					ClaimDisallowReason = NULL,
					ClaimType = NULL,
					ClaimTypeIndicator = NULL,
				ClaimStatus = CASE WHEN ISNULL(mc.Denied,'') = '' THEN 1 ELSE 2 END, --TODO Needs Review
				Client = 'BCBSA',
				DataSource = 'BCBSA_GDIT.Claim',
				DateClaimPaid = mc.ClaimProcessedDate,
				DateServiceBegin = mc.ClaimFromDate,
				DateServiceEnd = mc.ClaimThroughDate,
				DiagnosisCode1 = CASE WHEN LEN(mc.PrimaryDiagnosis) <= 10 THEN mc.PrimaryDiagnosis END,
				DiagnosisCode2  = mc.SecondaryDiagnosis1,
				DiagnosisCode3  = mc.SecondaryDiagnosis2,
				DiagnosisCode4  = mc.SecondaryDiagnosis3,
				DiagnosisCode5  = mc.SecondaryDiagnosis4,
				DiagnosisCode6  = mc.SecondaryDiagnosis5,
				DiagnosisCode7  = mc.SecondaryDiagnosis6,
				DiagnosisCode8  = mc.SecondaryDiagnosis7,
				DiagnosisCode9  = mc.SecondaryDiagnosis8,
				DiagnosisCode10 = mc.SecondaryDiagnosis9,
				DiagnosisCode11 = mc.SecondaryDiagnosis10,
				DiagnosisCode12 = mc.SecondaryDiagnosis11,
				DiagnosisCode13 = mc.SecondaryDiagnosis12,
				DiagnosisCode14 = mc.SecondaryDiagnosis13,
				DiagnosisCode15 = mc.SecondaryDiagnosis14,
				DiagnosisCode16 = mc.SecondaryDiagnosis15,
				DiagnosisCode17 = mc.SecondaryDiagnosis16,
				DiagnosisCode18 = mc.SecondaryDiagnosis17,
				DiagnosisCode19 = mc.SecondaryDiagnosis18,
				DiagnosisCode20 = mc.SecondaryDiagnosis19,
				DischargeStatus = mc.DischargeStatus,
				DiagnosisRelatedGroup = mc.DRGCode,
				DiagnosisRelatedGroupType = CASE mc.DRGVersion WHEN 32 THEN 'M' ELSE NULL END,
				HealthPlanID = (SELECT HealthPlanID FROM dbo.HealthPlan WHERE HealthPlanName = 'BCBSA'),
					HedisMeasureID = NULL,
				ihds_member_id = m.ihds_member_id,
					ihds_prov_id_attending = NULL,
					ihds_prov_id_billing = NULL,
					ihds_prov_id_med_group = NULL,
					ihds_prov_id_pcp = NULL,
					ihds_prov_id_referring = NULL,
				ihds_prov_id_servicing = ISNULL(p.ihds_prov_id,1),
					ihds_prov_id_vendor = NULL,
					InstanceID = NULL,
					MedicarePaidIndicator = NULL,
				MemberID = m.MemberID,
					PatientStatus = NULL,
				PayerClaimID = mc.ClaimNumber,
					PayerClaimIDSuffix = NULL,
					PayerID = NULL,
				PlaceOfService = mc.PlaceOfServiceCode,
					RecordType = NULL,
					ReferringProviderID = NULL,
				ServicingProviderID = ISNULL(p.ProviderID,noprov.ProviderID),
				SurgicalProcedure1 = mc.PrincipalProcedureCode,
				SurgicalProcedure2  = mc.OtherProcedureCode1,
				SurgicalProcedure3  = mc.OtherProcedureCode2,
				SurgicalProcedure4  = mc.OtherProcedureCode3,
				SurgicalProcedure5  = mc.OtherProcedureCode4,
				SurgicalProcedure6  = mc.OtherProcedureCode5,
				SurgicalProcedure7  = mc.OtherProcedureCode6,
				SurgicalProcedure8  = mc.OtherProcedureCode7,
				SurgicalProcedure9  = mc.OtherProcedureCode8,
				SurgicalProcedure10 = mc.OtherProcedureCode9,
				SurgicalProcedure11 = mc.OtherProcedureCode10,
				SurgicalProcedure12 = mc.OtherProcedureCode11,
				SurgicalProcedure13 = mc.OtherProcedureCode12,
				SurgicalProcedure14 = mc.OtherProcedureCode13,
				SurgicalProcedure15 = mc.OtherProcedureCode14,
				SurgicalProcedure16 = mc.OtherProcedureCode15,
				SurgicalProcedure17 = mc.OtherProcedureCode16,
				SurgicalProcedure18 = mc.OtherProcedureCode17,
				SurgicalProcedure19 = mc.OtherProcedureCode18,
				SurgicalProcedure20 = mc.OtherProcedureCode19,
				LoadInstanceFileID = mc.LoadInstanceFileID,
				RowFileID = mc.RowFileID,
				DateAdmitted = mc.AdmitDate,
				DateDischarged = mc.DischargeDate,
				rowid = mc.RowID,
				MemberAge = NULL,
				CustomerMemberID = mc.MemberID,
				CustomerBillingProvID = NULL,
				CustomerServicingProvID = mc.ProviderID,
				SupplementalDataCategory = SupplementalDataSource,
				SupplementalDataFlag = CASE WHEN ISNULL(SupplementalDataSource,'') <> '' THEN 'Y' ELSE 'N' END,
				ICDCodeType = CASE WHEN mc.DiagnosisVersionCode = '9' THEN '9' ELSE '10' END,
				SupplementalDataCode = NULL
			--select count(*)
            FROM RDSM.Claim mc
                INNER JOIN #ClaimFlt mx
                    ON mx.MaxRowID = mc.RowID
				INNER JOIN dbo.mpi_output_member mom
					ON mom.src_db_name = 'BCBSA_RDSM'
					AND mom.src_schema_name = 'BCBSA_GDIT'
					AND mom.src_table_name = 'Claim'
					AND mom.src_rowid = mc.RowID
                INNER JOIN Member m
                    ON mom.ihds_member_id = m.ihds_member_id
                 JOIN dbo.mpi_output_provider mop
					ON mop.src_db_name = 'BCBSA_RDSM'
					AND mop.src_schema_name = 'BCBSA_GDIT'
					AND mop.src_table_name = 'Claim'
					AND mop.src_rowid = mc.RowID
				JOIN Provider p
                    ON mop.ihds_prov_id_servicing = p.ihds_prov_id
				--LEFT JOIN #ClaimStatus1 cs1
				--	ON cs1.ClaimNumber = mc.ClaimNumber
                INNER JOIN #MinMaxServDate mmsd
                    ON mc.ClaimNumber = mmsd.PayerClaimID
				INNER JOIN (SELECT TOP 1 ProviderID FROM provider WHERE ihds_prov_id = 1) noprov
					ON 1 = 1


    EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted',
        @@ROWCOUNT, 'etl_BCBSA_MedicalClaims', 'Claim',
        @@ROWCOUNT


END 

/*************************************************************************************
		4.  ClaimLineItem from 
				BCBSA.MedicalClaimDetail 
*************************************************************************************/
BEGIN 

    INSERT INTO dbo.ClaimLineItem
            (
			AmountGrossPayment,
			ClaimID,
			LineItemNumber,
			ClaimStatus,
			AmountCOBSavings,
			AmountCopay,
			AmountDisallowed,
			AmountMedicarePaid,
			AmountNetPayment,
			AmountTotalCharge,
			AmountWithold,
			Client,
			DataSource,
			DateAdjusted,
			DatePaid,
			DateServiceBegin,
			DateServiceEnd,
			DiagnosisCode,
			CPTProcedureCode,
			CPTProcedureCodeModifier1,
			CPTProcedureCodeModifier2,
			CPTProcedureCodeModifier3,
			CPTProcedureCodeModifier4,
			HedisMeasureID,
			PlaceOfServiceCode,
			PlaceOfServiceCodeIndicator,
			RevenueCode,
			SubNumber,
			TypeOfService,
			Units,
			CoveredDays,
			CPT_II,
			HCPCSProcedureCode,
			ClaimDisallowReason,
			LoadInstanceFileID,
			RowFileID,
			PayClaimID,
			PayClaimLineID,
			RowID,
			PaymentStatus,
			PayerClaimID,
			PayerClaimLineID
			)
        SELECT 
				AmountGrossPayment = NULL,
			ClaimID = c.ClaimID,
				LineItemNumber =  CASE WHEN ISNUMERIC(mcd.ClaimLineNumber) = 0 THEN 999 ELSE CONVERT(SMALLINT, mcd.ClaimLineNumber) END, --TODO: Needs Review
			ClaimStatus = CASE WHEN ISNULL(Denied,'') = '' THEN 1 ELSE 2 END , --TODO Needs Review
				AmountCOBSavings = NULL,
				AmountCopay = NULL,
				AmountDisallowed = NULL,
				AmountMedicarePaid = NULL,
				AmountNetPayment = NULL,
				AmountTotalCharge = NULL,
				AmountWithold = NULL,
			Client = 'BCBSA',
			DataSource = 'BCBSA_GDIT.Claim',
				DateAdjusted = NULL,
			DatePaid = mcd.ClaimProcessedDate,
            DateServiceBegin = mcd.ClaimFromDate,
            DateServiceEnd = mcd.ClaimThroughDate,
			DiagnosisCode = mcd.PrimaryDiagnosis,
			CPTProcedureCode = CASE WHEN mcd.LineProcedureCode LIKE '[0-9][0-9][0-9][0-9][0-9]' THEN mcd.LineProcedureCode END, 
			CPTProcedureCodeModifier1 = mcd.LineProcedureCodeModifier,
			CPTProcedureCodeModifier2 = mcd.LineProcedureCodeModifier2,
			CPTProcedureCodeModifier3 = mcd.LineProcedureCodeModifier3,
			CPTProcedureCodeModifier4 = mcd.LineProcedureCodeModifier4,
				HedisMeasureID = NULL,
			PlaceOfServiceCode = mcd.PlaceOfServiceCode,
				PlaceOfServiceCodeIndicator = NULL,
            RevenueCode = mcd.RevenueCode,
				SubNumber = NULL,
				TypeOfService = NULL,
			Units = CASE WHEN RTRIM(LTRIM(mcd.Units)) <> '.' THEN CONVERT(NUMERIC(15,7),mcd.Units) ELSE 0.0 END,
            CoveredDays = CASE WHEN RevenueCode BETWEEN '0100' AND '0220'
								AND ISNULL(Denied,'') = ''
								THEN DATEDIFF(day,mcd.FirstServiceDate,mcd.LastServiceDate)
								ELSE 0 
								END,
			CPT_II = CASE WHEN mcd.LineProcedureCode LIKE '[0-9][0-9][0-9][0-9][A-Z]' THEN mcd.LineProcedureCode END, 
			HCPCSProcedureCode = CASE WHEN mcd.LineProcedureCode LIKE '[A-Z][0-9][0-9][0-9][0-9]' THEN mcd.LineProcedureCode END, 
				ClaimDisallowReason = NULL,
			LoadInstanceFileID = mcd.LoadInstanceFileID,
			RowFileID = mcd.RowFileID,
			PayClaimID = ClaimNumber,
			PayClaimLineID = ClaimLineNumber,
			RowID = mcd.RowID,
				PaymentStatus = NULL,
			PayerClaimID = mcd.ClaimNumber,
			PayerClaimLineID =  mcd.ClaimNumber + '~' + mcd.ClaimLineNumber
			--	SELECT COUNT(*), count(*), count(distinct mcd.rowid)
			FROM RDSM.Claim mcd
				INNER JOIN #ClaimDtlFlt cdf
					ON mcd.rowid = cdf.RowID
                INNER JOIN dbo.Claim c
                    ON c.DataSource = 'BCBSA_GDIT.Claim'
					AND c.PayerClaimID = mcd.ClaimNumber

    EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted',
        @@ROWCOUNT, 'etl_BCBSA_MedicalClaims', 'ClaimLineItem',
        @@ROWCOUNT


END 
		
/*************************************************************************************
         5. Delete temp tables if they already exist.

*************************************************************************************/
IF OBJECT_ID('tempdb..#MaxClaim') IS NOT NULL
    DROP TABLE #MaxClaim
IF OBJECT_ID('tempdb..#ClaimFlt') IS NOT NULL 
	DROP TABLE #ClaimFlt
IF OBJECT_ID('tempdb..#ClaimDtlFlt') IS NOT NULL 
	DROP TABLE #ClaimDtlFlt
IF OBJECT_ID('tempdb..#MinMaxServDate') IS NOT NULL
	DROP TABLE #MinMaxServDate
IF OBJECT_ID('tempdb..#ClaimStatus1') IS NOT NULL 
	DROP TABLE #ClaimStatus1
	
EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Completed'

--/*
END TRY

BEGIN CATCH
        DECLARE @iErrorLine		int,
                @iErrorNumber		int,
                @iErrorSeverity		int,
                @iErrorState		int,
                @nvcErrorMessage	nvarchar( 2048 ), 
                @nvcErrorProcedure	nvarchar( 126 )

        -- capture error info so we can fail it up the line
        SELECT	@iErrorLine = ERROR_LINE(),
                @iErrorNumber = ERROR_NUMBER(),
                @iErrorSeverity = ERROR_SEVERITY(),
                @iErrorState = ERROR_STATE(),
                @nvcErrorMessage = ERROR_MESSAGE(),
                @nvcErrorProcedure = ERROR_PROCEDURE()

        INSERT INTO IMIAdmin..ErrorLog( ErrorLine, ErrorMessage, ErrorNumber, ErrorProcedure, ErrorSeverity,
                ErrorState, ErrorTime, InstanceID, UserName )
        SELECT	@iErrorLine, @nvcErrorMessage, @iErrorNumber, @nvcErrorProcedure, @iErrorSeverity,
                @iErrorState, GETDATE(), InstanceID, SUSER_SNAME()
        FROM	IMIAdmin..ClientProcessInstance
        WHERE	LoadInstanceID = @iLoadInstanceID

        PRINT	'Error Procedure: ' + @sysMe
        PRINT	'Error Line:      ' + CAST( @iErrorLine AS varchar( 12 ))
        PRINT	'Error Number:    ' + CAST( @iErrorNumber AS varchar( 12 ))
        PRINT	'Error Message:   ' + @nvcErrorMessage
        PRINT	'Error Severity:  ' + CAST( @iErrorSeverity AS varchar( 12 ))
        PRINT	'Error State:     ' + CAST( @iErrorState AS varchar( 12 ))

        EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Failed'

        RAISERROR( @nvcErrorMessage, @iErrorSeverity, @iErrorState );
END CATCH
--*/



GO
