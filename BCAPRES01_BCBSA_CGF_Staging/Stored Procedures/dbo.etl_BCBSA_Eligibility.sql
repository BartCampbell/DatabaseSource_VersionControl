SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Procedure:  etl_BCBSA_Eligibility
Purpose:	To load BCBSA Eligibility data into Staging
Author:		Michael Wu
Depends On:	
Calls:		IMIAdmin..fxSetMetrics
			IMIAdmin..fxSetStatus
Called By:	dbo.IHDSBuildMaster
Returns:	None
Notes:		None
Depenedants:			

Usage: exec dbo.etl_BCBSA_Eligibility 1					

Change Log:
----------------------------------------------------------------------------------------------------------------------------------------------------- 
12/21/2016:				Copied McLaren file as template and converted to BCBSA
03/30/2017	Leon-		Update for RDSM Schema
04/7/2017	M Wu-		remove unused fields
04/14/2017	C Collins-	Populate dbo.healthPlan with BCBS MktSegmentCode and MktSegmentDesc. 
					    Populate healthPlanID in dbo.eligibility, to be consumed by prBuildResultTables and ultimately restrict access by user/plancode
						Populate PlanProduct from AltPopID1
04/19/2017	C Collins	Populate dbo.healthplan from GroupPlan without join to rdsm.enrollment to ensure all HealthPlans are popualated for report drop down
04/21/2017	C Collins	Populate ReportUsers and ReportUserPlanCode
04/25/2017	C Collins	Change Source of HealthPlan Name due to duplicates. Three HealthPlan’s have multiple MktSegmentDesc for the same BusinessMktSegDesc in GroupPlan ie Highmark BS BusinessMktSegDesc has BCBS OF RHODE ISLAND for MktSegmentDesc
05/10/2017	C Collins	Updating BCAPres01 version of SP to reflect changes made on ETL03 before BCAPres01 was created. 
****************************************************************************************************************************************************/


--/*
CREATE PROC [dbo].[etl_BCBSA_Eligibility] (@iLoadInstanceID INT        -- IMIAdmin..ClientProcessInstance.LoadInstanceID
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
    DECLARE @iExpectedCnt INT;
    DECLARE @sysMe sysname;

    SET @sysMe = OBJECT_NAME(@@PROCID);

    EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Started';

/*************************************************************************************
        2.  Delete temp tables if they already exist.
*************************************************************************************/
    BEGIN 

        TRUNCATE TABLE dbo.Eligibility;
    --DELETE FROM dbo.Eligibility
    --    WHERE Client = 'BCBSA'
    END;

/*************************************************************************************
        3.  Populate Eligibility.
				Load BCBSA.MemberEligibility
*************************************************************************************/
    BEGIN 

	/*IF NOT EXISTS (SELECT * FROM dbo.HealthPlan WHERE HealthPlanName = 'BCBSA')
		INSERT INTO dbo.HealthPlan
		        (Client,
		         HealthPlanName
		        )
		    VALUES
		        ('BCBSA', -- Client - varchar(20)
		         'BCBSA' -- HealthPlanName - varchar(50)
		        )*/
				--populate healthplan and user tables
        TRUNCATE TABLE dbo.HealthPlan;   
        INSERT  INTO dbo.HealthPlan
                (Client ,
                 HealthPlanName ,
                 CustomerHealthPlanID
                )
        SELECT DISTINCT
            'BCBSA' ,
            gp.MktSegmentDesc ,
            gp.MktSegmentCode CustomerHealthPlanID
        FROM
            RDSM.GroupPlan gp; --INNER JOIN rdsm.Enrollment e ON gp.GroupID=e.GroupID
  
      --  SET IDENTITY_INSERT  dbo.ReportUsers ON;
        TRUNCATE TABLE dbo.ReportUsers;
        INSERT  INTO dbo.ReportUsers
                (UserID ,
                 AssociationEmployeeFlag ,
                 FirstName ,
                 LastName ,
                 Email ,
                 Phone
                )
        SELECT DISTINCT
            UserID ,
            AssociationEmployeeFlag ,
            FirstName ,
            LastName ,
            Email ,
            Phone
        FROM
            RDSM.Users u;
        TRUNCATE TABLE dbo.ReportUserPlanCode;
        INSERT  INTO dbo.ReportUserPlanCode
                (userID ,
                 organization ,
                 PlanCode
                )
        SELECT DISTINCT
            UserID ,
            Organization ,
            PlanCode
        FROM
            RDSM.UserPlanCode upc;
    

	--	Insert into Eligibility table
        SET @iExpectedCnt = 0;

        INSERT  INTO Eligibility
                (Client ,
                 DataSource ,
                 DateEffective ,
                 DateRowCreated ,
                 DateTerminated ,
                 HealthPlanID ,
                 MemberID ,
                 RowID ,
                 ProductType ,
                 CoverageCDAmbulatoryFlag ,
                 CoverageCDDayNightFlag ,
                 CoverageCDInpatientFlag ,
                 CoverageDentalFlag ,
                 CoverageMHAmbulatoryFlag ,
                 CoverageMHDayNightFlag ,
                 CoverageMHInpatientFlag ,
                 CoveragePharmacyFlag ,
                 LoadInstanceFileID ,
                 EmployerGroup ,
                 CoverageHospiceFlag ,
                 ProductPriority, PlanProduct


			    )
        SELECT DISTINCT
            Client = 'BCBSA' ,
            DataSource = 'BCBSA_GDIT2017.Enrollment' ,
            DateEffective = CASE WHEN ISDATE(e.EnrollmentDate) = 0 THEN NULL
                                 WHEN CONVERT(VARCHAR(8), CONVERT(DATETIME, e.EnrollmentDate), 112) >= '19000101'
                                 THEN e.EnrollmentDate
                            END ,
            DateRowCreated = CONVERT(VARCHAR(8), GETDATE(), 112) ,
            DateTerminated = CASE WHEN ISNULL(e.TerminationDate, '') = ''
                                  THEN NULL
                                  WHEN ISDATE(e.TerminationDate) = 0 THEN NULL
                                  WHEN CONVERT(VARCHAR(8), CONVERT(DATETIME, e.TerminationDate), 112) >= '19000101'
                                  THEN e.TerminationDate
                             END ,
            HealthPlanID = hp.HealthPlanID ,
            MemberID = m.MemberID ,
            RowID = e.RowID ,
            ProductType = 'PPO' ,
            CoverageCDAmbulatoryFlag = e.ChemDepAMBBenefit ,
            CoverageCDDayNightFlag = e.ChemDepDayNightBenefit ,
            CoverageCDInpatientFlag = e.ChemDepINPBenefit ,
            CoverageDentalFlag = e.DentalBenefit ,
            CoverageMHAmbulatoryFlag = e.MentalHealthAMBBenefit ,
            CoverageMHDayNightFlag = e.MentalHealthDayNightBenefit ,
            CoverageMHInpatientFlag = e.MentalHealthINPBenefit ,
            CoveragePharmacyFlag = e.PharmacyBenefit ,
            LoadInstanceFileID = e.LoadInstanceFileID ,
            EmployerGroup = e.GroupID ,
            CoverageHospiceFlag = e.HospiceBenefit ,
            ProductPriority = 1,
			planProduct=e.AltPopID1
		--select count(1)
        FROM
            RDSM.Enrollment e
            JOIN mpi_output_member mom ON 'BCBSA' = mom.clientid
                                          AND 'Enrollment' = mom.src_table_name
                                          AND 'BCBSA_RDSM' = mom.src_db_name
                                          AND 'BCBSA_GDIT' = mom.src_schema_name
                                          AND e.RowID = mom.src_rowid
            INNER JOIN dbo.Member m ON mom.ihds_member_id = m.ihds_member_id
			INNER JOIN dbo.HealthPlan hp ON LEFT(e.GroupID,6)=hp.CustomerHealthPlanID


        EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted',
            @@ROWCOUNT, 'etl_BCBSA_Member', 'Eligibility : FROM Member',
            @iExpectedCnt;


    END; 

/*************************************************************************************
        4.  Delete temp tables if they already exist.
*************************************************************************************/
    IF OBJECT_ID('tempdb..#elig') IS NOT NULL
        DROP TABLE #Elig;

    EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Completed';

--/*
END TRY

BEGIN CATCH
    DECLARE
        @iErrorLine INT ,
        @iErrorNumber INT ,
        @iErrorSeverity INT ,
        @iErrorState INT ,
        @nvcErrorMessage NVARCHAR(2048) ,
        @nvcErrorProcedure NVARCHAR(126);

        -- capture error info so we can fail it up the line
    SELECT
        @iErrorLine = ERROR_LINE() ,
        @iErrorNumber = ERROR_NUMBER() ,
        @iErrorSeverity = ERROR_SEVERITY() ,
        @iErrorState = ERROR_STATE() ,
        @nvcErrorMessage = ERROR_MESSAGE() ,
        @nvcErrorProcedure = ERROR_PROCEDURE();

    INSERT  INTO IMIAdmin..ErrorLog
            (ErrorLine ,
             ErrorMessage ,
             ErrorNumber ,
             ErrorProcedure ,
             ErrorSeverity ,
             ErrorState ,
             ErrorTime ,
             InstanceID ,
             UserName
            )
    SELECT
        @iErrorLine ,
        @nvcErrorMessage ,
        @iErrorNumber ,
        @nvcErrorProcedure ,
        @iErrorSeverity ,
        @iErrorState ,
        GETDATE() ,
        InstanceID ,
        SUSER_SNAME()
    FROM
        IMIAdmin..ClientProcessInstance
    WHERE
        LoadInstanceID = @iLoadInstanceID;

    PRINT 'Error Procedure: ' + @sysMe;
    PRINT 'Error Line:      ' + CAST(@iErrorLine AS VARCHAR(12));
    PRINT 'Error Number:    ' + CAST(@iErrorNumber AS VARCHAR(12));
    PRINT 'Error Message:   ' + @nvcErrorMessage;
    PRINT 'Error Severity:  ' + CAST(@iErrorSeverity AS VARCHAR(12));
    PRINT 'Error State:     ' + CAST(@iErrorState AS VARCHAR(12));

    EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Failed';

    RAISERROR( @nvcErrorMessage, @iErrorSeverity, @iErrorState );
END CATCH;

--*/
GO
