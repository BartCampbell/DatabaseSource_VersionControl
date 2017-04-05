SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*************************************************************************************
Procedure:	[etl_mpi_preload_Provider]  
Author:		Leon Dowling
Copyright:	© 2016
Date:		2016.12.21
Purpose:	
Parameters:	@iLoadInstanceID int.........IMIAdmin..ClientProcessInstance.LoadInstanceID
        @bIncrementalBuildFlag BIT = 0
Depends On:	
Calls:		
Called By:	
Returns:	None
Notes:		None
UpDate Log:
3/30/2017 Leon - Update for RDSM Schema
Test Script: exec [etl_mpi_preload_Provider] 1
ToDo:		

TRUNCATE TABLE dbo.mpi_pre_load_dtl_prov 
TRUNCATE TABLE dbo.mpi_pre_load_prov 


*************************************************************************************/


CREATE PROCEDURE [dbo].[etl_mpi_preload_Provider]
	@iLoadInstanceID INT
WITH RECOMPILE
AS
BEGIN TRY
--        SET NOCOUNT ON
--*/		
		/*----------------------------------------------------		
		DECLARE @iLoadInstanceID INT, -- IMIAdmin..ClientProcessInstance.LoadInstanceID
			@bIncrementalBuildFlag BIT
				
		EXECUTE IMIAdmin..prInitializeInstance 'BCBSA', 'Staging Load', 0, NULL, NULL, @iLoadInstanceID OUTPUT 
		SET @bIncrementalBuildFlag = 1
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
        IF OBJECT_ID( 'tempdb..#Provider' ) IS NOT NULL DROP TABLE #Provider

        /*************************************************************************************
                3.  Delete client data from detail and/or rejected tables.
        *************************************************************************************/
		
		/*DELETE mpld
		FROM dbo.mpi_pre_load_dtl_prov mpld
			JOIN dbo.mpi_pre_load_prov mpl
				ON mpld.mpi_pre_load_prov_rowid = mpl.mpi_pre_load_prov_rowid
		WHERE mpl.src_schema_name = 'BCBSA_GDIT2017'

        DELETE mpl
            FROM mpi_pre_load_prov mpl
            WHERE mpl.src_schema_name = 'BCBSA_GDIT2017'
		*/
		TRUNCATE TABLE dbo.mpi_pre_load_dtl_prov 
		TRUNCATE TABLE dbo.mpi_pre_load_prov 

		BEGIN
		
			IF OBJECT_ID('tempdb..#provider') IS NOT NULL 
				DROP TABLE #provider

			SELECT a.src_rowid,
			        a.clientid,
			        a.src_table_name,
			        a.src_db_name,
			        a.src_schema_name,
			        a.src_name,
			        a.loaddate,
			        a.medical_provider_id,
					hashvalue = CONVERT( binary( 16 ), hashbytes( 'MD5', 0xFF 
							+ ISNULL( CONVERT( varbinary( 255 ), src_name, 0 ), 0x00 )
							+ ISNULL( CONVERT( varbinary( 255 ), Medical_Provider_ID, 0 ), 0x00 )
							+ 0xFF ), ( 0 )),
					mpi_prov_type = 'Servicing'
				INTO #provider
				FROM (SELECT  
								src_rowid = UPPER( RTRIM( p.RowID )), 
								clientid = 'BCBSA', 
								src_table_name = CONVERT(VARCHAR(50),'Provider'), 
								src_db_name = 'BCBSA_RDSM', 
								src_schema_name = 'BCBSA_GDIT', 
								src_name = CONVERT(VARCHAR(50),'BCBSA_GDIT_Provider'), 
								loaddate = GETDATE(), 
								medical_provider_id = CONVERT(VARCHAR(50),UPPER( RTRIM( p.ProviderID)))
						FROM    RDSM.Provider p 
						) a

            EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#Provider', ' FROM : RDSM.Provider', @@ROWCOUNT

			INSERT INTO #provider
			SELECT a.src_rowid,
			        a.clientid,
			        a.src_table_name,
			        a.src_db_name,
			        a.src_schema_name,
			        a.src_name,
			        a.loaddate,
			        a.medical_provider_id,
					hashvalue = CONVERT( binary( 16 ), hashbytes( 'MD5', 0xFF 
							+ ISNULL( CONVERT( varbinary( 255 ), src_name, 0 ), 0x00 )
							+ ISNULL( CONVERT( varbinary( 255 ), Medical_Provider_ID, 0 ), 0x00 )
							+ 0xFF ), ( 0 )),
					mpi_prov_type = 'Servicing'
				FROM (SELECT
								src_rowid = UPPER( RTRIM( mc.RowID )), 
								clientid = 'BCBSA', 
								src_table_name = 'Claim', 
								src_db_name = 'BCBSA_RDSM', 
								src_schema_name = 'BCBSA_GDIT', 
								src_name = 'BCBSA_GDIT_Claim', 
								loaddate = GETDATE(), 
								medical_provider_id = UPPER( RTRIM( mc.ProviderID)) 
						FROM    RDSM.Claim mc 
							) a

            EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#Provider', ' FROM : RDSM.Claim', @@ROWCOUNT


			INSERT INTO #provider
			SELECT a.src_rowid,
			        a.clientid,
			        a.src_table_name,
			        a.src_db_name,
			        a.src_schema_name,
			        a.src_name,
			        a.loaddate,
			        a.medical_provider_id,
					hashvalue = CONVERT( binary( 16 ), hashbytes( 'MD5', 0xFF 
							+ ISNULL( CONVERT( varbinary( 255 ), src_name, 0 ), 0x00 )
							+ ISNULL( CONVERT( varbinary( 255 ), Medical_Provider_ID, 0 ), 0x00 )
							+ 0xFF ), ( 0 )),
					mpi_prov_type = 'Servicing'
				FROM (SELECT
								src_rowid = UPPER( RTRIM( mc.RowID )), 
								clientid = 'BCBSA', 
								src_table_name = 'RxClaim', 
								src_db_name = 'BCBSA_RDSM', 
								src_schema_name = 'BCBSA_GDIT', 
								src_name = 'BCBSA_GDIT_RxClaim', 
								loaddate = GETDATE(), 
								medical_provider_id = UPPER( RTRIM( mc.DispensingProv)) 
						FROM    RDSM.RxClaim mc 
							) a

            EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#Provider', ' FROM : RDSM.RxClaim', @@ROWCOUNT

			BEGIN -- mpi_pre_load_prov
        
                INSERT INTO dbo.mpi_pre_load_prov
                        (clientid,
                         src_table_name,
                         src_db_name,
                         src_schema_name,
                         src_name,
                         hashvalue,
						 LoadDate,
                         medical_provider_id,
                         mpi_prov_type
						)
                    SELECT DISTINCT clientid = p.clientid,
                            src_table_name = p.src_table_name,
                            src_db_name = p.src_db_name,
                            src_schema_name = p.src_schema_name,
                            src_name = p.src_name,
                            hashvalue = p.hashvalue,
                            loaddate = p.loaddate,
                            medical_provider_id = p.medical_provider_id,
                            mpi_prov_type = p.mpi_prov_type
                        FROM #provider p
                            LEFT HASH JOIN dbo.mpi_pre_load_prov mpp
                                ON p.hashvalue = mpp.hashvalue
                        WHERE mpp.hashvalue IS NULL

				EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, 'dbo.mpi_pre_load_prov', ' FROM : #Provider', @@ROWCOUNT

			END

			BEGIN -- mpi_pre_load_dtl_prov

                INSERT INTO dbo.mpi_pre_load_dtl_prov
                        (mpi_pre_load_prov_rowid,
                         loaddate,
                         src_rowid,
                         clientid
						)
                    SELECT DISTINCT mpi_pre_load_prov_rowid = UPPER(RTRIM(mpp.mpi_pre_load_prov_rowid)),
                            loaddate = UPPER(RTRIM(mpp.LoadDate)),
                            src_rowid = UPPER(RTRIM(p.src_rowid)),
                            clientid = 'BCBSA'
                        FROM #provider p
                            JOIN dbo.mpi_pre_load_prov mpp
                                ON p.hashvalue = mpp.hashvalue
                            LEFT HASH JOIN dbo.mpi_pre_load_dtl_prov mpdp
                                ON mpp.mpi_pre_load_prov_rowid = mpdp.mpi_pre_load_prov_rowid
                                   AND p.src_rowid = mpdp.src_rowid
                        WHERE mpdp.mpi_pre_load_dtl_prov_rowid IS NULL

                EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID,
                    'Records Inserted', @@ROWCOUNT,
                    'dbo.mpi_pre_load_dtl_prov', ' FROM : #Provider p',
                    @@ROWCOUNT

			END
		END 

        /*************************************************************************************
                7.  Delete temp tables if they already exist.
        *************************************************************************************/
        IF OBJECT_ID( 'tempdb..#Provider' ) IS NOT NULL DROP TABLE #Provider

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
