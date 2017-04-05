SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





/*
truncate table dw_build_metrics_hdr
 select count(*) from dw_diabetes_ndc_list
exec usp_export_table 'ncqa_ihds_dw01_test1','BCS_Test1','E','\\imisql10\e$\dataware\ncqa\Deck_Results'

*/



CREATE    proc [dbo].[usp_export_Table] 

@lcDB CHAR(50), @lcTab CHAR(50), @lcType CHAR(1), @lcPath VARCHAR(200)

AS


DECLARE @lccmd varchar(1000), @lcServer VARCHAR(50), @lcFile VARCHAR(50), @Tablename VARCHAR(100)

IF @lcType IS NULL
	SET @lcTYPE = 'E'

IF @lcPath IS NULL
	SET @lcPath = '\\imisql\e$'

IF RIGHT(RTRIM(@lcPath),1) <> '\' AND RIGHT(RTRIM(@lcPath),1) <> '/'
	SET @lcPath = RTRIM(@lcPath)+'\'

SET @lcServer = CONVERT(CHAR(20),(select SERVERPROPERTY ('machinename')))

IF @lcType = 'E'
BEGIN

	SET @lcCmd = 'bcp ' + RTRIM(@lcDB) + '..'+RTRIM(@lcTab)+' OUT "'
		+ RTRIM(@lcPath)+RTRIM(@lcTab)+'.txt" -S ' + @lcServer
		+ '-T -c -t,'	
	
	SELECT @lccmd
	EXEC master..xp_cmdshell @lccmd
	
	--SET @lcCMd = 'pkzip -m ' + @lcPath +RTRIM(@lcTab)+'.zip ' + @lcPath+RTRIM(@lcTab)+'.txt'
	--SELECT @lccmd
	EXEC master..xp_cmdshell @lccmd

END
ELSE
BEGIN

	SET @lcCmd = 'TRUNCATE TABLE '+RTRIM(@lcDB)+'..'+RTRIM(@lcTab)
	SELECT @lcCmd
	EXEC (@lcCmd)

	-- Drop Indexes

	SET @lcCMd = 'pkunzip -o ' + @lcPath +RTRIM(@lcTab)+'.zip ' + @lcPath
	SELECT @lccmd
	exec master..xp_cmdshell @lccmd

	IF LEN(RTRIM(@lcTab)) > 8
		SET @lcFile = LEFT(@lcTab,6)+'~1'
	ELSE
		SET @lcFile = @lcTab


	SET @lcCmd = 'bcp ' + RTRIM(@lcDB) + '..'+RTRIM(@lcTab)+' IN "'
		+ RTRIM(@lcPath)+RTRIM(@lcFile)+'.txt" -S ' + @lcServer
		+ ' -T -c -t -o '+ RTRIM(@lcPath)+RTRIM(@lcFile)+'.out'
		+ ' -e '	+ RTRIM(@lcPath)+RTRIM(@lcFile)+'.err'
	
	SELECT @lccmd
	exec master..xp_cmdshell @lccmd

--	SET @lcCmd = 'del '+RTRIM(@lcPath)+RTRIM(@lcTab)+'.txt'
--	EXEC master..xp_cmdshell @lcCmd


END

GO
