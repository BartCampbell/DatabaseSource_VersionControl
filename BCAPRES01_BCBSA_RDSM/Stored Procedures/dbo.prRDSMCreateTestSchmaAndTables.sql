SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*************************************************************************************
Procedure:	prRDSMCreateTestSchmaAndTables 
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

EXEC prRDSMCreateTestSchmaAndTables 
	@iLoadInstanceID = NULL,
	@bDebug = 1,
	@bExec = 1,
	@vcSrcSchema = 'BCBSA_GDIT2017',
	@vcTargSchema = 'BCBSA_Tst_NameX',
	--MemberFilters
	@vcLastNameFilter = 'X',
	@iTopNMembers = NULL

-- to change staging RDSM synonyms

exec BCBSA_CGF_STaging.RDSM.spMapSynonyms
	@Debug = 1,
	@Exec  = 1,
	@TargetDB ='BCBSA_RDSM',
	@TargetSchema = 'BCBSA_Tst_x'

	EXEC IHDSBuildMaster
					
		@bUpdateRDSM     = 0,
		@bRunMpi		 = 1,
		@bUpdateStaging  = 1,
		@bResetStaging   = 1,
				
		@bRunProfiles	 = 0,
		@bMoveToProd     = 0

*/

--/*
CREATE PROC [dbo].[prRDSMCreateTestSchmaAndTables] 

	@iLoadInstanceID INT = NULL,
	@bDebug BIT = 1,
	@bExec BIT = 1,

	@vcSrcSchema VARCHAR(100) = NULL,
	@vcTargSchema VARCHAR(100) = NULL,
	@vcLastNameFilter VARCHAR(1) = NULL,
	@iTopNMembers INT = NULL

AS
--*/
/*--------------------------------
DECLARE 
	@iLoadInstanceID INT = NULL,
	@bDebug BIT = 1,
	@bExec BIT = 1,

	@vcSrcSchema VARCHAR(100) = 'BCBSA_GDIT2017',
	@vcTargSchema VARCHAR(100) = 'BCBSA_Tst_x',

	--MemberFilters
	@vcLastNameFilter VARCHAR(1) = 'x',
	@iTopNMembers INT = 10

--*/------------------------------

DECLARE @vcCmd VARCHAR(8000),
	@vcCmd2 VARCHAR(8000),
	@nvcCmd NVARCHAR(4000),
	@nvcCmd2 NVARCHAR(4000),
	@i INT
	
--IF @iLoadInstanceID IS NULL 
--	EXECUTE IMIAdmin..prInitializeInstance 'BCBSA', 'Staging Load', 0, NULL, NULL, @iLoadInstanceID OUTPUT 

IF @bDebug = 1
	PRINT '@iLoadInstanceID = ' + CONVERT(VARCHAR(10),@iLoadInstanceID)

IF OBJECT_ID('tempdb..#Mbr') IS NOT NULL
	DROP TABLE #Mbr

CREATE TABLE #Mbr (MemberID VARCHAR(20), RowID INT IDENTITY(1,1))

SELECT @vcCmd = 'SELECT '
				+ CASE WHEN @iTopNMembers IS NOT NULL THEN ' TOP ' + CONVERT(VARCHAR(10),@iTopNMembers) ELSE '' END
				+ ' MemberID FROM ' + @vcSrcSchema + '.Member m'
				+ CASE WHEN @vcLastNameFilter IS NOT NULL THEN ' WHERE LEFT(m.namelast,1) = '''+ @vcLastNameFilter + '''' ELSE '' END
PRINT @vcCmd
INSERT INTO #Mbr
EXEC (@vcCmd)

CREATE INDEX fk ON #Mbr (MemberID)
CREATE STATISTICS sp ON #Mbr (MemberID)

IF @bDebug = 1
BEGIN
	SELECT @vcCmd = 'Records added to tempdb..#Mbr: ' + CONVERT(VARCHAR(10),COUNT(*))
		FROM #Mbr

	PRINT @vcCmd
END

--confirm Schema Exists
SELECT @nvcCmd  = 'SELECT @i = COUNT(*) FROM sys.schemas where [name] = ''' + @vcTargSchema + ''''
IF @bDebug = 1
	PRINT 'SqlCmd: ' + @nvcCmd
EXECUTE	sp_executesql @nvcCmd , N'@i int OUT', @i OUT

IF @i < 1
BEGIN

	SELECT @vcCmd  = 'CREATE SCHEMA ' + @vcTargSchema

	IF @bDebug = 1
		PRINT 'SqlCmd: ' + @vcCmd
	IF @bExec = 1
	BEGIN
		SELECT @vcCmd2 = 'EXEC sp_executesql N''' + @vcCmd + ''''
		EXEC (@vcCmd2)

	END
END

SET @vccmd = ''
-- Non Filtered Tables
SELECT @vccmd = @vccmd + 'if object_id(''' + @vcTargSchema + '.' + a.tab + ''') IS NOT NULL DROP TABLE ' + @vcTargSchema + '.' + a.tab + ';' + CHAR(13)
	FROM (SELECT tab = 'GroupPlan'
			UNION SELECT tab = 'Provider'
			UNION SELECT tab = 'ProviderSpecialty'
			UNION SELECT tab = 'Member'
			UNION SELECT tab = 'Claim'
			UNION SELECT tab = 'ClaimLab'
			UNION SELECT tab = 'Enrollment'
			UNION SELECT tab = 'RxClaim') a
	IF @bDebug = 1
		PRINT @vcCmd
	IF @bExec = 1
		EXEC (@vcCmd)
SET @vccmd = ''
SELECT @vccmd = @vccmd + 'SELECT * INTO ' + @vcTargSchema + '.' + a.tab + ' FROM ' + @vcSrcSchema + '.' + a.tab + ';' + CHAR(13)
	FROM (SELECT tab = 'GroupPlan') a
	IF @bDebug = 1
		PRINT @vcCmd
	IF @bExec = 1
		EXEC (@vcCmd)

-- Member Filtered Tables
SET @vccmd = ''
SELECT @vccmd = @vccmd + 'SELECT a.* INTO ' + @vcTargSchema + '.' + a.tab + ' FROM ' + @vcSrcSchema + '.' + a.tab + ' a INNER JOIN #mbr m on a.MemberId = m.MemberID;' + CHAR(13)
	FROM (SELECT tab = 'Member'
			UNION SELECT tab = 'Claim'
			UNION SELECT tab = 'ClaimLab'
			UNION SELECT tab = 'Enrollment'
			UNION SELECT tab = 'RxClaim') a
	IF @bDebug = 1
		PRINT @vcCmd
	IF @bExec = 1
		EXEC (@vcCmd)

--Provider Filtered Tables
IF OBJECT_ID('tempdb..#prov') IS not NULL 
	DROP TABLE #prov

CREATE TABLE #prov (ProviderID VARCHAR(20), RowID INT IDENTITY(1,1))

SELECT @vcCmd = 'SELECT DISTINCT ProviderID FROM ' + @vcTargSchema + '.Claim ' 
				+ ' UNION SELECT DISTINCT DispensingProv FROM '+ @vcTargSchema + '.Rxclaim'
				+ ' UNION SELECT DISTINCT ProviderID FROM ' + @vcTargSchema + '.ClaimLab'

IF @bDebug = 1
	PRINT @vcCmd
IF @bExec = 1
	INSERT INTO #prov
	EXEC (@vcCmd)

SET @vccmd = ''
SELECT @vccmd = @vccmd + 'SELECT a.* INTO ' + @vcTargSchema + '.' + a.tab + ' FROM ' + @vcSrcSchema + '.' + a.tab + ' a INNER JOIN #prov m on a.ProviderID = m.ProviderID;' + CHAR(13)
	FROM (SELECT tab = 'Provider'
			UNION SELECT tab = 'ProviderSpecialty') a
	IF @bDebug = 1
		PRINT @vcCmd
	IF @bExec = 1
		EXEC (@vcCmd)



GO
