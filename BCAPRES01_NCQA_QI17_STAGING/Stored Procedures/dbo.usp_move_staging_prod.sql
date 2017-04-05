SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*

*/

-- exec usp_move_staging_prod 'hedis_gender_dim'

CREATE PROC [dbo].[usp_move_staging_prod]

@lcTableName VARCHAR(100) = ''

AS


--DECLARE @lcTableName VARCHAR(100)
--set	@lcTableName = 'hedis_gender_dim'


DECLARE @lcCurDB VARCHAR(50),
    @lcTargDB VARCHAR(50),
	@lcTabName VARCHAR(1000),
    @lccmd nvarchar(2000),
    @lcDate varchar(8),
	@liSingleTab INT,
	@lcIndex VARCHAR(200)
 
DECLARE @lcIndexName VARCHAR(100),
            @lcIndexColumn VARCHAR(100)
 
--IF @lcTableName = ''
--	SET @liSIngleTab = 0
--ELSE
	SET @liSingleTab = 1
 
SET @lcCurDb = 'NCQA_QI09_STAGING'
SET @lctargDb = 'NCQA_QI09_PROD'
SET @lcdate = CONVERT(CHAR(8),GETDATE(),112)
  
--IF OBJECT_ID(@lcTargDb+'..dw_dimension_table_list') IS NOT NULL
--BEGIN
--    SET @lccmd = 'DROP TABLE '+@lctargdb+'..dw_dimension_table_list'
--    PRINT @lccmd
--    EXEC (@lccmd)
--END
--SET @lccmd = 'SELECT * INTO '+@lctargdb+'..dw_dimension_table_list FROM dw_dimension_table_list'
--PRINT @lccmd
--EXEC (@lccmd)
-- 
--IF OBJECT_ID(@lcTargDb+'..dw_fact_table_list') IS NOT NULL
--BEGIN
--    SET @lccmd = 'DROP TABLE '+@lctargdb+'..dw_fact_table_list'
--    PRINT @lccmd
--    EXEC (@lccmd)
--END
--SET @lccmd = 'SELECT * INTO '+@lctargdb+'..dw_fact_table_list FROM dw_fact_table_list'
--PRINT @lccmd
-- 
--EXEC (@lccmd)
--
--SET @lccmd = 'UPDATE ' + @lctargdb + '..dw_dimension_table_list SET dimension_table_name = ''tbl''+dimension_table_name'
--PRINT @lccmd
--EXEC (@lccmd)
--
--SET @lccmd = 'UPDATE ' + @lctargdb + '..dw_fact_table_list SET fact_table_name = ''tbl''+fact_table_name'
--PRINT @lccmd
--EXEC (@lccmd)

IF @liSingleTab = 0  
BEGIN
	DECLARE tablist CURSOR FOR
	    SELECT 'tbl'+dimension_table_name
	        FROM dw_dimension_Table_list
	    UNION ALL
	    SELECT 'tbl'+fact_table_name
	        FROM  dw_fact_table_list
END
ELSE
BEGIN
	DECLARE tablist CURSOR FOR
	    SELECT 'tbl'+@lcTableName
END

OPEN tablist
 
FETCH NEXT FROM tablist INTO @lcTabName
 
WHILE @@FETCH_STATUS = 0
BEGIN
 
    IF OBJECT_ID(@lcTargDb+'..'+@lcTabName) IS NOT NULL
    BEGIN
        SET @lccmd = 'DROP TABLE '+@lctargdb+'..'+@lctabname
        PRINT @lccmd
        EXEC (@lccmd)
    END
 
    SET @lccmd = 'SELECT * INTO '+@lctargdb+'..'+LOWER(@lctabname)+' FROM '+SUBSTRING(@lctabname,4,50)
    PRINT @lccmd
    EXEC (@lccmd)

	-- Drop view if it exists
	IF OBJECT_ID(@lcTargDb+'..'+SUBSTRING(@lcTabName,4,50)) IS NOT NULL
	BEGIN
	    SET @lccmd = 'DROP VIEW '+SUBSTRING(@lctabname,4,50)
	    PRINT @lccmd
	    exec NCQA_QI09_PROD..sp_executesql  @lccmd
	END

	SET @lccmd = 'CREATE VIEW ' + SUBSTRING(@lcTabName,4,50) + ' AS SELECT * FROM '+@lcTabName
	PRINT @lccmd
	exec NCQA_QI09_PROD..sp_executesql @lccmd

    EXEC NCQA_QI09_PROD..usp_alter_primary_key @lcTabName, 'REPORT' 

    FETCH NEXT FROM tablist INTO @lcTabName
 
END
 
CLOSE tablist
DEALLOCATE tablist
 

IF OBJECT_ID('tempdb..#index_list') IS NOT NULL 
	DROP TABLE #index_list

CREATE TABLE #index_list (Table_name VARCHAR(100),
							column_name VARCHAR(100),
							index_name VARCHAR(100))

IF @liSingleTab = 0
BEGIN

	INSERT INTO #index_list
	SELECT DISTINCT 'tbl'+table_name table_name, column_name, 'FK_'+column_name index_name
	    from information_schema.columns a
	        INNER JOIN dw_dimension_table_list b
	            On a.table_name = b.dimension_table_name
	    where data_type IN ('int','varchar','numeric')
	        AND right(column_name,4) <> '_key'
	 
	INSERT INTO #index_list
	SELECT DISTINCT 'tbl'+table_name table_name, column_name, 'FK_'+column_name index_name
	    from information_schema.columns a
	        INNER JOIN dw_fact_table_list b
	            On a.table_name = b.fact_table_name
	    where right(column_name,4) <> '_key'
END
ELSE
BEGIN

	INSERT INTO #index_list
	SELECT DISTINCT 'tbl'+table_name table_name, column_name, 'FK_'+column_name index_name
	    from information_schema.columns a
	        INNER JOIN dw_dimension_table_list b
	            On a.table_name = b.dimension_table_name
	    where data_type IN ('int','varchar','numeric')
	        AND right(column_name,4) <> '_key'
			AND table_name = @lcTableName
	 
	INSERT INTO #index_list
	SELECT DISTINCT 'tbl'+table_name table_name, column_name, 'FK_'+column_name index_name
	    from information_schema.columns a
	        INNER JOIN dw_fact_table_list b
	            On a.table_name = b.fact_table_name
	    where right(column_name,4) <> '_key'
			AND table_name = @lcTableName

END	 

 
SELECT @lcTabName = table_name,
    @lcIndexname = index_name,
    @lcIndexColumn = column_name
    FROM #index_list a
        INNER JOIN (SELECT MIN(table_name + index_name) min_tab_index
                        FROM #index_list) b
            ON a.table_name + index_name = b.min_tab_index
 
WHILE @lcTabName IS NOT NULL
	AND @lcIndexName IS NOT NULL
BEGIN
 
    SET @lccmd = 'create index ' + @lcIndexname + ' ON ' + @lcTabname + ' (' + @lcIndexColumn + ')'
    PRINT @lccmd
    
    exec NCQA_QI09_PROD..sp_executesql @lccmd

	SET @lcIndex = (SELECT MIN(table_name + index_name) min_tab_index
				        FROM #index_list
				            WHERE table_name + index_name > @lcTabName + @lcindexName)
				                        

	SET @lcTabName = (SELECT a.table_name
					    FROM #index_list a
						WHERE table_name + index_name = @lcindex)

	SET @lcIndexName = (SELECT MIN(a.index_name)
					    FROM #index_list a
						WHERE table_name + index_name = @lcindex)
                   
    SET @lcIndexColumn = (SELECT a.column_name
					    FROM #index_list a
						WHERE table_name + index_name = @lcindex)

END
GO
