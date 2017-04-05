SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*************************************************************************************
Procedure:	
Author:		Leon Dowling
Copyright:	© 2016
Date:		2016.12.14
Purpose:	
Parameters:	
Depends On:	
Calls:		
Called By:	
Returns:	
Notes:		
Process:	
Update Log:
Test Script:	
	EXEC [prMoveStagingToProd]   
		@iLoadInstanceID = 1,
		@bArchive_tables  = 0,
		@bBackupDataStore = 0,
		@vcSpecificTable = 'Provider'

ToDo:		


*************************************************************************************/

--/*
CREATE PROC [dbo].[prMoveStagingToProd]   
(
	@iLoadInstanceID			int,
	@bArchive_tables			bit = 0,
	@bBackupDataStore			bit = 0,
	@vcSpecificTable			varchar(20) = NULL
)
AS
--*/

/*------------------------------------------
DECLARE @iLoadInstanceID INT,
	@bArchive_tables BIT ,
	@bBackupDataStore BIT,
	@vcSpecificTable VARCHAR(20)

SET @bArchive_tables = 0
SET @iLoadInstanceID = 1
SET @bBackupDataStore = 0
SET @vcSpecificTable = 'PharmacyClaim'
*/------------------------------------------
--	Declare variables 
DECLARE @iExpectedCnt int
DECLARE @sysMe sysname

DECLARE @vcSrcDB VARCHAR(100) = 'BCBSA_CGF_Staging'
DECLARE @vcTargDB VARCHAR(100) = 'BCBSA_CGF_Staging_PROD'

--	Set variables 
SET @sysMe = OBJECT_NAME( @@PROCID )

--	Logging
EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Started'

DECLARE @vctab NVARCHAR(100),    
    @vcCmd VARCHAR(MAX),
    @nvcCmd NVARCHAR(2000),
    @itaborder INT,
    @iCnt INT,
    @iStCnt INT,
    @iDSCnt INT


-- Update table structure

SET @vcCmd = ''

SELECT @vcCmd = @vcCmd +
 'ALTER TABLE BCBSA_CGF_Staging_prod..' + stag.TABLE_NAME + ' ADD ' + stag.COLUMN_NAME + ' ' 
		+ CASE WHEN stag.DATA_TYPE IN ('varchar','char') THEN stag.DATA_TYPE + '(' + CONVERT(VARCHAR(10),stag.CHARACTER_MAXIMUM_LENGTH) + ')'
				WHEN stag.data_type IN ('decimal','numeric','float') THEN stag.DATA_TYPE + '(' + CONVERT(VARCHAR(10),stag.NUMERIC_PRECISION) + ',' + CONVERT(VARCHAR(10),ISNULL(stag.NUMERIC_SCALE,stag.NUMERIC_PRECISION_RADIX)) + ')'
				ELSE stag.DATA_TYPE
				END + CHAR(13)
	FROM BCBSA_CGF_Staging.INFORMATION_SCHEMA.COLUMNS stag
		INNER JOIN (SELECT distinct 
						table_name ,
						TABLE_SCHEMA
						FROM BCBSA_CGF_Staging_prod.INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_SCHEMA = 'dbo' ) flt
			ON stag.TABLE_NAME = flt.table_name
			AND stag.TABLE_SCHEMA = flt.TABLE_SCHEMA
		LEFT JOIN BCBSA_CGF_Staging_prod.INFORMATION_SCHEMA.COLUMNS prod
			ON stag.TABLE_NAME = prod.TABLE_NAME
			AND stag.TABLE_SCHEMA = prod.TABLE_SCHEMA
			AND stag.COLUMN_NAME = prod.COLUMN_NAME
	WHERE prod.COLUMN_NAME IS NULL		
		AND stag.TABLE_SCHEMA = 'dbo'

PRINT @vcCmd
EXEC (@vcCmd)

SET @vcCmd = ''
-- Check length of char/varchar fields
SELECT @vcCmd = @vcCmd +
 'ALTER TABLE BCBSA_CGF_Staging_prod..' + stag.TABLE_NAME + ' ALTER COLUMN ' + stag.COLUMN_NAME + ' ' 
		+ stag.DATA_TYPE + '(' + CONVERT(VARCHAR(10),stag.CHARACTER_MAXIMUM_LENGTH) + ')'
		+ CHAR(13)
	FROM BCBSA_CGF_Staging.INFORMATION_SCHEMA.COLUMNS stag
		INNER JOIN (SELECT distinct 
						table_name ,
						TABLE_SCHEMA
						FROM BCBSA_CGF_Staging_prod.INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_SCHEMA = 'dbo'
						  ) flt
			ON stag.TABLE_NAME = flt.table_name
			AND stag.TABLE_SCHEMA = flt.TABLE_SCHEMA
		INNER JOIN BCBSA_CGF_Staging_prod.INFORMATION_SCHEMA.COLUMNS prod
			ON stag.TABLE_NAME = prod.TABLE_NAME
			AND stag.TABLE_SCHEMA = prod.TABLE_SCHEMA
			AND stag.COLUMN_NAME = prod.COLUMN_NAME
	WHERE stag.data_type IN ('VARCHAR','CHAR')
		AND stag.CHARACTER_MAXIMUM_LENGTH  <> prod.CHARACTER_MAXIMUM_LENGTH
		AND stag.TABLE_SCHEMA = 'dbo'

PRINT @vcCmd
EXEC (@vcCmd)

--,
--	@i int,
--	@vcSQLCommand	varchar( 255 )

IF OBJECT_ID('tempdb..#select') IS NOT NULL
    DROP TABLE #select
    
IF OBJECT_ID('tempdb..#insert') IS NOT NULL
    DROP TABLE #insert        

IF OBJECT_ID('tempdb..#taborder') IS NOT NULL
    DROP TABLE #taborder
    

CREATE TABLE #select (txt VARCHAR(200), rowid INT IDENTITY(1,1))
CREATE TABLE #insert (txt VARCHAR(200), rowid INT IDENTITY(1,1))
CREATE TABLE #taborder (tab VARCHAR(100), taborder INT IDENTITY(1,1))

IF @vcSpecificTable IS NULL
BEGIN

	INSERT INTO #taborder 
	SELECT DISTINCT TableName
		FROM etl_staging_Tables

	INSERT INTO #taborder SELECT 'mpi_output_member'
	INSERT INTO #taborder SELECT 'mpi_output_provider'
	INSERT INTO #taborder SELECT 'HealthPlan'


	INSERT INTO #taborder
		select a.Table_name
			FROM INFORMATION_SCHEMA.tables  a
				INNER JOIN dbo.etl_staging_tables b
					ON a.TABLE_NAME = 'BrXref_' + b.TableName
			WHERE LEFT(TABLE_NAME,6) = 'brxref'
			ORDER BY TABLE_NAME

END
ELSE
	INSERT INTO #taborder 
		SELECT @vcSpecificTable
	        
--	CREATE TABLE #DropMe( ID int IDENTITY( 1, 1 ), SQLCommand varchar( 255 ) )

BEGIN-- Delete in reverse order
    SELECT @itaborder = MAX(taborder) FROM [#taborder]
   
    WHILE EXISTS (SELECT * FROM [#taborder] WHERE taborder = @itaborder)
    BEGIN

        SELECT @vctab = tab FROM #taborder WHERE taborder = @itaborder


        IF @bArchive_tables = 1
        BEGIN

            SET @vcCmd = @vcTargDB+'.zArchive.' + @vctab + '_' + CONVERT(VARCHAR(8),GETDATE(),112) 
            PRINT @vccmd
            IF OBJECT_ID(@vcCmd) IS NOT NULL
            BEGIN
                SET @vccmd = 'DROP TABLE '+ @vcCmd
                PRINT @vccmd
                EXEC (@vccmd)
            END

			SET @vcCmd = @vcTargDB+'..' + @vctab + '_' + CONVERT(VARCHAR(8),GETDATE(),112) 
			PRINT @vccmd
			IF OBJECT_ID(@vcCmd) IS NULL
			BEGIN
				SET @vcCmd = 'SELECT * INTO ' + @vcTargDB + '.zArchive.' + @vcTab + ' FROM ' + @vcSrcDB + '..' + @vcTab
				PRINT @vcCmd
				EXEC (@vcCmd)
			END

		END

        SET @vcCmd = @vcTargDB+'..' + @vctab 
        PRINT @vccmd
        IF OBJECT_ID(@vcCmd) IS NULL
        BEGIN
			SET @vcCmd = 'SELECT TOP 0  * INTO ' + @vcTargDB + '..' + @vcTab + ' FROM ' + @vcSrcDB + '..' + @vcTab
			PRINT @vcCmd
			EXEC (@vcCmd)
		END

-- needs to run on @vcTargDB

		SET @vcCMD = 'EXECUTE ' + @vcTargDB + '..uspAlterIndex @vcTableName = ''' + @vctab+ ''', @cAction = ''D'', @bitDebug = 1'
		PRINT @vcCmd
        EXEC (@vccmd)

        SET @vccmd = 'TRUNCATE TABLE  ' + @vcTargDB + '..' + @vctab
        PRINT @vcCmd
        EXEC (@vccmd)

        EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records deleted', @@ROWCOUNT, 'prMoveStagingToProd', @vcTab, @@ROWCOUNT

		SET @itaborder = @itaborder - 1

    END   


/*
	--		-- get rid of all but the last 5 archive tables for our target table
	--		TRUNCATE TABLE #DropMe
	--		INSERT INTO #DropMe( SQLCommand )
	--			SELECT	'DROP TABLE @vcTargDB..' + TABLE_NAME
	--			FROM	@vcTargDB.INFORMATION_SCHEMA.TABLES
	--			WHERE	TABLE_NAME LIKE 'arc_' + @vctab + '_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
	--				AND TABLE_NAME NOT IN(	SELECT	TOP 5 TABLE_NAME
	--							FROM	@vcTargDB.INFORMATION_SCHEMA.TABLES
	--							WHERE	TABLE_NAME LIKE 'arc_' + @vctab + '_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
	--							ORDER BY
	--								TABLE_NAME DESC )
	--
	--		SET @i = @@ROWCOUNT	
	--		WHILE @i > 0
	--		BEGIN
	--			SELECT @vcSQLCommand = SQLCommand FROM #DropMe WHERE ID = @i
	--			EXECUTE( @vcSQLCommand )
	--			SET @i = @i - 1
	--		END
		
/* -- TURNED OFF THE ARCHIVING SECTION PER REQUEST FROM LEON ON 2009-02-19 TO PRESERVE DISK SPACE ON ALL PLATFORMS - JBURNETTE (2009-02-20)
            SET @vccmd = 'SELECT * INTO @vcTargDB..arc_' + @vctab + '_' + CONVERT(VARCHAR(8),GETDATE(),112) + ' FROM @vcTargDB..' + @vctab
            PRINT @vccmd
            EXEC (@vccmd)
*/ -- TURNED OFF THE ARCHIVING SECTION PER REQUEST FROM LEON ON 2009-02-19 TO PRESERVE DISK SPACE ON ALL PLATFORMS - JBURNETTE (2009-02-20)
        
*/
        

END

BEGIN -- insert from @vcSrcDB
    
    SET @itaborder = 1

    WHILE EXISTS (SELECT * FROM [#taborder] WHERE taborder = @itaborder)
    BEGIN

        SELECT @vctab = tab FROM #taborder WHERE taborder = @itaborder
        SET @vccmd = ''

        IF (SELECT IDENT_SEED(@vctab)) IS NOT NULL
            INSERT INTO [#insert] SELECT 'SET IDENTITY_INSERT ' + @vcTargDB+'..' + @vctab + ' ON;' 
        
        INSERT INTO #insert 
            SELECT 'INSERT INTO ' + @vcTargDB+'..' + @vctab + ' ( '
        
        INSERT INTO [#insert] 
            SELECT column_name + CASE WHEN ordinal_position <> (SELECT MAX(ordinal_position) FROM information_schema.columns WHERE table_name = @vctab AND table_schema = 'dbo') THEN ', ' ELSE '' END
                FROM information_schema.columns
                WHERE table_name = @vctab
	                AND table_schema = 'dbo'
                ORDER BY ordinal_position
                
        INSERT INTO [#select] 
            SELECT ' ) SELECT ' 
            
        INSERT INTO [#select] 
            SELECT column_name + CASE WHEN ordinal_position <> (SELECT MAX(ordinal_position) FROM information_schema.columns WHERE table_name = @vctab AND table_schema = 'dbo') THEN ', ' ELSE '' END
                FROM information_schema.columns
                WHERE table_name = @vctab
                AND table_schema = 'dbo'
                ORDER BY ordinal_position

        INSERT INTO [#select] 
            SELECT ' FROM '  + @vcSrcDB+'..' + @vctab + ';'

        IF (SELECT IDENT_SEED(@vctab)) IS NOT NULL
            INSERT INTO [#select] 
                SELECT ' SET IDENTITY_INSERT ' + @vcTargDB +'..'+ @vctab + ' OFF;'
            

        SELECT  @vcCmd = @vcCmd  + txt + CHAR(13)
            FROM    [#insert]
            ORDER BY rowid

        SELECT  @vcCmd = @vcCmd  + txt + CHAR(13)
            FROM    [#select]
            ORDER BY rowid

        PRINT @vccmd            
        EXEC (@vccmd)

		SELECT @nvcCmd  = 'SELECT @iStCnt = COUNT(*) FROM ' + @vcSrcDB + '..'+ @vctab
		
		EXECUTE	sp_executesql @nvcCmd , N'@iStCnt int OUT', @iStCnt OUT
			
		SELECT @nvcCmd  = 'SELECT @iDSCnt = COUNT(*) FROM ' + @vcTargDB+'..'+ @vctab
		
		EXECUTE	sp_executesql @nvcCmd , N'@iDSCnt int OUT', @iDSCnt OUT
	
	    EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records inserted', @iDSCnt, 'prMoveStagingToProd', @vcTab, @iStCnt

		IF ISNULL(@iStCnt,0) <> ISNULL(@iDSCnt ,0)
		BEGIN
			SET @vcCmd = 'Stag to prod Err:' + @vctab 
			EXEC BCBSA_CGF_Staging..usp_send_mail 'support@imihealth.com', 'leon.dowling@imihealth.com', 'BCBSAZ Stag to Prod error', @vcCmd
		END			


		SET @vcCMD = 'EXECUTE ' + @vcTargDB + '..uspAlterIndex @vcTableName = ''' + @vctab+ ''', @cAction = ''C'''
		PRINT @vcCmd
        EXEC (@vccmd)

		--EXECUTE uspAlterIndex @vcTableName = @vctab, @cAction = 'C'
    
        TRUNCATE TABLE #select
        TRUNCATE TABLE #insert

        SET @itaborder = @itaborder + 1
    END
END

--	tjs 10/06/2014
IF OBJECT_ID('tempdb..#DROPME') IS NOT NULL DROP TABLE #DROPME
IF OBJECT_ID('tempdb..#INSERT') IS NOT NULL DROP TABLE #INSERT
IF OBJECT_ID('tempdb..#SELECT') IS NOT NULL DROP TABLE #SELECT
IF OBJECT_ID('tempdb..#TABORDER') IS NOT NULL DROP TABLE #TABORDER

--	Logging
EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Completed'


--BEGIN -- update MTM Application Based on New Dataload
--	
--	EXEC [PMD_MTM]..[usp_MemberPatientMapUpdate]
--	EXEC [PMD_MTM]..[usp_RefreshMedicalClaim]
--	EXEC [PMD_MTM]..[usp_RefreshMedicalClaimDetail]
--	EXEC [PMD_MTM]..[usp_RefreshPatientDrugList]
--
--END


/*
IF @bBackupDataStore = 1 AND @@SERVERNAME = 'IMISQL9'
BEGIN

	--Truncate Log and Shrink Database Prior to Replication/Copy
	BACKUP LOG [@vcTargDB] WITH TRUNCATE_ONLY;

	DBCC SHRINKDATABASE ('@vcTargDB') WITH NO_INFOMSGS;

	--Backup Master Copy of @vcTargDB on IMISQL9
	EXECUTE master..sqlbackup 
		  N'-SQL "BACKUP DATABASE [@vcTargDB] 
		  TO DISK = ''\\imifs02\Database_Backup\IMISQL9\@vcTargDB\Current\@vcTargDB.sqb'' 
		  WITH COMPRESSION = 1, INIT, 
		  MAILTO_ONERROR = ''DBA_Alert@imihealth.com''"'

END
*/




GO
