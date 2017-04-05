SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	etl_BCBSA_Eligibility
Author:		Michael Wu
Copyright:	© 2015
Date:		2016.12.21
Purpose:	To load BCBSA Eligibility data into Staging
Parameters:	@iLoadInstanceID	int.........IMIAdmin..ClientProcessInstance.LoadInstanceID
Depends On:	
Calls:		IMIAdmin..fxSetMetrics
			IMIAdmin..fxSetStatus
Called By:	dbo.IHDSBuildMaster
Returns:	None
Notes:		None
Process:	
Change Log: Copied McLaren file as template and converted to BCBSA
3/30/2017 Leon - Update for RDSM Schema
Test Script:	
	
				exec dbo.etl_BCBSA_Eligibility 1

ToDo:		

		SELECT DataSource, COUNT(*) FROM Eligibility WHERE Client = 'BCBSA' GROUP BY DataSource

		SELECT COUNT(*) FROM Eligibility 

		SELECT COUNT(*) FROM RDSM.Enrollment 


*************************************************************************************/
--/*
CREATE PROCEDURE [dbo].[etl_BCBSA_Eligibility]
(
	@iLoadInstanceID        INT        -- IMIAdmin..ClientProcessInstance.LoadInstanceID
)
WITH RECOMPILE
AS
BEGIN TRY
--        SET NOCOUNT ON
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
    DELETE FROM dbo.Eligibility
        WHERE Client = 'BCBSA'
END

/*************************************************************************************
        3.  Populate Eligibility.
				Load BCBSA.MemberEligibility
*************************************************************************************/
BEGIN 
	
	IF NOT EXISTS (SELECT * FROM dbo.HealthPlan WHERE HealthPlanName = 'BCBSA')
		INSERT INTO dbo.HealthPlan
		        (Client,
		         HealthPlanName
		        )
		    VALUES
		        ('BCBSA', -- Client - varchar(20)
		         'BCBSA' -- HealthPlanName - varchar(50)
		        )

	--	Insert into Eligibility table
    SET @iExpectedCnt = 0

    INSERT INTO Eligibility (
			 Client,
			 DataSource,
			 DateEffective,
			 DateRowCreated,
			 DateTerminated,
			 HashValue,
			 HealthPlanID,
			 IsUpdated,
			 MemberID,
			 RowID,
			 ProductType,
			 CoverageCDAmbulatoryFlag,
			 CoverageCDDayNightFlag,
			 CoverageCDInpatientFlag,
			 CoverageDentalFlag,
			 CoverageMHAmbulatoryFlag,
			 CoverageMHDayNightFlag,
			 CoverageMHInpatientFlag,
			 CoveragePharmacyFlag,
			 HealthPlanEmployeeFlag,
			 HedisMeasureID,
			 LoadInstanceFileID,
			 Program,
			 EmployerGroup,
			 EmployerDivision,
			 ihds_prov_id_pcp,
			 MemberGroupID,
			 BenefitPlanID,
			 LineOfBusinessID,
			 BenefitPlanCode,
			 BenefitPlanDesc,
			 EligRecordCreateDate,
			 EligRecordCreateUser,
			 EligRecordUpdateDate,
			 EligRecordUpdateUser,
			 TermReason,
			 Relationship,
			 RelationshipDesc,
			 LineOfBusiness,
			 CustomerPCPID,
			 IPAID,
			 IPADesc,
			 PanelID,
			 PanelDesc,
			 CustomerEligibilityID,
			 CustomerMemberGroupID,
			 CoverageHospiceFlag,
			 MedicareType,
			 CustomerSubscriberSeqID,
			 CopayCategory,
			 LICSLevel,
			 CustomerEligibilityStatus,
			 HospitalPayorInsCode,
			 SourceSystem,
			 EnrollID,
			 CustomerPlanID,
			 EligibleOrigID,
			 Carrierid,
			 InsuredID,
			 PlanDescription,
			 PlanType,
			 EligibleOrganizationName,
			 EligibleOrganizationType,
			 CarrierName,
			 CarrierType,
			 CarrierMemID,
			 PlanID,
			 InsuredMemberID,
			 InsuredIHDS_Member_ID,
			 RateCode,
			 ProgramID,
			 ProgramDescription,
			 CustomerEligRatingCode,
			 OrgPolicyID,
			 policynum,
			 ProductPriority
			 
			 
			)
        SELECT DISTINCT
			Client = 'BCBSA',
			DataSource = 'BCBSA_GDIT2017.Enrollment',
			DateEffective = CASE WHEN ISDATE(e.EnrollmentDate) = 0 THEN NULL		
								WHEN CONVERT(VARCHAR(8),CONVERT(DATETIME,e.EnrollmentDate),112) >= '19000101' THEN e.EnrollmentDate
								END,
			DateRowCreated = CONVERT(VARCHAR(8), GETDATE(), 112),
			DateTerminated = CASE WHEN ISNULL(e.TerminationDate,'') = '' THEN NULL
								WHEN ISDATE(e.TerminationDate) = 0 THEN NULL		
								WHEN CONVERT(VARCHAR(8),CONVERT(DATETIME,e.TerminationDate),112) >= '19000101' THEN e.TerminationDate
								END,
				HashValue = NULL,
			HealthPlanID = (SELECT TOP 1 HealthPlanID FROM dbo.HealthPlan WHERE HealthPlanName = 'BCBSA'),
				IsUpdated = NULL,
			MemberID = m.MemberID,
			RowID = e.RowID,
			ProductType = 'PPO',
			CoverageCDAmbulatoryFlag = e.ChemDepAMBBenefit,
			CoverageCDDayNightFlag = e.ChemDepDayNightBenefit,
			CoverageCDInpatientFlag = e.ChemDepINPBenefit,
			CoverageDentalFlag = e.DentalBenefit,
			CoverageMHAmbulatoryFlag = e.MentalHealthAMBBenefit,
			CoverageMHDayNightFlag = e.MentalHealthDayNightBenefit,
			CoverageMHInpatientFlag = e.MentalHealthINPBenefit,
			CoveragePharmacyFlag = e.PharmacyBenefit,
				HealthPlanEmployeeFlag = NULL,
				HedisMeasureID = NULL,
			LoadInstanceFileID = e.LoadInstanceFileID,
				Program = NULL,
			EmployerGroup = e.GroupID,
				EmployerDivision = NULL,
				ihds_prov_id_pcp = NULL,
				MemberGroupID = NULL,
				BenefitPlanID = NULL,
				LineOfBusinessID = NULL,
				BenefitPlanCode = NULL,
				BenefitPlanDesc = NULL,
				EligRecordCreateDate = NULL,
				EligRecordCreateUser = NULL,
				EligRecordUpdateDate = NULL,
				EligRecordUpdateUser = NULL,
				TermReason = NULL,
				Relationship = NULL,
				RelationshipDesc = NULL,
				LineOfBusiness = NULL,
				CustomerPCPID = NULL,
				IPAID = NULL,
				IPADesc = NULL,
				PanelID = NULL,
				PanelDesc = NULL,
				CustomerEligibilityID = NULL,
				CustomerMemberGroupID = NULL,
			CoverageHospiceFlag = e.HospiceBenefit,
				MedicareType = NULL,
				CustomerSubscriberSeqID = NULL,
				CopayCategory = NULL,
				LICSLevel = NULL,
				CustomerEligibilityStatus = NULL,
				HospitalPayorInsCode = NULL,
				SourceSystem = NULL,
				EnrollID = NULL,
				CustomerPlanID = NULL,
				EligibleOrigID = NULL,
				Carrierid = NULL,
				InsuredID = NULL,
				PlanDescription = NULL,
				PlanType = NULL,
				EligibleOrganizationName = NULL,
				EligibleOrganizationType = NULL,
				CarrierName = NULL,
				CarrierType = NULL,
				CarrierMemID = NULL,
				PlanID = NULL,
				InsuredMemberID = NULL,
				InsuredIHDS_Member_ID = NULL,
				RateCode = NULL,
				ProgramID = NULL,
				ProgramDescription = NULL,
				CustomerEligRatingCode = NULL,
				OrgPolicyID = NULL,
				policynum = NULL,
				ProductPriority = 1
		--select count(1)
		FROM RDSM.Enrollment e
			JOIN mpi_output_member mom
				ON 'BCBSA' = mom.clientid
					AND 'Enrollment' = mom.src_table_name
					AND 'BCBSA_RDSM' = mom.src_db_name
					AND 'BCBSA_GDIT' = mom.src_schema_name
					AND e.RowID = mom.src_rowid
            INNER JOIN dbo.Member m
                ON mom.ihds_member_id = m.ihds_member_id

    EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted',
        @@ROWCOUNT, 'etl_BCBSA_Member', 'Eligibility : FROM Member',
        @iExpectedCnt


END 
		
/*************************************************************************************
        4.  Delete temp tables if they already exist.
*************************************************************************************/
IF OBJECT_ID('tempdb..#elig') IS NOT NULL
    DROP TABLE #Elig

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
