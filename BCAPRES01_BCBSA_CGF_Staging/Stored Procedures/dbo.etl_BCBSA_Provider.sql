SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	etl_BCBSA_Provider
Author:		Tom Sharn
Copyright:	© 2015
Date:		2015.10.16
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
3/30/2017 - Leon - Update for RDSM schema
Test Script:	
	
		EXEC dbo.etl_BCBSA_Provider 1

		SELECT count(*), count(distinct ihds_prov_id) FROM dbo.Provider WHERE Client = 'BCBSA'		--	21612

		SELECT count(*) FROM mpi_output_provider WHERE ClientID = 'BCBSA'

		SELECT CLIENT, DataSource, count(*) FROM mpi_output_provider WHERE CLIENTID = 'BCBSA' group by CLIENT, DataSource order by CLIENT, DataSource

		SELECT src_table_name, COUNT(*) FROM DBO.mpi_pre_load_prov group by src_table_name
		SELECT COUNT(*) FROM DBO.mpi_pre_load_dtl_prov

		select  count(1) from provider
ToDo:		


*************************************************************************************/
--/*
CREATE PROCEDURE [dbo].[etl_BCBSA_Provider] 
(
	@iLoadInstanceID        INT        -- IMIAdmin..ClientProcessInstance.LoadInstanceID
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
IF OBJECT_ID('tempdb..#BCBSA') IS NOT NULL
    DROP TABLE #BCBSA

        
/*************************************************************************************
        3.  EXECUTE override_sql.
            Clean up existing rows prior to load.
*************************************************************************************/
BEGIN 
    TRUNCATE TABLE dbo.Provider

     
END 


/*************************************************************************************
			
		4.  Provider records from 


*************************************************************************************/
--Spec Xref
BEGIN

	IF OBJECT_ID('tempdb..#SpeXref') IS NOT NULL 
		DROP TABLE #SpeXref

	SELECT DISTINCT ProviderSpecialtyID, 
		AmbulanceFlag		= CASE WHEN ProviderSpecialtyID IN ('58 Ambulance Service Provider',
																'59 Ambulance Service Provider') 
														THEN 'Y' 
														ELSE 'N' 
														END,
		AnesthesiologistFlag= CASE WHEN ProviderSpecialtyID IN ('05 Anesthesiology',
																'AK Anesthesiology Critical Care Medicine',
																'EN Anesthesiology Pain Management') 
														THEN 'Y' 
														ELSE 'N' 
														END,
		ClinicalPharmacistFlag=  'N',
		DentistFlag			= CASE WHEN ProviderSpecialtyID IN ('BG General Practice Dentistry') 
														THEN 'Y' 
														ELSE 'N' 
														END,
		DurableMedEquipmentFlag= CASE WHEN ProviderSpecialtyID IN ('CQ DME Supplier') 
														THEN 'Y' 
														ELSE 'N' 
														END,
		EyeCareFlag			= CASE WHEN ProviderSpecialtyID IN ('CE Optometrist',
																'41 Optometrist') 
														THEN 'Y' 
														ELSE 'N' 
														END,
		HospitalFlag		=  'N',
		MentalHealthFlag	= CASE WHEN ProviderSpecialtyID IN ('FA Mental Health Clinician') 
														THEN 'Y' 
														ELSE 'N' 
														END,
		NephrologistFlag	= CASE WHEN ProviderSpecialtyID IN ('39 Nephrology') 
														THEN 'Y' 
														ELSE 'N' 
														END,
		NursePractFlag		= CASE WHEN ProviderSpecialtyID IN ('RX Nurse Practitioner',
															'RZ Nurse Practitioner - Adult Health',
															'SB Nurse Practitioner - Critical Care Medicine',
															'SC Nurse Practitioner - Family',
															'SE Nurse Practitioner - Neonatal',
															'SL Nurse Practitioner - Psychiatric/Mental Health',
															'') 
														THEN 'Y' 
														ELSE 'N' 
														END,
		OBGynFlag			= CASE WHEN ProviderSpecialtyID IN ('16 Ob-Gynecology') 
														THEN 'Y' 
														ELSE 'N' 
														END,
		PhysicianAsstFlag	= CASE WHEN ProviderSpecialtyID IN ('CZ Physician Assistant',
															'97 Physician Assistant') 
														THEN 'Y' 
														ELSE 'N' 
														END,
		PCPFlag				= CASE WHEN ProviderSpecialtyID IN ('08 Family Practice',
															'JB Family Practice - Adult Medicine',
															'AN Family Practice Geriatric Medicine',
															'EQ Family Practice Sports Medicine',
															'01 General Practice',
															'') 
														THEN 'Y' 
														ELSE 'N' 
														END,
		ProviderPrescribingPrivFlag= 'N',
		RegisteredNurseFlag = CASE WHEN ProviderSpecialtyID IN ('NR Registered Nurse - College Health',
															'NU Registered Nurse - Critical Care Medicine',
															'OA Registered Nurse - Gerontology',
															'OE Registered Nurse - Infusion Therapy',
															'OF Registered Nurse - Lactation Consultant',
															'OH Registered Nurse - Medical-Surgical',
															'OI Registered Nurse - Neonatal Intensive Care',
															'OP Registered Nurse - Obstetric, Inpatient',
															'OT Registered Nurse - Ostomy Care',
															'OU Registered Nurse - Otorhinolayngology & Head-Ne',
															'OV Registered Nurse - Pain Management',
															'OX Registered Nurse - Pediatrics',
															'PA Registered Nurse - Psychiatric/Mental Health, A',
															'PD Registered Nurse - Reproductive Endocrinology/I',
															'PF Registered Nurse - Urology',
															'PH Registered Nurse - Wound Care') 
														THEN 'Y' 
														ELSE 'N' 
														END,
		SkilledNursingFacFlag= CASE WHEN ProviderSpecialtyID IN ('GU Skilled Nursing Facility') 
														THEN 'Y' 
														ELSE 'N' 
														END,
		SurgeonFlag			= 'N'
	INTO #SpeXref
	FROM RDSM.ProviderSpecialty spec 
	WHERE CHARINDEX('invalid',spec.ProviderSpecialtyID) = 0


	IF OBJECT_ID('tempdb..#ProvSpec') IS NOT NULL 
		DROP TABLE #ProvSpec

	SELECT p.ProviderId,
			AmbulanceFlag = MAX(ISNULL(x.AmbulanceFlag,'N')),
			AnesthesiologistFlag = MAX(ISNULL(x.AnesthesiologistFlag ,'N')),
			ClinicalPharmacistFlag  =  MAX(ISNULL(x.ClinicalPharmacistFlag ,'N')),
			DentistFlag =  MAX(ISNULL(x.DentistFlag ,'N')),
			DurableMedEquipmentFlag =  MAX(ISNULL(x.DurableMedEquipmentFlag ,'N')),
			EyeCareFlag =  MAX(ISNULL(x.EyeCareFlag ,'N')),
			HospitalFlag =  MAX(ISNULL(x.HospitalFlag ,'N')),
			MentalHealthFlag =  MAX(ISNULL(x.MentalHealthFlag ,'N')),
			NephrologistFlag =  MAX(ISNULL(x.NephrologistFlag ,'N')),
			NursePractFlag =  MAX(ISNULL(x.NursePractFlag ,'N')),
			OBGynFlag =  MAX(ISNULL(x.OBGynFlag ,'N')),
			PhysicianAsstFlag =  MAX(ISNULL(x.PhysicianAsstFlag ,'N')),
			PCPFlag =  MAX(ISNULL(x.PCPFlag ,'N')),
			ProviderPrescribingPrivFlag =  MAX(ISNULL(x.ProviderPrescribingPrivFlag ,'N')),
			RegisteredNurseFlag =  MAX(ISNULL(x.RegisteredNurseFlag ,'N')),
			SkilledNursingFacFlag =  MAX(ISNULL(x.SkilledNursingFacFlag ,'N')),
			SurgeonFlag =  MAX(ISNULL(x.SurgeonFlag, 'N'))
		INTO #ProvSpec
		FROM rdsm.ProviderSpecialty p
			INNER JOIN #SpeXref x
				ON p.ProviderSpecialtyID = x.ProviderSpecialtyID
		GROUP BY p.ProviderId

END


BEGIN 

	IF OBJECT_ID('tempdb..#max_prov') IS NOT NULL 
		DROP TABLE #max_prov

    SELECT ihds_prov_id = mop.ihds_prov_id_servicing,
            RowID = MAX(pm.RowID)
        INTO #max_prov
        FROM RDSM.Provider pm
            INNER JOIN dbo.mpi_output_provider mop
                ON 'BCBSA' = mop.clientid
                   AND 'Provider' = mop.src_table_name
                   AND 'BCBSA_RDSM' = mop.src_db_name
                   AND 'BCBSA_GDIT' = mop.src_schema_name
                   AND pm.RowID = mop.src_rowid
        GROUP BY mop.ihds_prov_id_servicing

    SET @iExpectedCnt = 0

    SELECT @iExpectedCnt = COUNT(*)
        FROM RDSM.Provider pm
            JOIN #max_prov mp
                ON pm.RowID = mp.RowID 

				--	Insert into Provider table 
    INSERT INTO dbo.Provider (
				Client,
				DataSource,
				DateRowCreated,
				ihds_prov_id,
				NameFirst,
				NameLast,
				NameMiddleInitial,
				NameSuffix,
				NPI,
				ProviderType,
				RowID,
				ProviderPrescribingPrivFlag,
				CDProviderFlag,
				DentistFlag,
				EyeCareFlag,
				MentalHealthFlag,
				NephrologistFlag,
				NursePractFlag,
				OBGynFlag,
				PCPFlag,
				PhysicianAsstFlag,
				ProviderPaidInpatientRateFlag,
				ProviderPaidOutpatientRateFlag,
				CustomerProviderID,
				ClinicalPharmacistFlag,
				AnesthesiologistFlag,
				ProviderFullName,
				AmbulanceFlag,
				DMEFlag,
				HospitalFlag,
				SNFFlag,
				Address1,
				Address2,
				City,
				State,
				Zip,
				Phone,
				Fax,
				DurableMedEquipmentFlag,
				RegisteredNurseFlag,
				SkilledNursingFacFlag,
				SurgeonFlag,
				CardiologistFlag,
				GastroenterologistFlag,
				EndocrinologistFlag,
				ProviderCounty,
				ProviderEmail		
            )
        SELECT
				Client = 'BCBSA',
				DataSource = 'BCBSA_GDIT.Provider',
				DateRowCreated = CONVERT(VARCHAR(8), GETDATE(), 112),
				ihds_prov_id = mp.ihds_prov_id,
				NameFirst = p.ProviderFirstName,
				NameLast = p.ProviderLastName,
				NameMiddleInitial = p.ProviderMiddleInitial,
				NameSuffix = p.ProviderNameSuffix,
				NPI = p.ProviderNPI,
				ProviderType = p.TypeID,
				RowID = p.RowID,
				ProviderPrescribingPrivFlag = ISNULL(p.Prescribing,'N'),
				CDProviderFlag = 'N',
				DentistFlag = ISNULL(sp.DentistFlag,'N'),
				EyeCareFlag = ISNULL(sp.EyeCareFlag,'N'),
				MentalHealthFlag = ISNULL(sp.MentalHealthFlag,'N'),
				NephrologistFlag = ISNULL(sp.NephrologistFlag,'N'),
				NursePractFlag = ISNULL(sp.NursePractFlag,'N'),
				OBGynFlag = ISNULL(sp.OBGynFlag,'N'),
				PCPFlag = ISNULL(sp.PCPFlag,'N'),
				PhysicianAsstFlag = ISNULL(sp.PhysicianAsstFlag,'N'),
				ProviderPaidInpatientRateFlag = 'N',
				ProviderPaidOutpatientRateFlag = 'N',
				CustomerProviderID = p.ProviderID,
				ClinicalPharmacistFlag = ISNULL(sp.ClinicalPharmacistFlag,'N'),
				AnesthesiologistFlag = ISNULL(sp.AnesthesiologistFlag,'N'),
				ProviderFullName = p.ProviderLastName + CASE when ISNULL(p.ProviderFirstName,'') = '' THEN ''
															ELSE ', ' + p.ProviderFirstName
															END,
				AmbulanceFlag = ISNULL(sp.AmbulanceFlag,'N'),
				DMEFlag = ISNULL(sp.DurableMedEquipmentFlag,'N'),
				HospitalFlag = ISNULL(SP.HospitalFlag,'N'),
				SNFFlag = ISNULL(sp.SkilledNursingFacFlag,'N'),
				Address1 = p.ProviderAddress1,
				Address2 = p.ProviderAddress2,
				City = p.ProviderCity,
				State = p.ProviderState,
				Zip = p.ProviderZipCode,
				Phone = p.ProviderTelephone,
				Fax = p.ProviderFax,
				DurableMedEquipmentFlag = ISNULL(sp.DurableMedEquipmentFlag,'N'),
				RegisteredNurseFlag = ISNULL(sp.RegisteredNurseFlag,'N'),
				SkilledNursingFacFlag = ISNULL(sp.SkilledNursingFacFlag,'N'),
				SurgeonFlag = ISNULL(sp.SurgeonFlag,'N'),
				CardiologistFlag = 'N',
				GastroenterologistFlag = 'N',
				EndocrinologistFlag = 'N',
				ProviderCounty = p.ProviderCounty,
				ProviderEmail = p.ProviderEmail
            FROM RDSM.Provider p
                JOIN #max_prov mp
                    ON p.RowID = mp.RowID 
				LEFT JOIN #ProvSpec sp
					ON p.ProviderID = sp.ProviderID
			
    EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted',
        @@ROWCOUNT, 'etl_BCBSA_Provider', 'Provider : FROM BCBSA_GDIT2017.Provider ',
        @iExpectedCnt

END 

/* -- each provider in the medical claim should be in the RDSM.Provider table.  We will need to confirm
BEGIN 

	IF OBJECT_ID('tempdb..#max_claim') IS NOT NULL 
		DROP TABLE #max_claim

    SELECT ihds_prov_id = mop.ihds_prov_id_servicing,
            RowID = MAX(ch.RowID)
        INTO #max_claim
				--	SELECT COUNT(*)
        FROM RDSM.ClaimInOutPatient CH
            INNER JOIN dbo.mpi_output_provider mop
                ON 'BCBSA' = mop.clientid
                   AND 'ClaimInOutPatient' = mop.src_table_name
                   AND 'BCBSA_RDSM' = mop.src_db_name
                   AND 'BCBSA_GDIT2017' = mop.src_schema_name
                   AND ch.RowID = mop.src_rowid
			LEFT JOIN Provider p
				ON mop.ihds_prov_id_servicing = p.ihds_prov_id
		WHERE p.ihds_prov_id IS NULL 
        GROUP BY mop.ihds_prov_id_servicing

    SET @iExpectedCnt = 0

    SELECT @iExpectedCnt = COUNT(*)
        FROM RDSM.ClaimInOutPatient pm
            JOIN #max_claim mp
                ON pm.RowID = mp.RowID 

				--	Insert into Provider table 
    INSERT INTO BCBSA_CGF_Staging.dbo.Provider (
				BoardCertification1,
				BoardCertification2,
				Client,
				DataSource,
				DateOfBirth,
				DateRowCreated,
				DateValidBegin,
				DateValidEnd,
				DEANumber,
				EIN,
				Gender,
				HashValue,
				HedisMeasureID,
				ihds_prov_id,
				InstanceID,
				IsUpdated,
				LicenseNumber,
				MedicaidID,
				NameFirst,
				NameLast,
				NameMiddleInitial,
				NamePrefix,
				NameSuffix,
				NameTitle,
				NetworkID,
				NPI,
				ProviderType,
				RowID,
				SpecialtyCode1,
				SpecialtyCode2,
				SSN,
				TaxID,
				UPIN,
				ProviderPrescribingPrivFlag,
				CDProviderFlag,
				DentistFlag,
				EyeCareFlag,
				MentalHealthFlag,
				NephrologistFlag,
				NursePractFlag,
				OBGynFlag,
				PCPFlag,
				PhysicianAsstFlag,
				ProviderPaidInpatientRateFlag,
				ProviderPaidOutpatientRateFlag,
				CustomerProviderID,
				ClinicalPharmacistFlag,
				AnesthesiologistFlag,
				ProviderFullName,
				SpecialtyCode1Desc,
				SpecialtyCode2Desc,
				AmbulanceFlag,
				DMEFlag,
				HospitalFlag,
				SNFFlag,
				Address1,
				Address2,
				City,
				State,
				Zip,
				Phone,
				Fax,
				DurableMedEquipmentFlag,
				RegisteredNurseFlag,
				SkilledNursingFacFlag,
				SurgeonFlag,
				Contracted,
				CardiologistFlag,
				GastroenterologistFlag,
				EndocrinologistFlag,
				LicenseNumberState,
				MedicareID,
				NetworkDesc,
				ProviderCounty,
				ProviderEmail,
				ProviderPracticeSite,
				TaxonomyCode,
				UserDefinedField,
				UserDefinedFieldDesc				
            )
        SELECT
					BoardCertification1 = NULL,
					BoardCertification2 = NULL,
				Client = 'BCBSA',
				DataSource = 'BCBSA_GDIT2017.ClaimInOutPatient',
					DateOfBirth = NULL,
				DateRowCreated = CONVERT(VARCHAR(8), GETDATE(), 112),
					DateValidBegin = NULL,
					DateValidEnd = NULL,
					DEANumber = NULL,
					EIN = NULL,
					Gender = NULL,
					HashValue = NULL,
					HedisMeasureID = NULL,
				ihds_prov_id = mc.ihds_prov_id,
					InstanceID = NULL,
					IsUpdated = NULL,
					LicenseNumber = NULL,
					MedicaidID = NULL,
					NameFirst = NULL,
				NameLast = 'Unknown Provider: ' + ch.ProviderID,
					NameMiddleInitial = NULL,
					NamePrefix = NULL,
					NameSuffix = NULL,
					NameTitle = NULL,
					NetworkID = NULL,
					NPI = NULL,
					ProviderType = NULL,
					RowID = NULL,
					SpecialtyCode1 = NULL,
					SpecialtyCode2 = NULL,
					SSN = NULL,
					TaxID = NULL,
					UPIN = NULL,
				ProviderPrescribingPrivFlag  = 'N',
				CDProviderFlag  = 'N',
				DentistFlag  = 'N',
				EyeCareFlag  = 'N',
				MentalHealthFlag  = 'N',
				NephrologistFlag  = 'N',
				NursePractFlag  = 'N',
				OBGynFlag  = 'N',
				PCPFlag  = 'N',
				PhysicianAsstFlag  = 'N',
				ProviderPaidInpatientRateFlag  = 'N',
				ProviderPaidOutpatientRateFlag  = 'N',
				CustomerProviderID = ch.ProviderID,
				ClinicalPharmacistFlag  = 'N',
				AnesthesiologistFlag  = 'N',
				ProviderFullName = 'Unknown Provider: '+ch.ProviderID,
					SpecialtyCode1Desc = NULL,
					SpecialtyCode2Desc = NULL,
				AmbulanceFlag  = 'N',
				DMEFlag  = 'N',
				HospitalFlag  = 'N',
				SNFFlag  = 'N',
					Address1 = NULL,
					Address2 = NULL,
					City = NULL,
					State = NULL,
					Zip = NULL,
					Phone = NULL,
					Fax = NULL,
				DurableMedEquipmentFlag  = 'N',
				RegisteredNurseFlag  = 'N',
				SkilledNursingFacFlag  = 'N',
				SurgeonFlag  = 'N',
					Contracted = NULL,
				CardiologistFlag  = 'N',
				GastroenterologistFlag  = 'N',
				EndocrinologistFlag  = 'N',
					LicenseNumberState = NULL,
					MedicareID = NULL,
					NetworkDesc = NULL,
					ProviderCounty = NULL,
					ProviderEmail = NULL,
					ProviderPracticeSite = NULL,
					TaxonomyCode = NULL,
					UserDefinedField = NULL,
					UserDefinedFieldDesc = NULL
            FROM RDSM.ClaimInOutPatient ch
                JOIN #max_claim mc
                    ON ch.RowID = mc.RowID 
			
    EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted',
        @@ROWCOUNT, 'etl_BCBSA_Provider', 'Provider : FROM BCBSA_GDIT2017.MedicalClaimHeader',
        @iExpectedCnt

END 
*/


IF NOT EXISTS (SELECT * FROM provider WHERE ihds_prov_id = 1)
BEGIN

    INSERT INTO BCBSA_CGF_Staging.dbo.Provider (
				Client,
				DataSource,
				DateRowCreated,
				ihds_prov_id,
				NameFirst,
				NameLast,
				NameMiddleInitial,
				NameSuffix,
				NPI,
				ProviderType,
				RowID,
				ProviderPrescribingPrivFlag,
				CDProviderFlag,
				DentistFlag,
				EyeCareFlag,
				MentalHealthFlag,
				NephrologistFlag,
				NursePractFlag,
				OBGynFlag,
				PCPFlag,
				PhysicianAsstFlag,
				ProviderPaidInpatientRateFlag,
				ProviderPaidOutpatientRateFlag,
				CustomerProviderID,
				ClinicalPharmacistFlag,
				AnesthesiologistFlag,
				ProviderFullName,
				AmbulanceFlag,
				DMEFlag,
				HospitalFlag,
				SNFFlag,
				Address1,
				Address2,
				City,
				State,
				Zip,
				Phone,
				Fax,
				DurableMedEquipmentFlag,
				RegisteredNurseFlag,
				SkilledNursingFacFlag,
				SurgeonFlag,
				CardiologistFlag,
				GastroenterologistFlag,
				EndocrinologistFlag,
				ProviderCounty,
				ProviderEmail
            )
        SELECT
				Client = 'BCBSA',
				DataSource = 'PHC.Provider',
				DateRowCreated = NULL,
				ihds_prov_id = 1,
				NameFirst = NULL,
				NameLast = 'Unknown Provider',
				NameMiddleInitial = NULL,
				NameSuffix = NULL,
				NPI = NULL,
				ProviderType = NULL,
				RowID = NULL,
				ProviderPrescribingPrivFlag  = 'N',
				CDProviderFlag  = 'N',
				DentistFlag  = 'N',
				EyeCareFlag  = 'N',
				MentalHealthFlag  = 'N',
				NephrologistFlag  = 'N',
				NursePractFlag  = 'N',
				OBGynFlag  = 'N',
				PCPFlag  = 'N',
				PhysicianAsstFlag  = 'N',
				ProviderPaidInpatientRateFlag  = 'N',
				ProviderPaidOutpatientRateFlag  = 'N',
				CustomerProviderID ='',
				ClinicalPharmacistFlag  = 'N',
				AnesthesiologistFlag  = 'N',
				ProviderFullName = 'Unknown Provider',
				AmbulanceFlag  = 'N',
				DMEFlag  = 'N',
				HospitalFlag  = 'N',
				SNFFlag  = 'N',
				Address1 = NULL,
				Address2 = NULL,
				City = NULL,
				State = NULL,
				Zip = NULL,
				Phone = NULL,
				Fax = NULL,
				DurableMedEquipmentFlag  = 'N',
				RegisteredNurseFlag  = 'N',
				SkilledNursingFacFlag  = 'N',
				SurgeonFlag  = 'N',
				CardiologistFlag  = 'N',
				GastroenterologistFlag  = 'N',
				EndocrinologistFlag  = 'N',
				ProviderCounty = NULL,
				ProviderEmail = NULL

    EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted',
        @@ROWCOUNT, 'etl_BCBSA_Provider', 'Provider : Unknown Provider ',
        @iExpectedCnt

END

/*************************************************************************************
        5.  Delete temp tables if they already exist.
*************************************************************************************/
IF OBJECT_ID('tempdb..#max_prov') IS NOT NULL
    DROP TABLE #max_prov

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
