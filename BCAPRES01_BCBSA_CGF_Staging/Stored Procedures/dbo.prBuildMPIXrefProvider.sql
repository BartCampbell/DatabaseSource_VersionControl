SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*

SELECT hdr.clientid,
        hdr.src_db_name,
        hdr.src_table_name,
        hdr.src_schema_name,
        COUNT(*)
    FROM dbo.mpi_pre_load_dtl_member dtl
        INNER JOIN dbo.mpi_pre_load_member hdr
            ON dtl.mpi_pre_load_rowid = hdr.mpi_pre_load_rowid
    GROUP BY hdr.clientid,
        hdr.src_db_name,
        hdr.src_table_name,
        hdr.src_schema_name
	ORDER BY clientid,
        hdr.src_db_name,
        hdr.src_table_name,
        hdr.src_schema_name

SELECT clientid,
        a.src_db_name,
        a.src_table_name,
        a.src_schema_name,
        COUNT(*)
    FROM dbo.mpi_output_member a
    GROUP BY clientid,
        a.src_db_name,
        a.src_table_name,
        a.src_schema_name
    ORDER BY clientid,
        a.src_db_name,
        a.src_table_name,
        a.src_schema_name


SELECT hdr.clientid,
        hdr.src_db_name,
        hdr.src_table_name,
        hdr.src_schema_name,
        COUNT(*)
    FROM dbo.mpi_pre_load_dtl_prov dtl
        INNER JOIN dbo.mpi_pre_load_prov hdr
            ON dtl.mpi_pre_load_prov_rowid = hdr.mpi_pre_load_prov_rowid
    GROUP BY hdr.clientid,
        hdr.src_db_name,
        hdr.src_table_name,
        hdr.src_schema_name
    ORDER BY hdr.clientid,
        hdr.src_db_name,
        hdr.src_table_name,
        hdr.src_schema_name
			
SELECT clientid,
        a.src_db_name,
        a.src_table_name,
        a.src_schema_name,
        COUNT(*)
    FROM dbo.mpi_output_provider a
    GROUP BY clientid,
        a.src_db_name,
        a.src_table_name,
        a.src_schema_name
    ORDER BY clientid,
        a.src_db_name,
        a.src_table_name,
        a.src_schema_name

-- Errors
SELECT hdr.clientid,
        hdr.src_db_name,
        hdr.src_table_name,
        hdr.src_schema_name,
        COUNT(*), count(distinct dtl.src_rowid), MIN(src_rowid)
    FROM dbo.mpi_pre_load_dtl_prov dtl
        INNER JOIN dbo.mpi_pre_load_prov hdr
            ON dtl.mpi_pre_load_prov_rowid = hdr.mpi_pre_load_prov_rowid
    GROUP BY hdr.clientid,
        hdr.src_db_name,
        hdr.src_table_name,
        hdr.src_schema_name
	having COUNT(*) <> count(distinct dtl.src_rowid)


exec [prBuildMPIXrefProvider] 
	@iLoadInstanceID = 1, -- IMIAdmin..ClientProcessInstance.LoadInstanceID
	@bProcessProvider = 15090,
	@bSingleClient = 1 ,
	@vcClient  = 'United'

*/




/*************************************************************************************
Procedure:	prBuildMPIXrefProvider
Author:		Leon Dowling
Copyright:	© 2015
Date:		20150101
Purpose:	To load MPI cross reference tables in the IMIDataStore with Staffmark
		data
Parameters:	
Depends On:	

Calls:
Called By:	dbo.prBuildMPIXref
Returns:	None
Update Log: 

Test Script:	

	EXEC prBuildMPIXrefProvider 1

Change Log:
20170405	CjC		Change tmp_mp_pre_load_prov and _mbr to dbo.tmp_mp_pre_load_ as it was causing invalid object errors
*************************************************************************************/

--/*
CREATE PROCEDURE [dbo].[prBuildMPIXrefProvider] 
(
	@iLoadInstanceID	int	, -- IMIAdmin..ClientProcessInstance.LoadInstanceID
	@bProcessProvider BIT = 1,
	@bSingleClient BIT = 0 ,
	@vcClient VARCHAR(20) = NULL
)
AS
--	SET NOCOUNT ON

BEGIN TRY

--*/
/*-----------------------------------------------------
DECLARE @iLoadInstanceID	int	, -- IMIAdmin..ClientProcessInstance.LoadInstanceID
	@bProcessProvider BIT,
	@bSingleClient BIT ,
	@vcClient VARCHAR(20) 
	

SELECT @iLoadInstanceID	= 1, -- IMIAdmin..ClientProcessInstance.LoadInstanceID
	@bProcessProvider = 1,
	@bSingleClient = 0 ,
	@vcClient = NULL
	
--*/



	DECLARE @iRes			int,
		@iRes2 INT,
		@sysMe			sysname,
		@vcSrc_table_name	varchar( 100 ),
		@vcCmd			varchar( 4000 )

	IF @bSingleClient = 0 OR @vcClient IS NULL
		SET @vcClient = NULL

	SET @sysMe = OBJECT_NAME( @@PROCID )

	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Started'


	BEGIN
		/*************************************************************************************
			2.	Load provider content into mpi_output_provider
			2.1	Find MPI GUIDS for distinct providers in MPI staging tables
		************************************************************************************/
		IF OBJECT_ID('tempdb..#mpi_prv') IS NOT NULL
			DROP TABLE #mpi_prv

		-- Provider linking logic
		BEGIN

			IF OBJECT_ID('tempdb..#mpi_pre_load_Filter') IS NOT NULL 
				DROP TABLE #mpi_pre_load_Filter
	
			INSERT INTO imietl.MEI_Provider
					(SourceTable,
					 SourceDB,
					 SourceSchema,
					 SystemProviderID,
					 ProviderFullName,
					 ProviderLastName,
					 ProviderFirstName,
					 ProviderTaxID,
					 MasterEntityID,
					 ProviderMatchLogic
					)
			SELECT SourceTable = mplp.src_table_name,
					SourceDB = mplp.src_db_name,
					SourceSchema = mplp.src_schema_name,
					SystemProviderID = mplp.medical_provider_id,
					ProviderFullName = NULL,--mplp.prov_name,
					ProviderLastName = NULL,--mplp.last_name,
					ProviderFirstName = NULL,--mplp.first_name,
					ProviderTaxID = NULL,--mplp.prov_tax_id,
					MasterEntityID = NEWID(),
					ProviderMatchLogic = 'Medical_provider_id'
				FROM dbo.mpi_pre_load_prov mplp
					INNER JOIN (SELECT MinRowID = MIN(mplp.mpi_pre_load_prov_rowid)
									FROM dbo.mpi_pre_load_prov mplp
									WHERE ISNULL(mplp.npi_id,'') = '' 
										AND ISNULL(mplp.medical_provider_id,'') <> ''
									GROUP BY mplp.clientid, mplp.medical_provider_id
								) flt
						ON mplp.mpi_pre_load_prov_rowid = flt.MinRowID

			EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 
					'Records Inserted', 
					@@ROWCOUNT, 
					'imietl.MEI_Provider', 
					'imietl.MEI_Provider : Providers w Medical Provider ID ', 
					@@ROWCOUNT

			-- Create MPI link
			BEGIN
				IF OBJECT_ID('tempdb..#mpi_prv') IS NOT NULL 
					drop TABLE #mpi_prv

				-- Provider w/ NPI
				SELECT  sourcename = a.src_name, 
						SourceEntityID = a.mpi_pre_load_prov_rowid,
						MasterEntityID = b.MasterEntityID,
						EntityTYpe = 'HealthCare Provider'
					INTO #mpi_prv
					FROM dbo.mpi_pre_load_prov a
						INNER JOIN imietl.MEI_Provider b
							ON ISNULL(a.NPI_ID,'') = ''
							AND b.SystemProviderID=  a.medical_provider_id

				EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 
					'Records Inserted', 
					@@ROWCOUNT, 
					'#mpi_prov', 
					'#mpi_prov : Providers w/o NPI', 
					@@ROWCOUNT

			END
					
		END

		CREATE INDEX fk ON #mpi_prv (sourcename, SourceEntityID, MasterEntityID)
		CREATE STATISTICS sp ON #mpi_prv (sourcename, SourceEntityID, MasterEntityID)


		-- Create Temp Tables for MPI_pre tables

		IF object_id('dbo.tmp_mpi_pre_load_prov') IS NOT NULL
			DROP TABLE dbo.tmp_mpi_pre_load_prov

		CREATE TABLE dbo.tmp_mpi_pre_load_prov
			(
			[mpi_pre_load_prov_rowid] [bigint] NOT NULL,
			[src_name] [varchar] (100) NULL,
			[src_table_name] [varchar] (100) NULL,
			[src_db_name] [varchar] (100) NULL,
			[src_schema_name] [varchar] (100) NULL,
			char_mpi_pre_load_prov_rowid VARCHAR(20),
			[clientid] [varchar] (20) NOT NULL)


		INSERT INTO dbo.tmp_mpi_pre_load_prov
		SELECT mpi_pre_load_prov_rowid,
				src_name,
				src_table_name,
				src_db_name,
				src_schema_name,
				char_mpi_pre_load_prov_rowid = CONVERT(VARCHAR(20),mpi_pre_load_prov_rowid),
				ClientID
			FROM dbo.mpi_pre_load_prov
			--WHERE ClientID = ISNULL(@vcClient,ClientID)

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, 'dbo.tmp_mpi_pre_load_prov', 
			'FROM mpi_pre_load_prov', @@ROWCOUNT

		CREATE INDEX fk ON dbo.tmp_mpi_pre_load_prov (mpi_pre_load_prov_rowid, src_name, char_mpi_pre_load_prov_rowid, ClientID, src_table_name, src_db_name, src_schema_name) 
		CREATE STATISTICS sp ON dbo.tmp_mpi_pre_load_prov (mpi_pre_load_prov_rowid, src_name, char_mpi_pre_load_prov_rowid, ClientID, src_table_name, src_db_name, src_schema_name)		

		IF object_id('dbo.tmp_mpi_pre_load_dtl_prov') IS NOT NULL
			DROP TABLE dbo.tmp_mpi_pre_load_dtl_prov

		CREATE TABLE dbo.tmp_mpi_pre_load_dtl_prov
			(Src_rowID BIGINT,
			[mpi_pre_load_prov_rowid] [bigint] NOT NULL,
			[src_name] [varchar] (100) NULL,
			char_mpi_pre_load_prov_rowid VARCHAR(20),
			mpi_srcname VARCHAR(100),
			[clientid] [varchar] (20) NOT NULL,
			[src_table_name] [varchar] (100) NULL,
			[src_db_name] [varchar] (100) NULL,
			[src_schema_name] [varchar] (100) NULL
			)

		INSERT INTO dbo.tmp_mpi_pre_load_dtl_prov 
		SELECT a.src_rowid,
				a.mpi_pre_load_prov_rowid,
				b.src_name,
				b.char_mpi_pre_load_prov_rowid,
				mpi_srcname  = b.ClientID + '|' + b.src_Table_name,
				b.clientid,
				b.src_table_name,
				b.src_db_name,
				b.src_schema_name
			FROM mpi_pre_load_dtl_prov a
				INNER JOIN dbo.tmp_mpi_pre_load_prov b
					ON a.mpi_pre_load_prov_rowid = b.mpi_pre_load_prov_rowid 


		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#mpi_pre_load_dtl_prov', 
			'FROM mpi_pre_load_dtl_prov', @@ROWCOUNT
	
		CREATE INDEX fk ON dbo.tmp_mpi_pre_load_dtl_prov  (mpi_pre_load_prov_rowid, src_rowid) 
		CREATE STATISTICS sp ON dbo.tmp_mpi_pre_load_dtl_prov  (mpi_pre_load_prov_rowid, src_rowid)

		CREATE INDEX fk2 ON dbo.tmp_mpi_pre_load_dtl_prov (mpi_pre_load_prov_rowid, char_mpi_pre_load_prov_rowid, src_rowid) 
		CREATE STATISTICS sp2 ON dbo.tmp_mpi_pre_load_dtl_prov (mpi_pre_load_prov_rowid, char_mpi_pre_load_prov_rowid, src_rowid) 

		/*************************************************************************************
			2.2	Remove MPI GUIDS that link to multiple providers in MPI staging 
				tables
		************************************************************************************/
		IF OBJECT_ID('tempdb..#dup_mpi_prv') IS NOT NULL
		DROP TABLE #dup_mpi_prv

		SELECT	sourcename, SourceEntityID, MAX(CONVERT(VARCHAR(50),MasterEntityID)) max_id
			INTO	#dup_mpi_prv
			FROM	#mpi_prv
			GROUP BY 
				sourcename, SourceEntityID
			HAVING	COUNT(*) > 1

		IF @@ROWCOUNT > 0
		BEGIN
			DELETE	a
				OUTPUT	DELETED.SourceName,
					DELETED.SourceEntityID,
					DELETED.MasterEntityID,
					DELETED.EntityType,
					@iLoadInstanceID,
					GETDATE()
					INTO	mpi_dupe_deleted
				FROM	#mpi_prv a
							JOIN #dup_mpi_prv b
						ON a.SourceName = b.sourcename
						AND a.SourceEntityID= b.SourceEntityID
						AND CONVERT(VARCHAR(50),a.MasterEntityID) <> b.max_id

			EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Deleted', @@ROWCOUNT, '#mpi_prv', 
			'#mpi_prv : records deleted due to dup sourcename, SourceEntityID', @@ROWCOUNT

		END
		/*************************************************************************************
			2.3	Report distinct provider and provider dtl records that don't link 
				to MPI master entity
		************************************************************************************/
		SELECT	@iRes = COUNT( * )
			FROM	dbo.tmp_mpi_pre_load_dtl_prov a 
				JOIN dbo.tmp_mpi_pre_load_prov prv
					ON a.mpi_pre_load_prov_rowid = prv.mpi_pre_load_prov_rowid
				LEFT JOIN #mpi_prv mpi
					ON mpi.SourceName = prv.src_name
					AND CONVERT( varchar( 20 ), a.mpi_pre_load_prov_rowid ) = mpi.SourceEntityID
			WHERE	mpi.SourceName IS NULL

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Record Count', @iRes, 'mpi_pre_load_dtl_prov', 
			'records in mpi_pre_load_dtl_prov without link in #mpi_prv', @ires

		SELECT	@iRes = COUNT(DISTINCT prv.mpi_pre_load_prov_rowid)
			FROM	dbo.tmp_mpi_pre_load_dtl_prov a 
				JOIN dbo.tmp_mpi_pre_load_prov prv
					ON a.mpi_pre_load_prov_rowid = prv.mpi_pre_load_prov_rowid
				LEFT JOIN #mpi_prv mpi
					ON mpi.SourceName = prv.src_name
					AND CONVERT( varchar( 20 ), a.mpi_pre_load_prov_rowid ) = mpi.SourceEntityID
			WHERE	mpi.SourceName IS NULL

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Record Count', @iRes, 'mpi_pre_load_dtl_prov', 
			'Distinct Providers in mpi_pre_load_dtl_prov without link in #mpi_prv', @iRes



		/*************************************************************************************
			2.4	Create ihds_member_id's for all new provider related MPI master 
				entities
		************************************************************************************/



		INSERT	INTO dbo.dw_xref_ihds_prov_id( ihds_mpi_id, create_datetime, update_datetime)
		SELECT	DISTINCT mpi.MasterEntityID, GETDATE(), GETDATE()
		FROM	#mpi_prv mpi 
			JOIN dbo.tmp_mpi_pre_load_prov prv
				ON prv.src_name = mpi.SourceName  
				AND CONVERT( varchar( 20 ), prv.mpi_pre_load_prov_rowid ) = mpi.SourceEntityID
			LEFT JOIN dbo.dw_xref_ihds_prov_id b
				ON mpi.MasterEntityId = b.ihds_mpi_id            
		WHERE	mpi.MasterEntityID IS NOT NULL
			AND b.ihds_mpi_id IS NULL


		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, 'dw_xref_ihds_prov_id', 
			'dw_xref_ihds_prov_id : FROM #mpi_prv (pmd_mpi..vw_master_xref)', @@ROWCOUNT

		/*************************************************************************************
			2.5	2nd look for dups where 1 source record links to 2 mpi guids
		************************************************************************************/
		IF OBJECT_ID('tempdb..#mpi_dups_prov') IS NOT NULL
			DROP TABLE #mpi_dups_prov

		SELECT	a.SourceEntityID, c.ihds_prov_id, c.ihds_mpi_id, c.create_datetime
			INTO	#mpi_dups_prov
			FROM (	SELECT	mpi.SourceName, SourceEntityID, COUNT(*) cnt
			FROM	#mpi_prv mpi 
			GROUP BY 
				mpi.SourceName, SourceEntityID
			HAVING	COUNT(*) > 1 ) a
			JOIN #mpi_prv b
				ON a.sourceName = b.sourcename
				AND a.sourceentityid = b.SourceEntityID
			JOIN dbo.dw_xref_ihds_prov_id c
				ON b.MasterEntityID = c.ihds_mpi_id
			JOIN dbo.tmp_mpi_pre_load_prov d
				ON a.sourceName = d.src_name
				AND a.SourceEntityID = CONVERT( varchar( 20 ), d.mpi_pre_load_prov_rowid )
			ORDER BY a.SourceEntityID, create_datetime

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#mpi_prov_dups', 
			'Duplicate records based on mpi.SourceName, mpi.SourceEntityID', @@ROWCOUNT

		/*************************************************************************************
			2.6	Populate dbo.mpi_output_provider
		************************************************************************************/
		IF OBJECT_ID('tempdb..#mpi_omit_prov') IS NOT NULL
			DROP TABLE #mpi_omit_prov

		SELECT	DISTINCT a.ihds_prov_id
			INTO	#mpi_omit_prov
			FROM	#mpi_dups_prov a
				LEFT JOIN (	SELECT	SourceEntityID, MIN( ihds_prov_id ) AS min_ihds_prov_id
						FROM	#mpi_dups_prov
						GROUP BY 
							SourceEntityID ) b
					ON a.ihds_prov_id = b.min_ihds_prov_id
			WHERE	b.SourceEntityID IS NULL                    

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#mpi_omit_prov', 
			'ihds_prov_ids that are omitted from build process', @@ROWCOUNT

		CREATE INDEX fk ON #mpi_omit_prov (ihds_prov_id)
		CREATE STATISTICS sp ON #mpi_omit_prov (ihds_prov_id)

		TRUNCATE TABLE dbo.mpi_output_provider

		EXEC dbo.uspAlterIndex @vcTableName = 'mpi_output_provider', -- varchar(100)
			@cAction = 'D'

		TRUNCATE TABLE mpi_output_provider

		EXEC IMIETL.prManageIMIStagingIndexANDFilegroup
			@iLoadInstanceID		= @iLoadInstanceID,
			@bDebug					= 0,
			@bExec					= 1,
			@vcSpecificTable		= 'mpi_output_provider',
			@bDropIndexes			= 1,
			@bIncludeClusteredIndexes  = 1,
			@bCreateIndexes			= 0,
			@vcSpecificSchema		= 'dbo'

		INSERT INTO dbo.mpi_output_provider( clientid, src_table_name, src_db_name, src_schema_name, src_rowid,
			ihds_prov_id_attending, ihds_prov_id_billing, ihds_prov_id_pcp, ihds_prov_id_referring,
			ihds_prov_id_servicing ) 
			SELECT	clientid = prv.clientid,
					src_table_name = prv.src_table_name,
					src_db_name = prv.src_db_name,
					src_schema_name = prv.src_schema_name,
					src_rowid = a.src_rowid,
					ihds_prov_id_attending = 0,
					ihds_prov_id_billing = 0,
					ihds_prov_id_pcp = 0,
					ihds_prov_id_referring = 0,
					ihds_prov_id_servicing = xrf.ihds_prov_id
				FROM dbo.tmp_mpi_pre_load_dtl_prov a WITH (INDEX (fk2))
					JOIN dbo.tmp_mpi_pre_load_prov prv WITH (INDEX (fk))
						ON a.mpi_pre_load_prov_rowid = prv.mpi_pre_load_prov_rowid
						--AND prv.src_table_name NOT IN ('ct_claims_data')
					JOIN #mpi_prv mpi-- pmd_mpi..vw_master_xref mpi 
						ON mpi.SourceName = prv.src_name
						AND a.char_mpi_pre_load_prov_rowid = mpi.SourceEntityID
					JOIN dw_xref_ihds_prov_id xrf WITH (INDEX(ixMain))
						ON mpi.MasterEntityID = xrf.ihds_mpi_id
			--			AND prv.clientid = xrf.clientid
					LEFT JOIN #mpi_omit_prov omit
						ON xrf.ihds_prov_id = omit.ihds_prov_id
				WHERE	omit.ihds_prov_id IS NULL

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, 'mpi_output_provider', 
			'mpi_output_provider: from mpi_pre_load_dtl_prov- not ct_claims_data', @@ROWCOUNT

		EXEC IMIETL.prManageIMIStagingIndexANDFilegroup
			@iLoadInstanceID		= @iLoadInstanceID,
			@bDebug					= 0,
			@bExec					= 1,
			@vcSpecificTable		= 'mpi_output_provider',
			@bDropIndexes			= 0,
			@bIncludeClusteredIndexes  = 1,
			@bCreateIndexes			= 1,
			@vcSpecificSchema		= 'dbo'

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Status', 1, 'mpi_output_provider', 
			'mpi_output_provider: ReIndex complete', 1


		--IF @vcClient IS NULL
		--BEGIN
		--	PRINT 'mpi_output_provider create'
		--	EXEC dbo.uspAlterIndex @vcTableName = 'mpi_output_provider', -- varchar(100)
		--		@cAction = 'C'
		--END
		/*************************************************************************************
			2.7	Remove duplicates from dbo.mpi_output_provider
		************************************************************************************/
		IF OBJECT_ID('tempdb..#provdup') IS NOT NULL
			DROP TABLE #provdup

		SELECT	clientid, src_table_name, src_rowid, src_schema_name,  COUNT(*) cnt
			INTO	#provdup
			FROM	dbo.mpi_output_provider
			GROUP BY 
				clientid, src_table_name, src_rowid, src_schema_name
			HAVING	COUNT(*) > 1

		IF @@ROWCOUNT > 0
		BEGIN
			CREATE INDEX fk_provdup ON #provdup (clientid, src_table_name, src_rowid)
			CREATE STATISTICS sp_fk_provdup ON [#provdup] (clientid, src_table_name, src_rowid)

			DELETE	a
				FROM	dbo.mpi_output_provider a 
					JOIN #provdup b
						ON a.clientid = b.clientid
						AND a.src_table_name = b.src_table_name
						AND a.src_rowid = b.src_rowid
						AND a.src_schema_name = b.src_schema_name

			EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Deleted', @@ROWCOUNT, 'mpi_output_provider', 
			'mpi_output_provider: deleted due to clientid, src_table_name, src_rowid dup', @@ROWCOUNT
		END
	END

	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Completed'
--/*
END TRY

BEGIN CATCH
	DECLARE @iErrorLine int,
		@iErrorNumber int,
		@iErrorSeverity int,
		@iErrorState int,
		@nvcErrorMessage nvarchar(2048),
		@nvcErrorProcedure nvarchar(126)

	-- capture error info so we can fail it up the line
	SELECT  @iErrorLine = ERROR_LINE(),
		@iErrorNumber = ERROR_NUMBER(),
		@iErrorSeverity = ERROR_SEVERITY(),
		@iErrorState = ERROR_STATE(),
		@nvcErrorMessage = ERROR_MESSAGE(),
		@nvcErrorProcedure = ERROR_PROCEDURE()
		
	INSERT  INTO IMIAdmin..ErrorLog( ErrorLine, ErrorMessage, ErrorNumber, ErrorProcedure,
		ErrorSeverity, ErrorState, ErrorTime, InstanceID, UserName )
	SELECT  @iErrorLine,
		@nvcErrorMessage,
		@iErrorNumber,
		@nvcErrorProcedure,
		@iErrorSeverity,
		@iErrorState,
		GETDATE(),
		InstanceID,
		SUSER_SNAME()
	FROM    IMIAdmin..ClientProcessInstance
	WHERE   LoadInstanceID = @iLoadInstanceID

	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Failed'

	RAISERROR ( @nvcErrorMessage, @iErrorSeverity, @iErrorState ) ;
END CATCH
--*/









GO
