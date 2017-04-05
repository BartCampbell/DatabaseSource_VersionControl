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
	@lcDB = 'tempdb', 
	@lcTab = 'maraxml', 
	@lcType = 'E', 
	@lcPath = '\\imivmld\c$\dataware\mara\', 
	@lcFileName = 'mararun.test' , 
	@lcDelim  = null, 
	@lcAddParam = NULL,
	@lcExportQuery = '"select txt from ##maraxml order by rowid"'


EXEC dbo.usp_export_table
		@lcDB = 'STFRAN_RDSM',
		@lcTab = '##crtab', 
		@lcType = 'I', 
		@lcPath = '\\fs01\FileStore\StFrancis\Wellpoint\~Incoming\STFRANCIS_JUN2013_MAY2014_AUG2014\',
		@lcFileName = 'STFRANCI_MEMBERS_FNL.txt',
		@lcDelim = '|',
		@lcAddParam = '/L 1',
		@bDebug = 1


select * from ##crtab

	STFRAN_RDSM	STFRANCI_MEMBERS_FNL.txt	|	/L 1

*/
CREATE proc [dbo].[usp_export_table] 

@lcDB CHAR(50), 
@lcTab CHAR(50), 
@lcType CHAR(1), 
@lcPath VARCHAR(200), 
@lcFileName VARCHAR(100) = '', 
@lcDelim VARCHAR(1) = '', 
@lcAddParam VARCHAR(2000) = NULL,
@lcExportQuery VARCHAR(4000) = NULL,
@lcSchema VARCHAR(200) = 'dbo',
@bDebug BIT = 1

AS

IF ISNULL(@lcFileName,'') = ''
    SET @lcFileName = @lcTab + '.txt'

DECLARE @lccmd varchar(8000), 
    @lcServer VARCHAR(50), 
    @lcFile VARCHAR(100), 
    @Tablename VARCHAR(100)

IF @lcType IS NULL
	SET @lcTYPE = 'E'

IF @lcPath IS NULL
	SET @lcPath = '\\imisql\e$'

IF RIGHT(RTRIM(@lcPath),1) <> '\' AND RIGHT(RTRIM(@lcPath),1) <> '/'
	SET @lcPath = RTRIM(@lcPath)+'\'

SET @lcServer = CONVERT(CHAR(10),(select SERVERPROPERTY ('machinename')))

IF @lcType = 'E'
BEGIN

	SET @lcCmd = 'bcp ' 
		+ CASE WHEN @lcExportQuery IS NULL
			THEN  RTRIM(@lcDB) + '.' + @lcSchema +'.'+RTRIM(@lcTab)+' OUT '
			ELSE @lcExportQuery + ' QUERYOUT ' 
			END
		+'"'+ @lcPath + @lcFileName + '" -S ' + @lcServer
		+ '-T -c ' 
        + ' -o '+ RTRIM(@lcPath)+RTRIM(@lcTab)+'.out '
		+ ' -e ' + RTRIM(@lcPath)+RTRIM(@lcTab)+'.err '
        + CASE WHEN ISNULL(@lcDelim,'') <> '' THEN ' -t "'+@lcDelim+'"'
            ELSE ''
            END
	
	IF @bDebug = 1
		PRINT @lccmd
	EXEC master..xp_cmdshell @lccmd
	
--	SET @lcCMd = 'pkzip -m ' + @lcPath +RTRIM(@lcTab)+'.zip ' + @lcPath+RTRIM(@lcTab)+'.txt'
--	SELECT @lccmd
--	EXEC master..xp_cmdshell @lccmd

END
ELSE
BEGIN

	SET @lcCmd = 'TRUNCATE TABLE '+RTRIM(@lcDB)+'.' + @lcSchema +'.'+RTRIM(@lcTab)
	IF @bDebug = 1
		SELECT @lcCmd

	EXEC (@lcCmd)

--	SET @lcCMd = RTRIM(@lcPath)+'pkunzip -o ' + @lcPath +RTRIM(@lcTab)+'.zip ' + @lcPath
--	SELECT @lccmd
--	exec master..xp_cmdshell @lccmd

-- 	IF LEN(RTRIM(@lcTab)) > 8
-- 		SET @lcFile = LEFT(@lcTab,6)+'~1'
-- 	ELSE
		SET @lcFile = @lcTab

	-- Drop Indexes
--	EXEC alter_index @lcdb,'D'

	SET @lcCmd = 'bcp ' + RTRIM(@lcDB) + '.' + @lcSchema +'.'+RTRIM(@lcTab)+' IN "'
		+ RTRIM(@lcPath)+RTRIM(@lcFileName)+'" -S ' + @lcServer
		+ ' -T -c -o '+ RTRIM(@lcPath)+RTRIM(@lcFile)+'.out'
		+ ' -e ' + RTRIM(@lcPath)+RTRIM(@lcFile)+'.err'
        + CASE WHEN ISNULL(@lcDelim,'') <> '' THEN ' -t "'+@lcDelim+'"'
            ELSE ''
            END
        + ' ' + ISNULL(@lcAddParam,'')
--		+ ' -f ' + RTRIM(@lcPath) + SUBSTRING(@lcfile,2,5) + '.fmt'
			
--	SELECT @lccmd
	IF @bDebug = 1
		PRINT @lccmd

	exec master..xp_cmdshell @lccmd

	SET @lcCmd = 'del '+RTRIM(@lcPath)+RTRIM(@lcFile)+'.txt'
	--EXEC master..xp_cmdshell @lcCmd

--	EXEC alter_index @lcdb,'C'


END
















GO
