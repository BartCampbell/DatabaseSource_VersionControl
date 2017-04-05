SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*


select * from utb_temp

exec usp_export_table 'pharmd_rdsm','temp','I','E:\dataware\pmd\','PharmacyClaimTest.txt','|'
        
select * from utb_temp
-- select count(*) from jinsthm0


EXEC [usp_export_table] 
	@vcDB = 'tempdb', 
	@vcTab = 'maraxml', 
	@vcType = 'E', 
	@vcPath = '\\imivmld\c$\dataware\mara\', 
	@vcFileName = 'mararun.test' , 
	@vcDelim  = null, 
	@vcAddParam = NULL,
	@vcExportQuery = '"select txt from ##maraxml order by rowid"'


DECLARE @vcPath VARCHAR(200) = '\\imifs02\QI.Documents\Clients\HSAG\2014\Data\20131122\SFY_2011_FFS_refresh\'
DECLARE @vcSchema VARCHAR(50) = 'FFS2011R'
SELECT @vcSchema,'FFS_Member_Data','FFS_Member_Data.txt'



*/
--/*
CREATe proc [dbo].[usp_export_table] 

@vcDB CHAR(50), 
@vcTab CHAR(50), 
@vcType CHAR(1), 
@vcPath VARCHAR(200), 
@vcFileName VARCHAR(100) = '', 
@vcDelim VARCHAR(1) = '', 
@vcAddParam VARCHAR(4000) = NULL,
@vcExportQuery VARCHAR(4000) = NULL,
@vcSchema VARCHAR(200) = 'dbo',
@bDebug BIT = 1

AS
--*/
/*----------------------------------------------------------------
DECLARE @vcDB CHAR(50) = 'HSAG_RDSM'
DECLARE @vcTab CHAR(50) = 'utb_ihds_import_dtl'
DECLARE @vcType CHAR(1) = 'I'
DECLARE @vcPath VARCHAR(200) = '\\imifs02\QI.Documents\Clients\HSAG\2014\Data\20131122\SFY_2011_FFS_refresh\' 
DECLARE @vcFileName VARCHAR(100) = 'FFS_Member_Data.txt' 
DECLARE @vcDelim VARCHAR(1) = '|'
DECLARE @vcAddParam VARCHAR(100) = ''
DECLARE @vcExportQuery VARCHAR(4000) = NULL
DECLARE @vcSchema VARCHAR(200) = 'dbo'
DECLARE @bDebug BIT = 1
*/----------------------------------------------------------------

DECLARE @vcLocalServerDir VARCHAR(100)
SET @vcLocalServerDir = 'f:\ihds\'

IF ISNULL(@vcFileName,'') = ''
    SET @vcFileName = @vcTab + '.txt'

DECLARE @vccmd varchar(8000), 
    @vcServer VARCHAR(50), 
    @vcFile VARCHAR(100), 
    @Tablename VARCHAR(100)

IF @vcType IS NULL
	SET @vcTYPE = 'E'

IF @vcPath IS NULL
	SET @vcPath = '\\imisql\e$'

IF RIGHT(RTRIM(@vcPath),1) <> '\' AND RIGHT(RTRIM(@vcPath),1) <> '/'
	SET @vcPath = RTRIM(@vcPath)+'\'

SET @vcServer = CONVERT(CHAR(10),(select SERVERPROPERTY ('machinename')))

IF @vcType = 'E'
BEGIN

	SET @vcCmd = 'bcp ' 
		+ CASE WHEN @vcExportQuery IS NULL
			THEN  RTRIM(@vcDB) + '.' + @vcSchema +'.'+RTRIM(@vcTab)+' OUT '
			ELSE @vcExportQuery + ' QUERYOUT ' 
			END
		+'"'+ @vcPath + @vcFileName + '" -S ' + @vcServer
		+ '-T -c ' 
        + ' -o '+ RTRIM(@vcPath)+RTRIM(@vcTab)+'.out '
		+ ' -e ' + RTRIM(@vcPath)+RTRIM(@vcTab)+'.err '
        + CASE WHEN ISNULL(@vcDelim,'') <> '' THEN ' -t "'+@vcDelim+'"'
            ELSE ''
            END
	
	IF @bDebug = 1
		PRINT @vccmd
	
	EXEC master..xp_cmdshell @vccmd
	
--	SET @vcCMd = 'pkzip -m ' + @vcPath +RTRIM(@vcTab)+'.zip ' + @vcPath+RTRIM(@vcTab)+'.txt'
--	SELECT @vccmd
--	EXEC master..xp_cmdshell @vccmd

END
ELSE
BEGIN

	SET @vcCmd = 'TRUNCATE TABLE '+RTRIM(@vcDB)+'.' + @vcSchema +'.'+RTRIM(@vcTab)
	IF @bDebug = 1
		SELECT @vcCmd

	EXEC (@vcCmd)

	SET @vcFile = @vcTab

	declare @bMoveSrc BIT
	IF LEN(@vcPath) > 30 
	BEGIN

		SET @vcCmd = 'DEL ' + RTRIM(@vcLocalServerDir) + RTRIM(@vcFileName)
		IF @bDebug = 1
			PRINT @vccmd
		EXEC master..xp_cmdshell @vcCmd

		SET @vcCmd = 'copy ' + RTRIM(@vcPath) + RTRIM(@vcFileName) + ' ' + RTRIM(@vcLocalServerDir) + RTRIM(@vcFileName)
		IF @bDebug = 1
			PRINT @vccmd
		EXEC master..xp_cmdshell @vcCmd

		SET @vcCmd = 'bcp ' + RTRIM(@vcDB) + '.' + @vcSchema +'.'+RTRIM(@vcTab)+' IN "'
			--+ RTRIM(@vcPath)+RTRIM(@vcFileName)
			+ RTRIM(@vcLocalServerDir) + RTRIM(@vcFileName)
			+ '" -S ' + @vcServer
			+ ' -T -c -o '+ RTRIM(@vcLocalServerDir)+RTRIM(@vcFile)+'.out'
			+ ' -e ' + RTRIM(@vcLocalServerDir)+RTRIM(@vcFile)+'.err'
			+ CASE WHEN ISNULL(@vcDelim,'') <> '' THEN ' -t "'+@vcDelim+'"'
				ELSE ''
				END
			+ ' ' + ISNULL(@vcAddParam,'')

		IF @bDebug = 1
			PRINT @vccmd

		exec master..xp_cmdshell @vccmd

		SET @vcCmd = 'copy ' + RTRIM(@vcLocalServerDir) + RTRIM(@vcFile) + '.out ' + RTRIM(@vcPath) + RTRIM(@vcFile)+'.out'
		IF @bDebug = 1
			PRINT @vccmd
		EXEC master..xp_cmdshell @vcCmd
		SET @vcCmd = 'copy ' + RTRIM(@vcLocalServerDir) + RTRIM(@vcFile) + '.err ' + RTRIM(@vcPath) + RTRIM(@vcFile)+'.err'
		IF @bDebug = 1
			PRINT @vccmd
		EXEC master..xp_cmdshell @vcCmd


		SET @vcCmd = 'DEL ' + RTRIM(@vcLocalServerDir) + RTRIM(@vcFileName)
		IF @bDebug = 1
			PRINT @vccmd
		EXEC master..xp_cmdshell @vcCmd

		SET @vcCmd = 'DEL ' + RTRIM(@vcLocalServerDir) + RTRIM(@vcFile)+'.out'
		IF @bDebug = 1
			PRINT @vccmd
		EXEC master..xp_cmdshell @vcCmd

		SET @vcCmd = 'DEL ' + RTRIM(@vcLocalServerDir) + RTRIM(@vcFile)+'.err'
		IF @bDebug = 1
			PRINT @vccmd
		EXEC master..xp_cmdshell @vcCmd


	END
	ELSE
	BEGIN

		SET @vcCmd = 'bcp ' + RTRIM(@vcDB) + '.' + @vcSchema +'.'+RTRIM(@vcTab)+' IN "'
			+ RTRIM(@vcPath)+RTRIM(@vcFileName)+'" -S ' + @vcServer
			+ ' -T -c -o '+ RTRIM(@vcPath)+RTRIM(@vcFile)+'.out'
			+ ' -e ' + RTRIM(@vcPath)+RTRIM(@vcFile)+'.err'
			+ CASE WHEN ISNULL(@vcDelim,'') <> '' THEN ' -t "'+@vcDelim+'"'
				ELSE ''
				END
			+ ' ' + ISNULL(@vcAddParam,'')
	
		IF @bDebug = 1
			PRINT @vccmd

		exec master..xp_cmdshell @vccmd

	END
			

	SET @vcCmd = 'del '+RTRIM(@vcPath)+RTRIM(@vcFile)+'.txt'


END

















GO
