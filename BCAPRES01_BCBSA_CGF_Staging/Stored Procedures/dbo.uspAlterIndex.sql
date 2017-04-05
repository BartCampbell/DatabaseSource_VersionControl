SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	uspAlterIndex
Author:		Leon Dowling
Copyright:	© 2008
Date:		2008.01.27
Purpose:	To drop and create indexes as necessary to optimize procedure
		performance
Parameters:	@vcTableName	varchar( 100 ).........Table to process
		@cAction	char( 1 )..............D = DROP; C = CREATE
		@vcFileGroup	varchar( 50 )....OPT...Index file group
		@bitDebug	bit = 0................1 = print debug messages
		@vcPreserve	varchar( 128 )...OPT...Index that is not to be dropped
Depends On:	syscolumns
		sysindexes
		sysindexkeys
		dbo.utb_drop_indexinfo
		dbo.utb_drop_indexkeys
Calls:		sp_helpstats
		dbo.usp_remove_auto_stats
Called By:	etl procedures
Returns:	0 = success
Notes:		This statement will need to exist in any calling populate procedure:
		
		IF EXISTS(SELECT * FROM sysobjects WHERE id = OBJECT_ID('group_dim'))
			DROP TABLE #indexinfo

		CREATE TABLE #indexinfo( indexname varchar( 40 ), tableid int, indexkey varchar( 40 ))
Process:	1.	Declare/initialize variables
		2.	Load procedure creation code into table variable
		3.	Transpose to varchar and execute code
Test Script:	CREATE TABLE _a( a int, b int )
		CREATE INDEX aa ON _a( a )
		CREATE INDEX ab ON _a( b )
		EXECUTE dbo.uspAlterIndex @vcTableName	= '_a', @cAction = 'D', @vcPreserve = 'ab'
		SELECT * FROM dbo.utb_drop_indexinfo where table_name = '_a'
		SELECT * FROM dbo.utb_drop_indexkeys
		EXECUTE uspAlterIndex '_a','C'
		SELECT * FROM dbo.utb_drop_indexinfo where table_name = '_a'
		SELECT * FROM dbo.utb_drop_indexkeys
		SELECT * FROM sysindexes WHERE OBJECT_ID('_a') = id
		DROP TABLE _a
ToDo:		
*************************************************************************************/

CREATE PROCEDURE [dbo].[uspAlterIndex] 
(
	@vcTableName	varchar( 100 ),		-- Table to process
	@cAction	char( 1 ),		-- D = DROP; C = CREATE
	@vcFileGroup	varchar( 50 ) = 'NDX',	-- Index file group
--	@cResult	char( 1 ) = 'N' OUTPUT,	-- Not used
	@bitDebug	bit = 0,		-- 1 = print debug messages
	@vcPreserve	varchar( 128 ) = ''	-- Index that is not to be dropped
)
AS

DECLARE @vcCmd		varchar( 1000 ),
	@vcIndexName	varchar( 120 ),
	@siIndexID	smallint,
	@vcIndexKey	varchar( 1000 ),
--	@iTableID	int,
	@siCurrentKey	smallint

IF OBJECT_ID('tempdb..#alter_index_sp_list') IS NOT NULL
	DROP TABLE #alter_index_sp_list

CREATE TABLE #alter_index_sp_list( stat_name varchar( 200 ), stat_keys varchar( 1000 ))

INSERT INTO #alter_index_sp_list EXECUTE sp_helpstats @vcTableName

IF @cAction = 'D'
BEGIN
	IF EXISTS(	SELECT	* 
			FROM	sysindexes 
			WHERE	id = OBJECT_ID( @vcTableName ) 
				AND indid > 1 
				AND indid < 255
				AND ( status & 64 ) = 0 )
	BEGIN
		IF @bitDebug = 1
			PRINT 'uspAlterIndex, DROP ' + @vcTableName + ' :' + CONVERT( char, GETDATE())

		-- Drop all records from dbo.utb_drop_indexinfo for this table
		DELETE FROM dbo.utb_drop_indexinfo
		WHERE	UPPER( RTRIM( table_name )) = UPPER( RTRIM( @vcTableName ))
--			AND indexname <> @vcPreserve

		TRUNCATE TABLE dbo.utb_drop_indexkeys

		INSERT INTO dbo.utb_drop_indexkeys
	        SELECT	a.*, SUBSTRING( b.name, 1, 40 ) indexfield, c.name indexname
		FROM	sysindexkeys a
			JOIN sysindexes c ON a.id = c.id AND a.indid = c.indid
			JOIN syscolumns b ON a.id = b.id AND a.colid = b.colid
		WHERE	a.id = OBJECT_ID( @vcTableName )
			AND SUBSTRING( c.name, 1, 1 ) <> '_'
			AND SUBSTRING( c.name, 1, 2 ) <> 'PK'
			AND c.indid > 1
			AND c.indid < 255
 		        AND ( c.status & 64 ) = 0
			AND c.name <> ISNULL(@vcPreserve,'')

		DECLARE indexlist CURSOR FOR
		SELECT	name, indid
		FROM	sysindexes
		WHERE	id = OBJECT_ID( @vcTableName )
			AND SUBSTRING( name, 1, 1 ) <> '_'
			AND SUBSTRING( name, 1, 2 ) <> 'PK'
			AND indid > 1
			AND indid < 255
			AND ( status & 64 ) = 0
			AND name <> ISNULL(@vcPreserve,'')

--		SET @iTableID = OBJECT_ID( @vcTableName )

		OPEN indexlist
		FETCH NEXT FROM indexlist INTO @vcIndexName, @siIndexID

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--Build index key
			SET @siCurrentKey = 2

			SET @vcIndexKey = ( SELECT indexfield FROM dbo.utb_drop_indexkeys WHERE indexname = @vcIndexName AND keyno = 1 )

			WHILE ( SELECT MAX( keyno ) FROM dbo.utb_drop_indexkeys WHERE indexname = @vcIndexName ) >= @siCurrentKey
			BEGIN
				SET @vcIndexKey = ( SELECT @vcIndexKey + ',' + indexfield FROM dbo.utb_drop_indexkeys WHERE indexname = @vcIndexName AND keyno = @siCurrentKey )
				SET @siCurrentKey = @siCurrentKey + 1
			END

			INSERT INTO dbo.utb_drop_indexinfo VALUES( @vcTableName, @vcIndexName, @siIndexID, @vcIndexKey )

			IF @bitDebug = 1
				PRINT 'uspAlterIndex, DROP ' + @vcTableName + '.[' + @vcIndexName + '] :' + CONVERT( char, GETDATE())

			EXECUTE( 'DROP INDEX ' + @vcTableName + '.[' + @vcIndexName + ']' )

			IF EXISTS ( SELECT * FROM #alter_index_sp_list WHERE stat_name = 'SP_' + @vcIndexName )
			BEGIN
				SET @vcCmd = 'DROP STATISTICS ' + @vcTableName + '.sp_' + @vcIndexName 
				IF @bitDebug = 1
					PRINT 'DROP STATISTICS ' + @vcTableName + '.sp_' + @vcIndexName + '  :' + CONVERT( char, GETDATE())

				EXECUTE( @vcCmd )
			END

			FETCH NEXT FROM indexlist INTO @vcIndexName, @siIndexID
		END
		CLOSE indexlist
		DEALLOCATE indexlist
		
		
		
	END
	
	exec usp_remove_auto_stats @vcTableName,1
	
END

IF @cAction = 'C'
BEGIN
	-- Re-Create indexes
	IF @bitDebug = 1
		PRINT 'uspAlterIndex, CREATE ' + @vcTableName + ' :' + CONVERT( char, GETDATE())

	IF EXISTS(	SELECT	* 
			FROM	dbo.utb_drop_indexinfo
			WHERE	UPPER( RTRIM( table_name )) = UPPER( RTRIM( @vcTableName )))
	BEGIN
		DECLARE indexlist CURSOR FOR
	        SELECT	indexname, indexkey 
		FROM	dbo.utb_drop_indexinfo
		WHERE	UPPER( RTRIM( table_name )) = UPPER( RTRIM( @vcTableName ))

		OPEN indexlist
		FETCH NEXT FROM indexlist INTO @vcIndexName, @vcIndexKey

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @bitDebug = 1
				PRINT 'uspAlterIndex, CREATE [' + @vcIndexName + '] ON ' + @vcTableName + ' (' + @vcIndexKey + '):  ' + CONVERT( char, GETDATE())	

			SET @vcCmd = 'CREATE INDEX [' + @vcIndexName + '] ON ' + @vcTableName + ' (['
				+ REPLACE( @vcIndexKey, ',', '],[' ) + '])'
				+ CASE WHEN ISNULL( @vcFileGroup, '' ) = '' THEN '' 
				ELSE ' ON ' + @vcFileGroup END

			EXECUTE( @vcCmd )

			SET @vcCmd = 'CREATE STATISTICS [sp_' + @vcIndexName + '] ON ' + @vcTableName + ' (['
				+ REPLACE( @vcIndexKey, ',', '],[' ) + '])'

			IF @bitDebug = 1
				PRINT 'CREATE STATISTICS [sp_' + @vcIndexName + '] ON ' + @vcTableName + ' (['
					+ REPLACE( @vcIndexKey, ',', '],[' ) + ']) :  ' + CONVERT( char, GETDATE())	

			EXECUTE( @vcCmd )

			FETCH NEXT FROM indexlist INTO @vcIndexName, @vcIndexKey
		END
		CLOSE indexlist
		DEALLOCATE indexlist
	END

	IF @bitDebug = 1
		PRINT 'EXECUTE usp_remove_auto_status ' + @vcTableName + ' : ' + CONVERT( char, GETDATE())

	EXECUTE dbo.usp_remove_auto_stats @lcTab = @vcTableName, @lbexec = 1

	-- Drop all records from dbo.utb_drop_indexinfo for this table
	--	DELETE FROM dbo.utb_drop_indexinfo
	--	  WHERE UPPER(RTRIM(table_name)) = UPPER(RTRIM(@vcTableName))
END

GO
