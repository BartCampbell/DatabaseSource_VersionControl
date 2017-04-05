SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****************************************************************************************************************************************************
Description:	Generate an INSERT statement for a FileConfig record based on an existing record.
Use:

EXEC CHSStaging.etl.spFileConfigInsertFromExisting @FileConfigID = 100108

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2017-02-23	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROC [etl].[spFileConfigInsertFromExisting]
	@FileConfigID INT = 100108
AS 
SET NOCOUNT ON

DECLARE 
	@vcCmd NVARCHAR(MAX)
	,@SQLSrcTableColList VARCHAR(MAX) = ''
	,@SQLSrcTableValList VARCHAR(MAX) = ''
	,@ColName VARCHAR(MAX) = ''
	,@ColType VARCHAR(MAX) = ''
	,@ColValue VARCHAR(MAX) = ''
	,@SQLResult VARCHAR(MAX) = ''
	,@iCnt INT
	,@SQLSrcOrdinalPosCur INT
	,@SQLSrcOrdinalPosLast INT
	,@DebugMsgVar VARCHAR(100)
		
	CREATE TABLE #SQLTargetDef (COLUMN_NAME VARCHAR(100),ORDINAL_POSITION INT,DATA_TYPE VARCHAR(100),CHARACTER_MAXIMUM_LENGTH INT)

	SELECT @vcCmd = '
	INSERT INTO #SQLTargetDef
	SELECT COLUMN_NAME,ORDINAL_POSITION,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH
	FROM CHSStaging.INFORMATION_SCHEMA.COLUMNS
	WHERE table_name = ''FileConfig''
		AND TABLE_SCHEMA = ''etl''
		AND Column_name NOT IN (''FileConfigID'',''CreateDate'',''LastUpdated'')
	ORDER BY ORDINAL_POSITION'

	--PRINT @vcCmd
	EXEC (@vcCmd)

	-- 

	SET @SQLSrcTableColList = ''
	SET @iCnt = 1
	SELECT @SQLSrcOrdinalPosCur = MIN(ORDINAL_POSITION) FROM #SQLTargetDef
	SET @SQLSrcOrdinalPosLast = 1

	WHILE @SQLSrcOrdinalPosCur IS NOT NULL
		BEGIN
			SELECT @ColName = COLUMN_NAME
				,@ColType = DATA_TYPE
				FROM #SQLTargetDef
				WHERE ORDINAL_POSITION = @SQLSrcOrdinalPosCur

			SELECT @SQLSrcTableColList = @SQLSrcTableColList + @ColName + ','
				FROM #SQLTargetDef
				WHERE ORDINAL_POSITION = @SQLSrcOrdinalPosCur

			SELECT @vcCmd = '
				SELECT @ColValue = COALESCE(CAST(' + @ColName + ' AS VARCHAR(MAX)),''NULL'')
				FROM CHSStaging.etl.FileConfig
				WHERE FileConfigID = ' + CAST(@FileConfigID AS VARCHAR)

			--PRINT @vcCmd
			EXEC sp_executesql @vcCmd, N'@ColValue VARCHAR(MAX) OUT', @ColValue OUT

			SELECT @SQLSrcTableValList = @SQLSrcTableValList 
					+ CHAR(9) + @ColName + ' = '
					+ CASE 
						WHEN @ColValue = 'NULL' THEN 'NULL'
						WHEN @ColType IN ('int','bit') THEN CAST(@ColValue AS VARCHAR)
						WHEN @ColType IN ('date','datetime') THEN '''' + @ColValue + ''''
						WHEN @ColType IN ('varchar','char') THEN '''' + @ColValue + ''''
						ELSE '!!!ERROR!!!'
						END
					+ ',' + CHAR(13)
				FROM #SQLTargetDef
				WHERE ORDINAL_POSITION = @SQLSrcOrdinalPosCur

			SELECT @SQLSrcOrdinalPosCur = MIN(ORDINAL_POSITION) FROM #SQLTargetDef WHERE ORDINAL_POSITION > @SQLSrcOrdinalPosCur
			SET @iCnt = @iCnt + 1
		END

	SET @SQLResult = 'INSERT INTO CHSStaging.etl.FileConfig'  + CHAR(13) 
						+ CHAR(9) +'(' + SUBSTRING(@SQLSrcTableColList,1,LEN(@SQLSrcTableColList) - 1) + ')' + CHAR(13)
						+ 'SELECT' + CHAR(13)
						+ SUBSTRING(@SQLSrcTableValList,1,LEN(@SQLSrcTableValList) - 2)

	PRINT @SqlResult

	DROP TABLE #SQLTargetDef

GO
