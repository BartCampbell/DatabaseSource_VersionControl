SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [etl].[spBcpFileDynamic] (
	@lcDB CHAR(50)
	,@lcTab CHAR(50)
	,@lcType CHAR(1)
	,@lcPath VARCHAR(200)
	,@lcFileName VARCHAR(100) = ''
	,@lcDelim VARCHAR(1) = ''
	,@lcAddParam VARCHAR(2000) = NULL
	,@lcExportQuery VARCHAR(4000) = NULL
	,@lcSchema VARCHAR(200) = 'etl'
	,@Debug INT = 0 -- 0:Exec with no Debug // 1:Exec with Debug // 2:Debug Print Only
)
AS

DECLARE @lccmd varchar(8000), 
    @lcServer VARCHAR(50), 
    @lcFile VARCHAR(100), 
    @Tablename VARCHAR(100)

IF @lcType IS NULL
	SET @lcTYPE = 'E'


IF RIGHT(RTRIM(@lcPath),1) <> '\' AND RIGHT(RTRIM(@lcPath),1) <> '/'
	SET @lcPath = RTRIM(@lcPath)+'\'

--IF @lcTYPE = 'E'
	SET @lcServer = CONVERT(CHAR(10),(SELECT SERVERPROPERTY ('machinename')))
--ELSE 
--	SET @lcServer = 'IMIETL05.imihealth.com'

IF @lcType = 'E'
BEGIN

	SET @lcCmd = 'bcp ' 
		+ CASE WHEN @lcExportQuery IS NULL
			THEN  RTRIM(@lcDB) + '.' + @lcSchema +'.'+RTRIM(@lcTab)+' OUT '
			ELSE @lcExportQuery + ' QUERYOUT ' 
			END
		+'"'+ @lcPath + @lcFileName + '.txt" -S ' + @lcServer
		+ ' -T -c ' 
        + ' -o ' + RTRIM(@lcPath) + RTRIM(@lcFileName) + '.out '
		+ ' -e ' + RTRIM(@lcPath) + RTRIM(@lcFileName) + '.err '
        + CASE WHEN ISNULL(@lcDelim,'') <> '' THEN ' -t "' + @lcDelim + '"'
            ELSE ''
            END
	
	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFile: Export:' + @lccmd
	IF @Debug <=1 EXEC xp_cmdshell @lccmd

END
ELSE
BEGIN

	--SET @lcFile = @lcTab
	
	SET @lcCmd = 'bcp ' + RTRIM(@lcDB) + '.' + @lcSchema +'.'+RTRIM(@lcTab)+' IN "'
		+ RTRIM(@lcPath) + RTRIM(@lcFileName) + '" -S ' + @lcServer
		+ ' -T -c -o ' + RTRIM(@lcPath) + RTRIM(@lcTab) + '.out'
		+ ' -e ' + RTRIM(@lcPath) + RTRIM(@lcTab) + '.err'
        + CASE WHEN ISNULL(@lcDelim,'') <> '' THEN ' -t "' + @lcDelim + '"'
            ELSE ''
            END
        + ' ' + ISNULL(@lcAddParam,'')
	
	IF @Debug >= 1 PRINT CHAR(13) + 'spBcpFile: Import:' + @lccmd
	IF @Debug <=1 EXEC xp_cmdshell @lccmd

END

















GO
