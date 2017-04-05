SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*************************************************************************************
Procedure:	[etl_mpi_preload_member]
Author:		Leon Dowling
Copyright:	© 2016
Date:		2016.12.22
Purpose:	
Parameters:	@iLoadInstanceID int.........IMIAdmin..ClientProcessInstance.LoadInstanceID
			@bIncrementalBuild BIT 
Depends On:	
Calls:		
Called By:	
Returns:	None
Update Log:
1/1/2017 - fix lab result table name
1/25/2017 - add MemberPCp
2/8/2017 - add SupplementalClaimHeader and SupplementalClaimDetail
Test Script: 

	EXEC [etl_mpi_preload_member] 1
	EXEC [etl_mpi_preload_Provider] 1

	exec [prBuildMPIXref] 
		@iLoadInstanceID = 1253, -- IMIAdmin..ClientProcessInstance.LoadInstanceID
		@bProcessMember = 1,
		@bProcessProvider = 1,
		@bSingleClient = 0 ,
		@vcClient  = ''

TRUNCATE TABLE  mpi_pre_load_dtl_member 
TRUNCATE TABLE  dbo.mpi_pre_load_member 

SELECT src_table_name, COUNT(*)
	FROM dbo.mpi_pre_load_member
	GROUP BY src_table_name


ToDo:		
*************************************************************************************/
--/*

CREATE PROCEDURE [dbo].[etl_mpi_preload_member]
        @iLoadInstanceID INT, -- IMIAdmin..ClientProcessInstance.LoadInstanceID
        @bIncrementalBuildFlag BIT = 0
        
WITH RECOMPILE
AS
BEGIN TRY
--        SET NOCOUNT ON
--*/
		/*----------------------------------------------------
		DECLARE @iLoadInstanceID INT, -- IMIAdmin..ClientProcessInstance.LoadInstanceID
				@bIncrementalBuildFlag BIT
				
		EXECUTE IMIAdmin..prInitializeInstance 'BCBSA', 'Staging Load', 0, NULL, NULL, @iLoadInstanceID OUTPUT 
		SET @bIncrementalBuildFlag = 0
		--*/----------------------------------------------------		
		
        /*************************************************************************************
                1.	Declare/initialize variables
        *************************************************************************************/
        DECLARE @sysMe sysname

        SET @sysMe = OBJECT_NAME( @@PROCID )

        EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Started'

        /*************************************************************************************
                2.  Delete temp tables if they already exist.
        *************************************************************************************/
        IF OBJECT_ID( 'tempdb..#Member' ) IS NOT NULL DROP TABLE #Member

        /*************************************************************************************
                3.  Delete client data from detail and/or rejected tables.
        *************************************************************************************/

		DELETE  mpdm
		FROM    dbo.mpi_pre_load_dtl_member mpdm
				JOIN dbo.mpi_pre_load_member mpm
						ON mpm.mpi_pre_load_rowid = mpdm.mpi_pre_load_rowid
		WHERE   mpm.src_schema_name = 'BCBSA'

		DELETE  mpm
		FROM    mpi_pre_load_member mpm
		WHERE   mpm.src_schema_name = 'BCBSA'


        /*************************************************************************************
                5.  Populate #Member.
                    Initial load of VERISK Member data
        *************************************************************************************/
        BEGIN 

			IF OBJECT_ID('tempdb..#member') IS NOT NULL
				DROP TABLE #member

			SELECT a.member_id,
			        a.src_rowid,
			        a.clientid,
			        a.src_table_name,
			        a.src_db_name,
			        a.src_schema_name,
			        a.src_name,
			        a.loaddate,
					hashvalue = CONVERT( binary( 16 ), hashbytes( 'MD5', 0xFF 
							+ ISNULL( CONVERT( varbinary( 255 ), src_name, 0 ), 0x00 )
							+ ISNULL( CONVERT( varbinary( 255 ), Member_ID, 0 ), 0x00 )
							+ 0xFF ), ( 0 ))
				INTO #Member
				FROM (SELECT 
                        member_id = UPPER( RTRIM( m.MemberID )), 
                        src_rowid = UPPER( RTRIM( m.RowID )), 
                        clientid = 'BCBSA', 
                        src_table_name = CONVERT(VARCHAR(50),'Member'), 
                        src_db_name = 'BCBSA_RDSM', 
                        src_schema_name = 'BCBSA', 
                        src_name = CONVERT(VARCHAR(50),'BCBSA_Member'), 
                        loaddate = GETDATE() 
	                --select top 10 *
					FROM  BCBSA_RDSM.BCBSA.Member m 
						) a

            EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#Member', ' FROM : BCBSA.Member', @@ROWCOUNT


			INSERT INTO #Member 
			SELECT a.member_id,
			        a.src_rowid,
			        a.clientid,
			        a.src_table_name,
			        a.src_db_name,
			        a.src_schema_name,
			        a.src_name,
			        a.loaddate,
					hashvalue = CONVERT( binary( 16 ), hashbytes( 'MD5', 0xFF 
							+ ISNULL( CONVERT( varbinary( 255 ), src_name, 0 ), 0x00 )
							+ ISNULL( CONVERT( varbinary( 255 ), Member_ID, 0 ), 0x00 )
							+ 0xFF ), ( 0 ))
				FROM (SELECT 
							member_id = UPPER( RTRIM( mc.MemberID)), 
							src_rowid = UPPER( RTRIM( mc.RowID )), 
							clientid = 'BCBSA', 
							src_table_name = 'Enrollment', 
							src_db_name = 'BCBSA_RDSM', 
							src_schema_name = 'BCBSA', 
							src_name = 'BCBSA_Enrollment', 
							loaddate = GETDATE() 
						FROM BCBSA_RDSM.BCBSA.Enrollment mc
						) a

            EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#Member', ' FROM : BCBSA.Enrollment', @@ROWCOUNT

			INSERT INTO #Member 
			SELECT a.member_id,
			        a.src_rowid,
			        a.clientid,
			        a.src_table_name,
			        a.src_db_name,
			        a.src_schema_name,
			        a.src_name,
			        a.loaddate,
					hashvalue = CONVERT( binary( 16 ), hashbytes( 'MD5', 0xFF 
							+ ISNULL( CONVERT( varbinary( 255 ), src_name, 0 ), 0x00 )
							+ ISNULL( CONVERT( varbinary( 255 ), Member_ID, 0 ), 0x00 )
							+ 0xFF ), ( 0 ))
				FROM (SELECT 
							member_id = UPPER( RTRIM( mc.MemberID )), 
							src_rowid = UPPER( RTRIM( mc.RowID )), 
							clientid = 'BCBSA', 
							src_table_name = 'Claim', 
							src_db_name = 'BCBSA_RDSM', 
							src_schema_name = 'BCBSA', 
							src_name = 'BCBSA_Claim', 
							loaddate = GETDATE() 
						FROM BCBSA_RDSM.BCBSA.Claim mc
						) a

            EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#Member', ' FROM : BCBSA.Claim', @@ROWCOUNT

			INSERT INTO #Member 
			SELECT a.member_id,
				    a.src_rowid,
				    a.clientid,
				    a.src_table_name,
				    a.src_db_name,
				    a.src_schema_name,
				    a.src_name,
				    a.loaddate,
					hashvalue = CONVERT( binary( 16 ), hashbytes( 'MD5', 0xFF 
							+ ISNULL( CONVERT( varbinary( 255 ), src_name, 0 ), 0x00 )
							+ ISNULL( CONVERT( varbinary( 255 ), Member_ID, 0 ), 0x00 )
							+ 0xFF ), ( 0 ))
				FROM (SELECT 
							member_id = UPPER( RTRIM( rx.MemberID )), 
							src_rowid = UPPER( RTRIM( rx.RowID )), 
							clientid = 'BCBSA', 
							src_table_name = 'RxClaim', 
							src_db_name = 'BCBSA_RDSM', 
							src_schema_name = 'BCBSA', 
							src_name = 'BCBSA_RxClaim', 
							loaddate = GETDATE() 
						FROM BCBSA_RDSM.BCBSA.RxClaim rx 
					) a

			EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#Member', ' FROM : BCBSA.RxClaim', @@ROWCOUNT

			INSERT INTO #Member 
			SELECT a.member_id,
				    a.src_rowid,
				    a.clientid,
				    a.src_table_name,
				    a.src_db_name,
				    a.src_schema_name,
				    a.src_name,
				    a.loaddate,
					hashvalue = CONVERT( binary( 16 ), hashbytes( 'MD5', 0xFF 
							+ ISNULL( CONVERT( varbinary( 255 ), src_name, 0 ), 0x00 )
							+ ISNULL( CONVERT( varbinary( 255 ), Member_ID, 0 ), 0x00 )
							+ 0xFF ), ( 0 ))
				FROM (SELECT 
							member_id = UPPER( RTRIM( l.MemberID)), 
							src_rowid = UPPER( RTRIM( l.RowID )), 
							clientid = 'BCBSA', 
							src_table_name = 'ExternalEvent', 
							src_db_name = 'BCBSA_RDSM', 
							src_schema_name = 'BCBSA', 
							src_name = 'BCBSA_ExternalEvent', 
							loaddate = GETDATE() 
						FROM BCBSA_RDSM.BCBSA.ExternalEvent l 
						) a

			EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#Member', ' FROM : BCBSA.ExternalEvent', @@ROWCOUNT

			---6.  Populate mpi_pre_load_member.
			BEGIN             
        
                INSERT INTO dbo.mpi_pre_load_member
                        (clientid,
                         src_table_name,
                         src_db_name,
                         src_schema_name,
                         src_name,
                         member_id,
                         hashvalue,
                         LoadDate
                        )
                    SELECT DISTINCT clientid = UPPER(RTRIM(m.clientid)),
                            src_table_name = UPPER(RTRIM(m.src_table_name)),
                            src_db_name = UPPER(RTRIM(m.src_db_name)),
                            src_schema_name = UPPER(RTRIM(m.src_schema_name)),
                            src_name = UPPER(RTRIM(m.src_name)),
                            member_id = UPPER(RTRIM(m.member_id)),
                            hashvalue = m.hashvalue,
                            loaddate = UPPER(RTRIM(m.loaddate))
                        FROM #Member m
                            LEFT HASH JOIN mpi_pre_load_member mpm
                                ON m.hashvalue = mpm.hashvalue
                        WHERE mpm.hashvalue IS NULL

                EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, 'dbo.mpi_pre_load_member', ' FROM : #member', @@ROWCOUNT
              
			END

			--  Populate mpi_pre_load_dtl_member.
                   
	        BEGIN 
        
                INSERT INTO dbo.mpi_pre_load_dtl_member ( 
                        mpi_pre_load_rowid, 
                        loaddate, 
                        src_rowid, 
                        clientid
                        )
                SELECT DISTINCT 
                        mpi_pre_load_rowid = UPPER( RTRIM( mpm.mpi_pre_load_rowid )), 
                        loaddate = UPPER( RTRIM( mpm.loaddate )), 
                        src_rowid = UPPER( RTRIM( m.src_rowid )), 
                        clientid = 'BCBSA'
                FROM    #Member m 
                        JOIN dbo.mpi_pre_load_member mpm 
                                ON m.hashvalue  = mpm.hashvalue 
                        LEFT HASH JOIN dbo.mpi_pre_load_dtl_member mpdm 
                                ON mpm.mpi_pre_load_rowid  = mpdm.mpi_pre_load_rowid 
                                AND m.src_rowid  = mpdm.src_rowid 
                WHERE   mpdm.mpi_pre_load_rowid IS NULL

                EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, 'dbo.mpi_pre_load_dtl_member', ' FROM : #member', @@ROWCOUNT
		    END

		END -- Member

        /*************************************************************************************
                22.  Delete temp tables if they already exist.
        *************************************************************************************/

		IF OBJECT_ID('tempdb..#member_newrow') IS NOT NULL	DROP TABLE #member_newrow
		IF OBJECT_ID('tempdb..#elig_newrow') IS NOT NULL	DROP TABLE #elig_newrow
		IF OBJECT_ID('tempdb..#med_newrow') IS NOT NULL	DROP TABLE #med_newrow
		IF OBJECT_ID('tempdb..#rx_newrow') IS NOT NULL	DROP TABLE #rx_newrow

        IF OBJECT_ID( 'tempdb..#Member' ) IS NOT NULL DROP TABLE #Member
        IF OBJECT_ID( 'tempdb..#Elieg' ) IS NOT NULL DROP TABLE #elig
        IF OBJECT_ID( 'tempdb..#MedicalClaims' ) IS NOT NULL DROP TABLE #MedicalClaims
        IF OBJECT_ID( 'tempdb..#RxClaims' ) IS NOT NULL DROP TABLE #RxClaims

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
