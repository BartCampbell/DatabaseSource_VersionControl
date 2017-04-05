SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*************************************************************************************
Procedure:	etl_BCBSA_Member
Author:		Leon Dowling
Copyright:	© 2017
Date:		2017.01.02
Purpose:	To load BCBSA Member data into Staging
Parameters:	@iLoadInstanceID	int.........IMIAdmin..ClientProcessInstance.LoadInstanceID
Depends On:	
Calls:		IMIAdmin..fxSetMetrics
			IMIAdmin..fxSetStatus
Called By:	dbo.IHDSBuildMaster
Returns:	None
Notes:		None
Process:	
Change Log:
3/30/2017 Leon - Update for BCBSA Schema
Test Script:	
	
				exec dbo.etl_BCBSA_Member 1

ToDo:		

		SELECT DataSource, COUNT(*) FROM Member GROUP BY DataSource
		select * from dbo.Member
		select * from dbo.Eligibility

*************************************************************************************/
--/*
CREATE PROCEDURE [dbo].[etl_BCBSA_Member]
(
	@iLoadInstanceID		int        
)
WITH RECOMPILE
AS
BEGIN TRY
        --SET NOCOUNT ON
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
IF OBJECT_ID('tempdb..#MaxMember') IS NOT NULL
    DROP TABLE #MaxMember

DELETE FROM dbo.Member
    WHERE Client = 'BCBSA'


/*************************************************************************************
        3.  Populate Member.
*************************************************************************************/
BEGIN 

    SET @iExpectedCnt = 0

    IF OBJECT_ID('tempdb..#maxMember') IS NOT NULL
        DROP TABLE #maxMember

    SELECT ihds_member_id = mom.ihds_member_id,
            RowID = MAX(e.RowID)
        INTO #MaxMember
		--	SELECT COUNT(*)
        FROM RDSM.Member e
            JOIN mpi_output_member mom
                ON 'BCBSA' = mom.clientid
                   AND 'Member' = mom.src_table_name
                   AND 'BCBSA_RDSM' = mom.src_db_name
                   AND 'BCBSA_GDIT' = mom.src_schema_name
                   AND e.RowID = mom.src_rowid
        GROUP BY mom.ihds_member_id

    CREATE INDEX fk#MaxMember ON #MaxMember ( RowID )
    CREATE STATISTICS sp_fk#MaxMember ON #MaxMember ( RowID )

    EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted',
        @@ROWCOUNT, 'etl_BCBSA_Member',
        '#MaxMember : FROM BCBSA_MD', @@rowcount

	--	Insert records
    INSERT INTO dbo.Member
            (Client,
             DataSource,
             RowID,
             Address1,
             Address2,
             City,
             CustomerMemberID,
             CustomerSubscriberID,
             DateOfBirth,
             DateRowCreated,
             Gender,
             ihds_member_id,
             NameFirst,
             NameLast,
             NameMiddleInitial,
             NamePrefix,
             NameSuffix,
             Phone,
             RelationshipToSubscriber,
             SSN,
             [State],
             SubscriberID,
             ZipCode,
             Ethnicity,
             InterpreterFlag,
             MemberLanguage,
             Race,
             County,
             RaceEthnicitySource,
             RaceSource,
             EthnicitySource,
             SpokenLanguage,
             SpokenLanguageSource,
             WrittenLanguage,
             WrittenLanguageSource,
             OtherLanguage,
             OtherLanguageSource,
             CustomerPersonNo,
             PhoneMobile,
             PhoneWork,
             PhoneHome,
             MemberLanguageCode ,
			 MedicareID                  
            )
        SELECT
				Client = 'BCBSA',
                DataSource = 'BCBSA_GDIT.Member',
                RowID = m.RowID,
                Address1 = m.ContactAddress1,
                Address2 = m.ContactAddress2,
                City = m.ContactCity,
                CustomerMemberID = m.MemberID,
					CustomerSubscriberID = NULL,
                DateOfBirth = m.DOB,
                DateRowCreated = CONVERT(VARCHAR(8), GETDATE(), 112),
                Gender = m.Gender,
                ihds_member_id = mm.ihds_member_id,
                NameFirst = m.NameFirst,
                NameLast = m.NameLast,
                NameMiddleInitial = LEFT(m.NameMiddleInitial,1),
					NamePrefix = NULL,
				NameSuffix = NameSuffix,
                Phone = m.ContactTelephone,
					RelationshipToSubscriber = NULL,
					SSN = NULL,
                [State] = m.ContactState,
                SubscriberID = NULL,--e.SubscriberID,
                ZipCode = m.ContactZipCode,
                Ethnicity = m.Hispanic,
                InterpreterFlag = LEFT(m.Interpreter,1),
                MemberLanguage = m.[Language],
                Race = m.Race,
                County = M.ContactCounty,
					RaceEthnicitySource = NULL,
                RaceSource = m.RaceSource,
                EthnicitySource = m.EthnicitySource,
                SpokenLanguage = m.[Language],
                SpokenLanguageSource = m.LanguageSource,
                WrittenLanguage = m.WrittenLanguage,
                WrittenLanguageSource = m.WrittenLanguageSource,
                OtherLanguage = m.OtherLanguage,
                OtherLanguageSource = m.OtherLanguageSource,
					CustomerPersonNo = NULL,
					PhoneMobile = NULL,
					PhoneWork = NULL,
					PhoneHome = NULL,
					MemberLanguageCode = NULL,
				MedicareID = m.MedicareID
			--SELECT COUNT(*)
            FROM RDSM.Member m
                JOIN #MaxMember mm
                    ON m.RowID = mm.RowID

    EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted',
        @@ROWCOUNT, 'etl_BCBSA_Member', 'Member : FROM Member',
        @@rowcount

END 

/*************************************************************************************
14.  Delete temp tables if they already exist.
*************************************************************************************/

IF OBJECT_ID('tempdb..#MaxMember') IS NOT NULL
    DROP TABLE #MaxMember
IF OBJECT_ID('tempdb..#MaxLabMember') IS NOT NULL
    DROP TABLE #maxLabMember

EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Completed'

--/*
END TRY

BEGIN CATCH
        DECLARE @iErrorLine		INT,
                @iErrorNumber		INT,
                @iErrorSeverity		INT,
                @iErrorState		INT,
                @nvcErrorMessage	NVARCHAR( 2048 ), 
                @nvcErrorProcedure	NVARCHAR( 126 )

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
        PRINT	'Error Line:      ' + CAST( @iErrorLine AS VARCHAR( 12 ))
        PRINT	'Error Number:    ' + CAST( @iErrorNumber AS VARCHAR( 12 ))
        PRINT	'Error Message:   ' + @nvcErrorMessage
        PRINT	'Error Severity:  ' + CAST( @iErrorSeverity AS VARCHAR( 12 ))
        PRINT	'Error State:     ' + CAST( @iErrorState AS VARCHAR( 12 ))

        EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Failed'

        RAISERROR( @nvcErrorMessage, @iErrorSeverity, @iErrorState );
END CATCH
--*/


GO
