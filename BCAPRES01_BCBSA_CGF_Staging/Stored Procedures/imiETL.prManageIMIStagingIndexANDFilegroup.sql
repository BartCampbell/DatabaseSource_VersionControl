SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*************************************************************************************
Procedure:	IMIETL.prManageIMIStagingIndexANDFilegroup
Author:		Leon Dowling
Copyright:	© 2016
Date:		2016.01.01
Purpose:	
Parameters: 
Depends On:	
Calls:		
Called By:	
Returns:	None
Notes:		
Update Log:

Test Script: 

EXEC IMIETL.prManageIMIStagingIndexANDFilegroup
	@iLoadInstanceID		= 1,
	@bDebug					= 1,
	@bExec					= 1,
	@vcSpecificTable		= 'member',
	@bDropIndexes			= 0,
	@bIncludeClusteredIndexes  = 1,
	@bCreateIndexes			= 1,
	@vcSpecificSchema		= 'dbo'


*/

--/*
CREATE PROC [imiETL].[prManageIMIStagingIndexANDFilegroup]

	@iLoadInstanceID INT = 1,
	@bDebug BIT = 1,
	@bExec BIT = 1,
	@vcSpecificTable VARCHAR(50),--= 'Member',
	@bDropIndexes BIT = 1,
	@bIncludeClusteredIndexes BIT = 1,
	@bCreateIndexes BIT = 1,
	@vcSpecificSchema VARCHAR(50) = 'dbo'

AS
--*/
/*--------------------------------
DECLARE
	@iLoadInstanceID INT = 1,
	@bDebug BIT = 1,
	@bExec BIT = 1,
	@vcSpecificTable VARCHAR(50) = NULL,
	@bDropIndexes BIT = 0,
	@bIncludeClusteredIndexes BIT = 1,
	@bCreateIndexes BIT = 1,
	@vcSpecificSchema VARCHAR(50) = 'dbo'

--*/------------------------------
DECLARE @vcCmd VARCHAR(8000),
	@vcCmd2 VARCHAR(8000),
	@nvCmd NVARCHAR(4000),
	@nvCmd2 NVARCHAR(4000),
	@i INT,
	@vcDBFileName VARCHAR(100),
	@vcFGName VARCHAR(50),
	@vcIDXDBFileName VARCHAR(1000),
	@vcIDXFGName VARCHAR(100),
	@vcDataFGPath VARCHAR(100),
	@vcIDXFGPath VARCHAR(100)


DECLARE @vcDBName VARCHAR(200) 

SELECT @vcDBName = MIN(TABLE_CATALOG)
	FROM INFORMATION_SCHEMA.TABLES

IF OBJECT_ID('imiETL.IMIStagingStandardIndexes') IS NULL 
	CREATE TABLE imiETL.IMIStagingStandardIndexes
		(RowID INT IDENTITY(1,1),
		TabSchema VARCHAR(50),
		TabName VARCHAR(50),
		IndexName VARCHAR(50),
		ClusteredIndexFlag BIT,
		IndexFields VARCHAR(1000),
		IncludeFields VARCHAR(1000),
		DataFGPath VARCHAR(100),
		IndexFGPath VARCHAR(100)
		)

TRUNCATE TABLE imiETL.IMIStagingStandardIndexes

INSERT INTO imiETL.IMIStagingStandardIndexes
        ( TabSchema ,
          TabName ,
          IndexName ,
          ClusteredIndexFlag ,
          IndexFields ,
          IncludeFields,
		  DataFGPath ,
		  IndexFGPath
        )
	-- Prov MPI Tables
		--mpi_pre_load_dtl_prov
			SELECT TabSchema = 'dbo',
					  TabName = 'mpi_pre_load_dtl_prov',
					  IndexName = 'fk_dtl_prov',
					  ClusteredIndexFlag = 1,
					  IndexFields = 'mpi_pre_load_prov_rowid, src_rowid',
					  IncludeFields = NULL,
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'
		--mpi_pre_load_prov

			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'mpi_pre_load_prov',
					  IndexName = 'fk_dtllink',
					  ClusteredIndexFlag = 1,
					  IndexFields = 'mpi_pre_load_prov_rowid, clientid, src_table_name, src_db_name, src_schema_name',
					  IncludeFields = NULL,
					  DataFGPath = 'j:\sql.data\',
					  IndexFGPath = 'i:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'mpi_pre_load_prov',
					  IndexName = 'fk_hashvalue',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'hashvalue, mpi_pre_load_prov_rowid',
					  IncludeFields = NULL,
					  DataFGPath = 'j:\sql.data\',
					  IndexFGPath = 'i:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'mpi_pre_load_prov',
					  IndexName = 'fk_rowid_srcname',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'mpi_pre_load_prov_rowid, src_name',
					  IncludeFields = NULL,
					  DataFGPath = 'j:\sql.data\',
					  IndexFGPath = 'i:\sql.data\'
		--mpi_output_provider
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'mpi_output_provider',
					  IndexName = 'idxMPI_output_provider',
					  ClusteredIndexFlag = 1,
					  IndexFields = 'clientid, src_table_name, src_db_name, src_schema_name, src_rowid',
					  IncludeFields = NULL,
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'mpi_output_provider',
					  IndexName = 'idxclient_src_tab_rowid',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'clientid, src_table_name, src_rowid',
					  IncludeFields = NULL,
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'
	-- Member MPI Tables
		--mpi_pre_load_dtl_member
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'mpi_pre_load_dtl_member',
					  IndexName = 'fk_pre_load_id_src_row_id',
					  ClusteredIndexFlag = 1,
					  IndexFields = 'mpi_pre_load_rowid, src_rowid',
					  IncludeFields = NULL,
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'
		--mpi_pre_load_member
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'mpi_pre_load_member',
					  IndexName = 'pk_mpi_pre_load_member1',
					  ClusteredIndexFlag = 1,
					  IndexFields = 'mpi_pre_load_rowid, clientid, src_table_name, src_db_name, src_schema_name',
					  IncludeFields = NULL,
					  DataFGPath = 'j:\sql.data\',
					  IndexFGPath = 'i:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'mpi_pre_load_member',
					  IndexName = 'fk_hashvalue',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'hashvalue, mpi_pre_load_rowid',
					  IncludeFields = NULL,
					  DataFGPath = 'j:\sql.data\',
					  IndexFGPath = 'i:\sql.data\'
		--mpi_output_member
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'mpi_output_member',
					  IndexName = 'pk_mpi_output_member',
					  ClusteredIndexFlag = 1,
					  IndexFields = 'clientid, src_table_name, src_db_name, src_schema_name, src_rowid, ihds_member_id',
					  IncludeFields = NULL,
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'mpi_output_member',
					  IndexName = 'fk_client_src_tab_rowid',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'clientid, src_schema_name, src_table_name, src_rowid',
					  IncludeFields = NULL,
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'

	-- Core Staging tables
		--Member 
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'member',
					  IndexName = 'idxMemberID',
					  ClusteredIndexFlag = 1,
					  IndexFields = 'MemberID, ihds_member_id',
					  IncludeFields = NULL,
					  DataFGPath = 'g:\sql.data\',
					  IndexFGPath = 'f:\sql.data\'
		--Eligibility
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'Eligibility',
					  IndexName = 'idxMemberID',
					  ClusteredIndexFlag = 1,
					  IndexFields = 'MemberID, EligibilityID',
					  IncludeFields = NULL,
					  DataFGPath = 'f:\sql.data\',
					  IndexFGPath = 'g:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'Eligibility',
					  IndexName = 'idxEligibilityID',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'EligibilityID, memberID',
					  IncludeFields = NULL,
					  DataFGPath = 'f:\sql.data\',
					  IndexFGPath = 'g:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'Eligibility',
					  IndexName = 'idxClient',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'Client, LoadInstanceFileID',
					  IncludeFields = NULL,
					  DataFGPath = 'f:\sql.data\',
					  IndexFGPath = 'g:\sql.data\'
		--Provider
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'Provider',
					  IndexName = 'idxProviderID',
					  ClusteredIndexFlag = 1,
					  IndexFields = 'ProviderID, ihds_prov_id',
					  IncludeFields = NULL,
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'Provider',
					  IndexName = 'idxIHDS_Prov_id',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'ihds_prov_id, ProviderID',
					  IncludeFields = NULL,
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'Provider',
					  IndexName = 'idxNPI',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'NPI, ProviderID',
					  IncludeFields = NULL,
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'
		--Claim
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'Claim',
					  IndexName = 'idxMemberID',
					  ClusteredIndexFlag = 1,
					  IndexFields = 'MemberID, ClaimID',
					  IncludeFields = NULL,
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'Claim',
					  IndexName = 'idxClaimID',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'ClaimID ',
					  IncludeFields = 'DateServiceBegin, MemberID',
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'Claim',
					  IndexName = 'idxClientClaimID',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'Client, ClaimID',
					  IncludeFields = NULL,
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'
		--ClaimLineItem
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'ClaimLineItem',
					  IndexName = 'idxClaimID',
					  ClusteredIndexFlag = 1,
					  IndexFields = 'ClaimID, ClaimLineItemID',
					  IncludeFields = NULL,
					  DataFGPath = 'j:\sql.data\',
					  IndexFGPath = 'i:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'ClaimLineItem',
					  IndexName = 'idxClaimLineItemID',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'ClaimLineItemID',
					  IncludeFields = 'DateServiceBegin, ClaimID',
					  DataFGPath = 'j:\sql.data\',
					  IndexFGPath = 'i:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'ClaimLineItem',
					  IndexName = 'idxClientClaimID',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'Client, ClaimID',
					  IncludeFields = NULL,
					  DataFGPath = 'j:\sql.data\',
					  IndexFGPath = 'i:\sql.data\'
		--PharmacyClaim
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'PharmacyClaim',
					  IndexName = 'idxmemberID',
					  ClusteredIndexFlag = 1,
					  IndexFields = 'MemberID, PharmacyClaimID',
					  IncludeFields = NULL,
					  DataFGPath = 'j:\sql.data\',
					  IndexFGPath = 'i:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'PharmacyClaim',
					  IndexName = 'idxPharmacyClaimID',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'PharmacyClaimID',
					  IncludeFields = 'DateDispensed, MemberID',
					  DataFGPath = 'j:\sql.data\',
					  IndexFGPath = 'i:\sql.data\'
		--LabResult
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'LabResult',
					  IndexName = 'idxmemberID',
					  ClusteredIndexFlag = 1,
					  IndexFields = 'MemberID, LabResultID',
					  IncludeFields = NULL,
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'
			UNION 
			SELECT TabSchema = 'dbo',
					  TabName = 'LabResult',
					  IndexName = 'idxLabResultID',
					  ClusteredIndexFlag = 0,
					  IndexFields = 'LabResultID',
					  IncludeFields = 'DateOfService',
					  DataFGPath = 'i:\sql.data\',
					  IndexFGPath = 'j:\sql.data\'




IF OBJECT_ID('tempdb..#ProcLIst') IS NOT NULL 
	DROP TABLE #procList

CREATE TABLE #procList
	(RowID INT IDENTITY(1,1),
		TabSchema VARCHAR(50),
		TabName VARCHAR(50),
		IndexName VARCHAR(50),
		ClusteredIndexFlag BIT,
		IndexFields VARCHAR(1000),
		IncludeFields VARCHAR(1000),
		DataFGPath VARCHAR(200),
		IndexFGPath VARCHAR(200)
		)

INSERT INTO #procList
        ( TabSchema ,
          TabName ,
          IndexName ,
          ClusteredIndexFlag ,
          IndexFields ,
          IncludeFields,
		  DataFGPath ,
		  IndexFGPath
        )
SELECT TabSchema ,
          TabName ,
          IndexName ,
          ClusteredIndexFlag ,
          IndexFields ,
          IncludeFields ,
		  DataFGPath ,
		  IndexFGPath
	FROM imiETL.IMIStagingStandardIndexes
	WHERE TabName = ISNULL(@vcSpecificTable,tabname)

IF @bDebug = 1
	SELECT * FROM #procList

DECLARE @vcTabName VARCHAR(100)


IF OBJECT_ID('tempdb..#CurrentIdxList') IS NOT NULL 
	DROP TABLE #CurrentIdxList;

WITH    TYPED_COLUMNS
            AS (SELECT name = '[' + col.name + '] ',
                    col.is_nullable,
                    col.user_type_id,
                    col.max_length,
                    col.object_id,
                    col.column_id,
                    [type_name] = '[' + typ.name + '] '
                FROM sys.columns col
                    JOIN sys.types typ
                        ON typ.user_type_id = col.user_type_id
                ),
        INDEX_COLUMNS
            AS (SELECT col.*,
                    k.index_id,
                    k.is_included_column,
                    k.key_ordinal,
                    k.is_descending_key
                FROM TYPED_COLUMNS col
                    JOIN sys.index_columns AS k
                        ON k.object_id = col.object_id
                            AND k.column_id = col.column_id
                )
SELECT TabSchema = sch.name,
		TabName = obj.name,
		Index_name = i.name,
		Index_fields = REPLACE(ISNULL((SELECT col.name
                                                + CASE
                                                WHEN is_descending_key = 1
                                                THEN 'DESC'
                                                ELSE 'ASC'
                                                END AS [data()]
                                            FROM INDEX_COLUMNS col
                                            WHERE col.object_id = i.object_id
                                                AND col.index_id = i.index_id
                                                AND col.is_included_column <> 1
                                                AND i.type IN (1,
                                                2)
                                            ORDER BY key_ordinal
                                            FOR
                                            XML PATH('')
                                            ),
                                            (SELECT '['
                                                + col.name
                                                + '] ' AS [data()]
                                            FROM sys.columns col
                                            WHERE col.object_id = i.object_id
                                                AND i.type = 0
                                                AND (col.user_type_id IN (
                                                48, 52, 56, 58,
                                                59, 62, 104, 127,
                                                106, 108)
                                                OR col.max_length BETWEEN 1 AND 800
                                                )
                                            ORDER BY col.is_nullable DESC
                                            FOR
                                            XML PATH('')
                                            )), ' [', ', ['),
		[includes_fields] = REPLACE('INCLUDE (*)',
                                                              '*',
                                                              REPLACE((SELECT col.name AS [data()]
                                                              FROM INDEX_COLUMNS col
                                                              WHERE col.object_id = i.object_id
                                                              AND col.index_id = i.index_id
                                                              AND col.is_included_column <> 0
                                                              ORDER BY key_ordinal,
                                                              col.column_id
                                                              FOR
                                                              XML PATH('')
                                                              ), ']  [',
                                                              '], [')),
		ClusteredFlag = CASE WHEN i.type_desc = 'CLUSTERED' THEN 1 ELSE 0 END,
		CurrentFileGroup = f.name
INTO #CurrentIdxList
FROM sys.indexes i (READPAST)
    JOIN sys.filegroups f (READPAST)
        ON i.data_space_id = f.data_space_id
    JOIN sys.tables obj (READPAST)
        ON i.object_id = obj.object_id
    JOIN sys.schemas sch
        ON obj.schema_id = sch.schema_id


DECLARE @CurrentStats TABLE (Stat_name VARCHAR(100), Stat_keys VARCHAR(1000))

-- Table loop

SELECT @vcTabName = MIN(TabName)
	FROM #procList
	WHERE Tabname = ISNULL(@vcSpecificTable,Tabname)
	
WHILE @vcTabName IS NOT NULL 
BEGIN

	IF @bDropIndexes = 1
	BEGIN

		EXEC dbo.usp_remove_auto_stats
			@lcTab = @vcTabName, 
		    @lbexec = 1, 
		    @lbReCreateIndex = 0
		
		DELETE FROM  @CurrentStats

		SELECT @vcCmd = @vcSpecificSchema + '.' + @vcTabName

		INSERT INTO @CurrentStats
		EXEC sp_helpStats @vcCmd
		
		SELECT @vcCmd = ''

		SELECT @vcCmd = @vcCmd + 'DROP STATISTICS ' + @vcTabName + '.' + Stat_name+ ';' + CHAR(13)
			FROM @CurrentStats
		IF @bDebug = 1 
			PRINT @vcCmd
		IF @bExec = 1 
			EXEC (@vcCmd)

		SELECT @vccmd = ''
		SELECT @vcCmd = @vcCmd + 'DROP INDEX ' + Index_name + ' ON ' +@vcSpecificSchema + '.' + TabName + ';' + CHAR(13)
			FROM #CurrentIdxList
			WHERE TabName = @vcTabName
				AND TabSchema = @vcSpecificSchema
				AND ClusteredFlag = 0

		IF @bDebug = 1 
			PRINT @vcCmd
		IF @bExec = 1 
		BEGIN
			EXEC (@vcCMD)
			DELETE FROM #CurrentIdxList
				WHERE TabName = @vcTabName
					AND TabSchema = @vcSpecificSchema
					AND ClusteredFlag = 0
		END

		IF @bIncludeClusteredIndexes = 1
		BEGIN


			SELECT @vccmd = ''
			SELECT @vcCmd = @vcCmd + 'DROP INDEX ' + Index_name + ' ON ' +@vcSpecificSchema + '.' + TabName + ';' + CHAR(13)
				FROM #CurrentIdxList
				WHERE TabName = @vcTabName
					AND TabSchema = @vcSpecificSchema
					AND ClusteredFlag = 1

			IF @bDebug = 1 
				PRINT @vcCmd
			IF @bExec = 1 
			BEGIN
				EXEC (@vcCMD)

				DELETE FROM #CurrentIdxList
				WHERE TabName = @vcTabName
					AND TabSchema = @vcSpecificSchema
					AND ClusteredFlag = 1

			END
		END
	
	END

	IF @bCreateIndexes = 1
	BEGIN

		-- Confirm FileGroups and Files exists
		BEGIN

			SELECT @vcDBFileName = @vcDBName + '_' + @vcSpecificSchema + '_' + TabName , --+ '.ndf',
					@vcIDXDBFileName = @vcDBName + '_' + @vcSpecificSchema + '_' + TabName + '_IDX', --+ '.ndf',
					@vcFGName = @vcSpecificSchema + '_' + TabName,
					@vcIDXFGName = @vcSpecificSchema + '_' + TabName+ '_IDX',
					@vcDataFGPath = DataFGpath,
					@vcIDXFGPath = IndexFGPath
				FROM #procList
				WHERE Rowid = (SELECT MIN(RowID) FROM #procList WHERE TabName = @vcTabName) 

			IF @bDebug = 1
			BEGIN

				PRINT '@vcDBFileName: ' +  ISNULL( @vcDBFileName,'NULL')
				PRINT '@vcIDXDBFileName: ' + ISNULL(@vcIDXDBFileName ,'NULL')
				PRINT '@vcFGName: ' + ISNULL(@vcFGName ,'NULL')
				PRINT '@vcIDXFGName: ' + ISNULL( @vcIDXFGName,'NULL')
				PRINT '@vcDataFGPatf: ' + ISNULL( @vcDataFGPath,'NULL')
				PRINT '@vcIDXFGPatf: ' + ISNULL( @vcIDXFGPath,'NULL')

			END

			-- See if FileGroup Exists
			IF NOT EXISTS (SELECT * 
								FROM sys.filegroups
								WHERE Name = @vcFGName)
			BEGIN
				SET @vcCmd = 'ALTER DATABASE ' + @vcDBName + ' ADD FILEGROUP ' + @vcFGName
				IF @bDebug = 1
					PRINT @vcCmd
				IF @bExec = 1
					EXEC (@vcCmD)
			END
			-- See if IDX FileGroup Exists
			IF NOT EXISTS (SELECT * 
								FROM sys.filegroups
								WHERE Name = @vcIDXFGName)
			BEGIN
				SET @vcCmd = 'ALTER DATABASE ' + @vcDBName + ' ADD FILEGROUP ' + @vcIDXFGName
				IF @bDebug = 1
					PRINT @vcCmd
				IF @bExec = 1
					EXEC (@vcCmD)
			END
			-- See if DB file exists
			IF NOT EXISTS (SELECT 
								[name]
							FROM sys.database_files
							WHERE Name LIKE @vcDBFileName
						) 
			BEGIN
				SELECT @vcCmd = 'ALTER DATABASE [' + @vcDBNAme + '] ADD FILE ( NAME = N''' + @vcDBFileName + ''', FILENAME = N'''
							+ @vcDataFGPath
							+ @vcDBFileName + '.ndf'', SIZE = 1GB , FILEGROWTH = 65536KB ) TO FILEGROUP [' + @vcFGName + ']'
					
		
				IF @bDebug = 1
					PRINT @vcCmd
				IF @bExec = 1
					EXEC (@vcCmD)
			END

			-- See if IDX DB file exists
			IF NOT EXISTS (SELECT 
								[name]
							FROM sys.database_files
							WHERE Name LIKE @vcIDXDBFileName
						) 
			BEGIN
				SELECT @vcCmd = 'ALTER DATABASE [' + @vcDBNAme + '] ADD FILE ( NAME = N''' + @vcIDXDBFileName + ''', FILENAME = N'''
							+ @vcIDXFGPath
							+ @vcIDXDBFileName + '.ndf'', SIZE = 1GB , FILEGROWTH = 65536KB ) TO FILEGROUP [' + @vcIDXFGName + ']'
		
				IF @bDebug = 1
					PRINT @vcCmd
				IF @bExec = 1
					EXEC (@vcCmD)
			END
		END

		--IF indexes have not been removed
		IF @bDropIndexes = 0
			AND (EXISTS (SELECT *
							FROM #procList pl
								LEFT JOIN #CurrentIdxList ci
									ON ci.TabName = pl.TabName
									AND ci.TabSchema = pl.TabSchema
									AND ci.Index_name = pl.IndexName
									AND pl.TabName = @vcTabName
									AND pl.TabSchema = @vcSpecificSchema
									AND pl.ClusteredIndexFlag = 1
							WHERE ci.CurrentFileGroup <> @vcFGName
						)
				OR EXISTS (SELECT *
							FROM #procList pl
								LEFT JOIN #CurrentIdxList ci
									ON ci.TabName = pl.TabName
									AND ci.TabSchema = pl.TabSchema
									AND ci.Index_name = pl.IndexName
									AND pl.TabName = @vcTabName
									AND pl.TabSchema = @vcSpecificSchema
									AND pl.ClusteredIndexFlag = 0
							WHERE ci.CurrentFileGroup <> @vcIDXFGName
						)
				) 
		BEGIN

			IF @bDebug = 1
				PRINT 'EXEC master.[dbo].[sp_MoveTablesToFileGroup] ' + @vcSpecificSchema + '.' + @vcTabName 
		
			PRINT '@vcFGName = ' + @vcFGName
			PRINT '@vcDefaultIndexFG = ' + @vcIDXFGName

			IF @bExec = 1
				EXEC [sp_MoveTablesToFileGroup] 
					@SchemaFilter = @vcSpecificSchema,          -- Filter which table schemas to work on
					@TableFilter = @vcTabName,          -- Filter which tables to work on
					@DataFileGroup = @vcFGName,    -- Name of filegroup that data must be moved to
					@IndexFileGroup = @vcIDXFGName,
					@LobFileGroup = NULL,         -- Name of filegroup that LOBs (if any) must be moved to
					@FromFileGroup = '%',          -- Only move objects that currenly occupy this filegroup
					@ClusteredIndexes = 1,            -- 1 = move clustered indexes (table data), else 0
					@SecondaryIndexes = 1,            -- 1 = move secondary indexes, else 0
					@Heaps  = 1,            -- 1 = move heaps (lazy-assed, unindexed crap), else 0
					@Online = 0,            -- 1 = keep indexes online (required Enterprise edition)
					@ProduceScript = 0,
					@Debug = @bDebug

		END		

		-- Confirm all indexes are in place
		BEGIN
			
			-- Check for clustered index
			IF EXISTS (SELECT *
							FROM #procList pl
								LEFT JOIN #CurrentIdxList ci
									ON ci.TabName = pl.TabName
									AND ci.TabSchema = pl.TabSchema
									AND ci.Index_name = pl.IndexName
							WHERE pl.ClusteredIndexFlag = 1
								AND ci.TabName IS NULL 
								AND pl.TabName = @vcTabName
								AND pl.TabSchema = @vcSpecificSchema
					) 			
			BEGIN
				
				SELECT @vcCmd = 'CREATE CLUSTERED INDEX ' + IndexName + ' ON ' + @vcSpecificSchema+ '.' + @vcTabName + ' (' + IndexFields + ' ) ON ' + @vcFGName + ';' + CHAR(13)
							+ 'CREATE STATISTICS sp' + IndexName + ' ON ' + @vcSpecificSchema+ '.' + @vcTabName + ' (' + IndexFields + ' ) '
					FROM #procList
					WHERE TabName = @vcTabName
						AND TabSchema = @vcSpecificSchema
						AND ClusteredIndexFlag = 1
				IF @bDebug = 1
					PRINT @vcCmd
				IF @bExec = 1
					EXEC (@vcCmd)

			END

			-- Check for non clustered indexes
			IF EXISTS (SELECT *
							FROM #procList pl
								LEFT JOIN #CurrentIdxList ci
									ON ci.TabName = pl.TabName
									AND ci.TabSchema = pl.TabSchema
									AND ci.Index_name = pl.IndexName
							WHERE pl.ClusteredIndexFlag = 0
								AND ci.TabName IS NULL 
								AND pl.TabName = @vcTabName
								AND pl.TabSchema = @vcSpecificSchema
					) 			
			BEGIN

				-- Make sure all statistics w/ same name are removed

				DELETE FROM  @CurrentStats

				SELECT @vcCmd = @vcSpecificSchema + '.' + @vcTabName

				INSERT INTO @CurrentStats

				EXEC sp_helpStats @vcCmd
				SET @vcCmd = ''

				SELECT @vcCmd = @vcCmd + ' DROP STATISTICS ' + @vcSpecificSchema+ '.' + @vcTabName + '.sp' + IndexName + CHAR(13)
					FROM #procList pl
						LEFT JOIN #CurrentIdxList ci
									ON ci.TabName = pl.TabName
									AND ci.TabSchema = pl.TabSchema
									AND ci.Index_name = pl.IndexName
						INNER JOIN @CurrentStats cs
							ON cs.Stat_name = 'sp'+indexname
					WHERE pl.ClusteredIndexFlag = 0
						AND ci.TabName IS NULL 
						AND pl.TabName = @vcTabName
						AND pl.TabSchema = @vcSpecificSchema
				IF @bDebug = 1
					PRINT @vcCmd
				IF @bExec = 1
					EXEC (@vcCmd)

				SELECT @vcCmd = ''

				SELECT @vcCmd = @vcCmd + 'CREATE INDEX ' + IndexName + ' ON ' + @vcSpecificSchema+ '.' + @vcTabName + ' (' + pl.IndexFields + ' ) '
									+ CASE WHEN ISNULL(pl.IncludeFields,'') <> '' THEN ' INCLUDE (' + pl.IncludeFields + ') '
										ELSE ''
										END
									+ ' ON ' + @vcIDXFGName + ';' + CHAR(13)
									+ ' CREATE STATISTICS sp'+ IndexName + ' ON ' + @vcSpecificSchema+ '.' + @vcTabName + ' (' + pl.IndexFields + ' );' + CHAR(13)
					FROM #procList pl
						LEFT JOIN #CurrentIdxList ci
									ON ci.TabName = pl.TabName
									AND ci.TabSchema = pl.TabSchema
									AND ci.Index_name = pl.IndexName
					WHERE pl.ClusteredIndexFlag = 0
						AND ci.TabName IS NULL 
						AND pl.TabName = @vcTabName
						AND pl.TabSchema = @vcSpecificSchema
				IF @bDebug = 1
					PRINT @vcCmd
				IF @bExec = 1
					EXEC (@vcCmd)


			END

		END-- Confirm all indexes are in place


	END --@bCreateIndexes

	SELECT @vcTabName = MIN(TabName)
		FROM #procList
		WHERE Tabname = ISNULL(@vcSpecificTable,Tabname)
			AND TabName > @vcTabName
END-- Table loop


GO
