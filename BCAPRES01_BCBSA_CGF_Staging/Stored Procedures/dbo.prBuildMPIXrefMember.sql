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
	ORDER BY hdr.clientid,
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
    FROM dbo.mpi_pre_load_dtl_member dtl
        INNER JOIN dbo.mpi_pre_load_member hdr
            ON dtl.mpi_pre_load_rowid = hdr.mpi_pre_load_rowid
    GROUP BY hdr.clientid,
        hdr.src_db_name,
        hdr.src_table_name,
        hdr.src_schema_name
	having COUNT(*) <> count(distinct dtl.src_rowid)


exec [prBuildMPIXrefMember] 
	@iLoadInstanceID = 1, -- IMIAdmin..ClientProcessInstance.LoadInstanceID
	@bProcessMember = 1,
	@bSingleClient = 1 ,
	@vcClient  = 'CCI'

*/




/*************************************************************************************
Procedure:	prBuildMPIXrefMember
Author:		Leon Dowling
Copyright:	2015
Date:		20150101
Purpose:	To load MPI cross reference tables in the IMIDataStore with Staffmark
		data
Parameters:	
Depends On:	
Calls:		
Called By:	dbo.prBuildMPIXref
Returns:	None
Notes:		None

Process:	

Test Script:	prBuildMPIXrefMember 1,1
Change Log:

ToDo:		
*************************************************************************************/

--/*
CREATE PROCEDURE [dbo].[prBuildMPIXrefMember] 
(
	@iLoadInstanceID	int	, -- IMIAdmin..ClientProcessInstance.LoadInstanceID
	@bProcessMember BIT = 1,
	@bSingleClient BIT = 0 ,
	@vcClient VARCHAR(20) = NULL
)
AS
--	SET NOCOUNT ON
--*/
/*-----------------------------------------------------
DECLARE @iLoadInstanceID	int	, -- IMIAdmin..ClientProcessInstance.LoadInstanceID
	@bProcessMember BIT,
	@bProcessProvider BIT,
	@bSingleClient BIT ,
	@vcClient VARCHAR(20) 
	

SELECT @iLoadInstanceID	= 1	, -- IMIAdmin..ClientProcessInstance.LoadInstanceID
	@bProcessMember  = 1,
	@bSingleClient = 0,
	@vcClient = NULL
	
--*/

BEGIN TRY

	DECLARE @iRes			int,
		@iRes2 INT,
		@sysMe			sysname,
		@vcSrc_table_name	varchar( 100 ),
		@vcCmd			varchar( 4000 )

	IF @bSingleClient = 0 OR @vcClient IS NULL
		SET @vcClient = NULL

	SET @sysMe = OBJECT_NAME( @@PROCID )

	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Started'

	IF ( @bProcessMember = 1 )
	BEGIN
		/*************************************************************************************
			1.	Load member content into mpi_output_member
			1.1	Find MPI GUIDS for distinct members in MPI staging tables
		************************************************************************************/

		--IF OBJECT_ID('tempdb..#mpi_mbr') IS NOT NULL
		--	DROP TABLE #mpi_mbr

		--SELECT	TOP 0 SourceName, SourceEntityID, MasterEntityID, EntityType
		--	INTO	#mpi_mbr
		--	FROM	imisql09.pmd_mpi.dbo.vw_master_xref mpi 
		--	WHERE	EntityType = 'Healthcare Patient'
		--		AND LEFT(sourcename,6) <> 'health'


		--INSERT INTO #mpi_mbr
		--	SELECT	SourceName, SourceEntityID, MasterEntityID, EntityType
		--		FROM	imisql09.pmd_mpi.dbo.vw_master_xref mpi 
		--		WHERE	EntityType = 'Healthcare Patient'
		--			AND LEFT(sourcename,6) <> 'health'

		--SELECT @vcCmd = 'SELECT * INTO ARc.tmp_ihds_member_id_xref_'+CONVERT(VARCHAR(8),GETDATE(),112) 
		--					+ '_' + CONVERT(VARCHAR(2),DATEPART(hh,GETDATE())) 
		--					+ '_' + CONVERT(VARCHAR(2),DATEPART(mi,GETDATE())) 
		--					+' FROM tmp_ihds_member_id_xref'
		--PRINT @vcCmd
		--EXEC (@vcCmd)
		
		-- Temp code to go around MEI 
		BEGIN

			INSERT INTO tmp_ihds_member_id_xref (CustomerMemberID, ClientID)
			SELECT DISTINCT CustomerMemberID = a.member_id,
					ClientID = a.clientid
				FROM dbo.mpi_pre_load_member a
					LEFT JOIN tmp_ihds_member_id_xref b
						ON a.clientid = b.ClientID
						AND a.member_id = b.CustomerMemberID
				WHERE b.CustomerMemberID IS NULL
					AND a.member_id IS NOT NULL
				
			EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, 'tmp_ihds_member_id_xref', 
				'tmp_ihds_member_id_xref: from mpi_pre_load_member', @@ROWCOUNT

			UPDATE tmp_ihds_member_id_xref
				SET MasterEntityID = NEWID()
				WHERE MasterEntityID IS NULL

			IF OBJECT_ID('tempdb..#mpi_mbr') IS NOT NULL
				DROP TABLE #mpi_mbr
					
			SELECT  sourcename = a.src_name, 
					SourceEntityID = a.mpi_pre_load_rowid,
					MasterEntityID = b.MasterEntityID,
					EntityTYpe = 'HealthCare Member'
				INTO #mpi_mbr
				FROM dbo.mpi_pre_load_member a
					INNER JOIN tmp_ihds_member_id_xref b
						ON a.member_id= b.CustomerMemberID
						AND a.clientID = b.ClientID

		END
							
		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#mpi_mbr', 
			'#mpi_mbr : FROM pmd_mpi..vw_master_xref', @@ROWCOUNT

		CREATE INDEX fk ON #mpi_mbr (SourceName, SourceEntityID)
		CREATE STATISTICS sp ON #mpi_mbr (SourceName, SourceEntityID)

		IF object_id('tempdb..#mpi_pre_load_member') IS NOT NULL
			DROP TABLE #mpi_pre_load_member

		SELECT mpi_pre_load_rowid,
				src_name,
				src_table_name,
				src_db_name,
				src_schema_name,
				char_mpi_pre_load_rowid = CONVERT(VARCHAR(20),mpi_pre_load_rowid),
				ClientID
			INTO #mpi_pre_load_member
			FROM dbo.mpi_pre_load_member
			WHERE ClientID = ISNULL(@vcClient,ClientID)

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#mpi_pre_load_member', 
			'FROM mpi_pre_load_member', @@ROWCOUNT

		CREATE INDEX fk ON #mpi_pre_load_member (mpi_pre_load_rowid, src_name, char_mpi_pre_load_rowid, ClientID, src_table_name, src_db_name, src_schema_name)
		CREATE STATISTICS sp ON #mpi_pre_load_member (mpi_pre_load_rowid, src_name, char_mpi_pre_load_rowid, ClientID, src_table_name, src_db_name, src_schema_name)		

		IF OBJECT_ID('tempdb..#mpi_pre_load_dtl_member ') IS NOT NULL	
			DROP TABLE #mpi_pre_load_dtl_member 

		SELECT a.src_rowid,
				a.mpi_pre_load_rowid,
				b.src_name,
				b.char_mpi_pre_load_rowid,
				mpi_srcname  = b.ClientID + '|' + b.src_Table_name,
				b.clientid,
				b.src_table_name,
				b.src_db_name,
				b.src_schema_name
			INTO #mpi_pre_load_dtl_member 
			FROM mpi_pre_load_dtl_member a
				INNER JOIN #mpi_pre_load_member b
					ON a.mpi_pre_load_rowid = b.mpi_pre_load_rowid 


		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#mpi_pre_load_dtl_member', 
			'FROM mpi_pre_load_dtl_member', @@ROWCOUNT
	
		CREATE INDEX fk ON #mpi_pre_load_dtl_member (mpi_pre_load_rowid, src_rowid) 
		CREATE STATISTICS sp ON #mpi_pre_load_dtl_member (mpi_pre_load_rowid, src_rowid)

		CREATE INDEX fk2 ON #mpi_pre_load_dtl_member (src_name, char_mpi_pre_load_rowid, clientid, src_table_name, src_db_name, src_schema_name, src_rowid) 
		CREATE STATISTICS sp2 ON #mpi_pre_load_dtl_member (src_name, char_mpi_pre_load_rowid, clientid, src_table_name, src_db_name, src_schema_name, src_rowid)

		/*************************************************************************************
			1.2	Remove MPI GUIDS that link to multiple members in MPI staging 
				tables
		************************************************************************************/

		IF OBJECT_ID('tempdb..#dup_mpi_mbr') IS NOT NULL
			DROP TABLE #dup_mpi_mbr

		SELECT	sourcename, SourceEntityID, COUNT(*) AS cnt
			INTO	#dup_mpi_mbr
			FROM	#mpi_mbr
			GROUP BY 
				sourcename, SourceEntityID
			HAVING	COUNT( * ) > 1

		--        DELETE a
		--	OUTPUT	DELETED.SourceName,
		--		DELETED.SourceEntityID,
		--		DELETED.MasterEntityID,
		--		DELETED.EntityType,
		--		@iLoadInstanceID,
		--		GETDATE()
		--        INTO	dbo.mpi_dupe_deleted
		--	FROM	#mpi_mbr a
		--                JOIN #dup_mpi_mbr b
		--			ON a.SourceName = b.sourcename
		--			AND a.SourceEntityID= b.SourceEntityID

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Deleted', @@ROWCOUNT, '#mpi_mbr', 
			'#mpi_mbr : records deleted due to dup sourcename, SourceEntityID', @@ROWCOUNT

		/*************************************************************************************
			1.3	Report distinct member and member dtl records that don't link 
				to MPI master entity
		************************************************************************************/
		SELECT	@vcSrc_table_name = MIN(clientid + '|' + src_table_name)
			FROM #mpi_pre_load_member 
	
		WHILE @vcSrc_table_name IS NOT NULL
		BEGIN
			SET @iRes = 0

			SELECT	@iRes = COUNT( * ),
				@iRes2 = COUNT(DISTINCT a.mpi_pre_load_rowid)
			FROM #mpi_pre_load_dtl_member a 
				LEFT HASH JOIN #mpi_mbr mpi
					ON mpi.SourceName = a.src_name
					AND mpi.SourceEntityID = a.char_mpi_pre_load_rowid
					--AND CONVERT( varchar( 20 ), a.mpi_pre_load_rowid ) = mpi.SourceEntityID
			WHERE	mpi.SourceName IS NULL
				AND a.mpi_srcname = @vcSrc_table_name

			--FROM #mpi_pre_load_dtl_member a 
			--	INNER HASH JOIN #mpi_pre_load_member mbr WITH (INDEX(fk))
			--		ON a.mpi_pre_load_rowid = mbr.mpi_pre_load_rowid
			--	LEFT HASH JOIN #mpi_mbr mpi
			--		ON mpi.SourceName = mbr.src_name
			--		AND mpi.SourceEntityID = mbr.char_mpi_pre_load_rowid
			--		--AND CONVERT( varchar( 20 ), a.mpi_pre_load_rowid ) = mpi.SourceEntityID
			--WHERE	mpi.SourceName IS NULL
			--	AND mbr.clientid + '|' + mbr.src_table_name = @vcSrc_table_name



			SELECT @vcCmd = @vcSrc_table_name + ' records in mpi_pre_load_dtl_member without link in vw_master_xref'

			EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Record Count', @iRes, 'mpi_pre_load_dtl_member', 
				@vcCmd, 0

			--SELECT	@iRes = COUNT(DISTINCT mbr.mpi_pre_load_rowid)
			--	FROM	dbo.mpi_pre_load_dtl_member a 
			--		INNER HASH JOIN #mpi_pre_load_member mbr WITH (INDEX(fk))
			--			ON a.mpi_pre_load_rowid = mbr.mpi_pre_load_rowid
			--		LEFT HASH JOIN #mpi_mbr mpi
			--			ON mpi.SourceName = mbr.src_name
			--			AND mpi.SourceEntityID = mbr.char_mpi_pre_load_rowid 
			--			--AND CONVERT( varchar( 20 ), a.mpi_pre_load_rowid ) = mpi.SourceEntityID
			--		WHERE	mpi.SourceName IS NULL
			--		AND mbr.clientid + '|' + mbr.src_table_name = @vcSrc_table_name

			SELECT @vcCmd = @vcSrc_table_name + ' Distinct Members in mpi_pre_load_dtl_member without link in vw_master_xref'

			EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Record Count', @iRes2, 'mpi_pre_load_dtl_member',
				@vcCmd, 0

			SELECT	@vcSrc_table_name = MIN(clientid + '|' + src_table_name)
					FROM	#mpi_pre_load_member 
					WHERE	clientid + '|' + src_table_name > @vcSrc_table_name


		END

		/*************************************************************************************
		1.4	Create ihds_member_id's for all new member related MPI master 
			entities
		************************************************************************************/
		INSERT INTO dbo.dw_xref_ihds_member_id( ihds_mpi_id, create_datetime, update_datetime, 
			legacy_ihds_member_id, ClientID )
		SELECT	DISTINCT mpi.MasterEntityID, GETDATE(), GETDATE(), 
			b.legacy_ihds_member_id, mbr.ClientID
		FROM	#mpi_mbr mpi 
			INNER HASH JOIN #mpi_pre_load_member mbr
				ON  mbr.src_name = mpi.SourceName  
				AND mpi.SourceEntityID = mbr.char_mpi_pre_load_rowid
				--AND CONVERT( varchar( 20 ), mbr.mpi_pre_load_rowid ) = mpi.SourceEntityID
			LEFT HASH JOIN dw_xref_ihds_member_id b
				ON mpi.MasterEntityId = b.ihds_mpi_id            
		WHERE	mpi.MasterEntityID IS NOT NULL
			AND b.ihds_mpi_id IS NULL

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, 'dw_xref_ihds_member_id', 
			'dw_xref_ihds_member_id : FROM #mpi_mbr (pmd_mpi..vw_master_xref)', @@ROWCOUNT


		/*************************************************************************************
			1.5	2nd look for dups where 1 source record links to 2 mpi guids
		************************************************************************************/
		IF object_id('tempdb..#mpi_prep_dups') IS NOT NULL
			DROP TABLE #mpi_prep_dups

		SELECT	mpi.SourceName, SourceEntityID, COUNT(*) cnt
			INTO #mpi_prep_dups
			FROM	#mpi_mbr mpi 
			GROUP BY 
				mpi.SourceName, SourceEntityID
			HAVING COUNT(*) > 1

		IF OBJECT_ID('tempdb..#mpi_dups') IS NOT NULL
			DROP TABLE #mpi_dups

		SELECT	a.SourceName, a.SourceEntityID, c.ihds_member_id, c.ihds_mpi_id, c.create_datetime
			INTO	#mpi_dups
			FROM #mpi_prep_dups a
				JOIN #mpi_mbr b
					ON a.sourceName = b.sourcename
					AND a.sourceentityid = b.SourceEntityID
				JOIN dbo.dw_xref_ihds_member_id c
					ON b.MasterEntityID = c.ihds_mpi_id
				JOIN dbo.mpi_pre_load_member d
					ON a.sourceName = d.src_name
					AND a.SourceEntityID = CONVERT( varchar( 20 ), d.mpi_pre_load_rowid )
			WHERE d.ClientID = ISNULL(@vcClient,d.ClientID)
			ORDER BY a.SourceEntityID, create_datetime

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#mpi_dups', 
		'Duplicate records based on mpi.SourceName, mpi.SourceEntityID', 0

		/*************************************************************************************
			1.6	Populate dbo.mpi_output_member
		************************************************************************************/
		IF OBJECT_ID('tempdb..#mpi_dup_keep') IS NOT NULL
			DROP TABLE #mpi_dup_keep

		SELECT	SourceName, SourceEntityID, MIN( ihds_member_id ) AS min_ihds_member_id
			INTO #mpi_dup_keep
			FROM	#mpi_dups
			GROUP BY SourceName, SourceEntityID 

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, '#mpi_omit', 
			'rec cnt kept from the #mpi_dups table', @@ROWCOUNT

		CREATE INDEX fk ON #mpi_dup_keep (SourceName, SourceEntityID, min_ihds_member_id)
		CREATE STATISTICS sp ON #mpi_dup_keep (SourceName, SourceEntityID, min_ihds_member_id)

		IF OBJECT_ID('tempdb..#mpi_omit') IS NOT NULL
			DROP TABLE #mpi_omit

		SELECT a.SourceName, 
				a.SourceEntityID,
				a.ihds_mpi_id
			INTO #mpi_omit				
			FROM #mpi_dups a
				LEFT JOIN #mpi_dup_keep b WITH (INDEX(fk))
					ON a.SourceName = b.SourceName
					AND a.SourceEntityID= b.SOurceENtityID
					AND a.ihds_member_id= b.min_ihds_member_id
			WHERE b.SourceName IS NULL

		CREATE INDEX fk ON #mpi_omit (SourceName, SourceEntityID, ihds_mpi_id)
		CREATE STATISTICS sp ON #mpi_omit (SourceName, SourceEntityID, ihds_mpi_id)

		SELECT @iRes = @@ROWCOUNT

		DELETE a			
		--SELECT count(*)
			FROM #mpi_mbr a
				 JOIN #mpi_omit b
					ON a.SourceName = b.SourceName
					AND a.SourceEntityID = b.SourceEntityID
					AND a.MasterEntityID = b.ihds_mpi_id

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Deleted', @@ROWCOUNT, '#mpi_mbr', 
		'Records deleted from #mpi_mbr due to SourceName+SourceEntityID dup', @iRes

		IF @vcClient IS NULL
			TRUNCATE TABLE dbo.mpi_output_member
		ELSE
		BEGIN

			DELETE mpi_output_member
				WHERE ClientID = ISNULL(@vcClient,ClientID)	

			EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Deleted', @@ROWCOUNT, 'Records deleted from mpi_output_member for Client', 
						@vcClient, @@RowCount
		
		END

		IF @vcClient IS NULL
		BEGIN

			EXEC imietl.prManageIMIStagingIndexANDFilegroup
				@iLoadInstanceID = @iLoadInstanceID, -- int
			    @bDebug = 0, -- bit
			    @bExec = 1, -- bit
			    @vcSpecificTable = 'mpi_output_member', -- varchar(50)
			    @bDropIndexes = 1, -- bit
			    @bIncludeClusteredIndexes = 1, -- bit
			    @bCreateIndexes = 0, -- bit
			    @vcSpecificSchema = 'dbo' -- varchar(50)
			
			--EXEC dbo.uspAlterIndex @vcTableName = 'mpi_output_member', -- varchar(100)
			--	@cAction = 'D' ,-- char(1)
			--	@bitDebug = 0

			--IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[mpi_output_member]') AND name = N'pk_mpi_output_member')
			--	ALTER TABLE mpi_output_member DROP  CONSTRAINT pk_mpi_output_member 

			--IF EXISTS (SELECT b.name, a.* 
			--			FROM sys.stats a
			--				INNER JOIN sys.objects b
			--					ON a.object_id = b.object_id
			--			WHERE b.name = 'mpi_output_member'
			--				AND a.name = 'sp_pk_mpi_output_member'
			--		) 
			--	DROP  STATISTICS mpi_output_member.sp_pk_mpi_output_member 
		END

		SELECT @iRes = COUNT(*)
			FROM #mpi_pre_load_dtl_member a 
				 JOIN #mpi_pre_load_member mbr
					ON a.mpi_pre_load_rowid = mbr.mpi_pre_load_rowid

		IF object_id('tempdb..#mpi_mbr2') IS NOT NULL 
			DROP TABLE #mpi_mbr2
	
		SELECT mpi.SourceName,
				mpi.SourceEntityID,
				xrf.ihds_member_id
			INTO #mpi_mbr2
			FROM #mpi_mbr mpi 
				INNER JOIN dw_xref_ihds_member_id xrf WITH (INDEX(fk_ihds_mpi_id))
					ON mpi.MasterEntityID = xrf.ihds_mpi_id

		CREATE INDEX fk ON #mpi_mbr2 (SourceName, SourceEntityID, ihds_member_id)
		CREATE STATISTICS sp ON #mpi_mbr2 (SourceName, SourceEntityID, ihds_member_id)

		INSERT INTO dbo.mpi_output_member( clientid, src_table_name, src_db_name, src_schema_name,
			src_rowid, ihds_member_id ) 
		SELECT	ClientID = a.clientid,
				a.src_table_name,
				a.src_db_name,
				a.src_schema_name,
				a.src_rowid,
				mpi.ihds_member_id
			FROM #mpi_pre_load_dtl_member a WITH (INDEX(fk2))
				INNER JOIN #mpi_mbr2 mpi WITH (INDEX(fk))
					ON mpi.SourceName = a.src_name
					AND mpi.SourceEntityID = a.char_mpi_pre_load_rowid 

			--FROM #mpi_pre_load_dtl_member a WITH (INDEX(fk))
			--	INNER JOIN #mpi_pre_load_member mbr WITH (INDEX(fk))--WITH (INDEX(pk_mpi_pre_load_member1))
			--		ON a.mpi_pre_load_rowid = mbr.mpi_pre_load_rowid
			--	INNER JOIN #mpi_mbr mpi WITH (INDEX(fk_mpi))
			--		ON mpi.SourceName = mbr.src_name
			--		AND mpi.SourceEntityID = mbr.char_mpi_pre_load_rowid 
			--		--AND CONVERT( varchar( 20 ), a.mpi_pre_load_rowid ) = mpi.SourceEntityID
			--	INNER JOIN dw_xref_ihds_member_id xrf
			--		ON mpi.MasterEntityID = xrf.ihds_mpi_id

		EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@ROWCOUNT, 'mpi_output_member', 
		'mpi_output_member: from mpi_pre_load_dtl_member', @iRes

		IF @vcClient IS NULL 
		BEGIN
			
			exec imietl.prManageIMIStagingIndexANDFilegroup 
				@iLoadInstanceID = @iLoadInstanceID, -- int
			    @bDebug = 0, -- bit
			    @bExec = 1, -- bit
			    @vcSpecificTable = 'mpi_output_member', -- varchar(50)
			    @bDropIndexes = 0, -- bit
			    @bIncludeClusteredIndexes = 0, -- bit
			    @bCreateIndexes = 1, -- bit
			    @vcSpecificSchema = 'dbo' -- varchar(50)
			
			--ALTER TABLE mpi_output_member ADD CONSTRAINT pk_mpi_output_member PRIMARY KEY (clientid, src_table_name, src_db_name, src_schema_name, src_rowid, ihds_member_id) ON NDX
			--CREATE STATISTICS sp_pk_mpi_output_member ON mpi_output_member (clientid, src_table_name, src_db_name, src_schema_name, src_rowid, ihds_member_id)

			--EXEC dbo.uspAlterIndex @vcTableName = 'mpi_output_member', -- varchar(100)
			--	@cAction = 'C' -- char(1)
		END
		/*************************************************************************************
			1.7	Remove duplicates from dbo.mpi_output_member
		************************************************************************************/
		IF OBJECT_ID('tempdb..#mbrdup') IS NOT NULL
			DROP TABLE #mbrdup

		SELECT	clientid, src_schema_name, src_table_name, src_rowid, COUNT(*) AS cnt
			INTO	#mbrdup
			FROM	mpi_output_member 
			GROUP BY 
				clientid, src_schema_name, src_table_name, src_rowid
			HAVING	COUNT(*) > 1
		
		IF @@ROWCOUNT > 0
		BEGIN

			CREATE INDEX fk_mbrdup ON [#mbrdup] (clientid, src_schema_name, src_table_name, src_rowid)
			CREATE STATISTICS sp_fk_mbrdup ON [#mbrdup] (clientid, src_schema_name, src_table_name, src_rowid)

			DELETE	a
				FROM	dbo.mpi_output_member a
					INNER HASH JOIN #mbrdup b
						ON a.clientid = b.clientid
						AND a.src_table_name = b.src_table_name
						AND a.src_rowid = b.src_rowid
						AND a.src_schema_name = b.src_schema_name

			EXECUTE IMIAdmin..fxSetMetrics @iLoadInstanceID, 'Records Deleted', @@ROWCOUNT, 'mpi_output_member', 
				'mpi_output_member: deleted due to clientid, src_table_name, src_rowid dup', 0

		END
		
	END

	IF OBJECT_ID('tempdb..#mpi_mbr') IS NOT NULL
		DROP TABLE #mpi_mbr
	IF OBJECT_ID('tempdb..#mpi_pre_load_dtl_member ') IS NOT NULL	
		DROP TABLE #mpi_pre_load_dtl_member 
	IF object_id('tempdb..#mpi_pre_load_member') IS NOT NULL
		DROP TABLE #mpi_pre_load_member
	IF OBJECT_ID('tempdb..#dup_mpi_mbr') IS NOT NULL
		DROP TABLE #dup_mpi_mbr
	IF object_id('tempdb..#mpi_prep_dups') IS NOT NULL
		DROP TABLE #mpi_prep_dups
	IF OBJECT_ID('tempdb..#mpi_dups') IS NOT NULL
		DROP TABLE #mpi_dups
	IF OBJECT_ID('tempdb..#mpi_dup_keep') IS NOT NULL
		DROP TABLE #mpi_dup_keep
	IF OBJECT_ID('tempdb..#mpi_omit') IS NOT NULL
		DROP TABLE #mpi_omit
	IF object_id('tempdb..#mpi_mbr2') IS NOT NULL 
		DROP TABLE #mpi_mbr2
	IF OBJECT_ID('tempdb..#mbrdup') IS NOT NULL
		DROP TABLE #mbrdup

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
