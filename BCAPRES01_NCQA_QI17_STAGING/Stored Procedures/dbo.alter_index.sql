SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/*
_____________________________________________________________________

 Author:    Leon Dowling
   Date:	
   Desc:	

Updated:	
     By:	
 Reason:	

   Test:	
   
	This statement will need to exist in any calling populate procedure
	IF EXISTS(SELECT * FROM sysobjects WHERE id = OBJECT_ID('group_dim'))
	  drop table #indexinfo
	CREATE TABLE #indexinfo (indexname VARCHAR(40), tableid int, indexkey varchar(40))
	exec alter_index 'group_dim','D'
	EXEC alter_index 'group_dim','C'

_____________________________________________________________________
*/
CREATE PROCEDURE [dbo].[alter_index] 
(
	@tablename varchar(100), 
	@act_type char(1), 
	@file_grp VARCHAR(50) = '',
	@result varchar(1) ='N' OUTPUT
)
AS
DECLARE @lccmd VARCHAR(1000),
    @indexname VARCHAR(120),
    @indexid smallint,
    @indexkey VARCHAR(1000),
    @tabid int,
    @curkeyno smallint

IF OBJECT_ID('tempdb..#alter_index_sp_list') IS NOT NULL
    DROP TABLE #alter_index_sp_list

CREATE TABLE #alter_index_sp_list (stat_name VARCHAR(200), stat_keys VARCHAR(1000))

INSERT INTO #alter_index_sp_list
EXEC sp_helpstats @tablename


IF @act_type = 'D'
BEGIN
    IF EXISTS (SELECT * 
			    FROM sysindexes 
			    WHERE id = OBJECT_ID(@tablename) 
				    AND indid > 1 
				    AND indid < 255
				    AND (status & 64)=0)
    BEGIN
        PRINT 'Alter_index, DROP ' + @tablename+' :'+CONVERT(CHAR,GETDATE())

        -- Drop all records from utb_drop_indexinfo for this table
        DELETE FROM utb_drop_indexinfo
          WHERE UPPER(RTRIM(table_name)) = UPPER(RTRIM(@tablename))

        TRUNCATE TABLE utb_drop_indexkeys

        INSERT INTO utb_drop_indexkeys
	        SELECT a.*, SUBSTRING(b.name,1,40) indexfield, c.name indexname
	          FROM sysindexkeys a
	            INNER JOIN sysindexes c ON a.id = c.id and a.indid = c.indid
	            INNER JOIN syscolumns b ON a.id = b.id AND a.colid = b.colid
	          WHERE a.id = object_id(@tablename)
		         AND SUBSTRING(c.name,1,1) <> '_'
                 AND SUBSTRING(c.name,1,2) <> 'PK'
                 AND c.indid > 1
                 AND c.indid < 255
 		         AND (c.status & 64)=0

        DECLARE indexlist CURSOR FOR
          SELECT name, indid
            FROM sysindexes
            WHERE id = object_id(@tablename)
              AND SUBSTRING(name,1,1) <> '_'
                  AND SUBSTRING(name,1,2) <> 'PK'
                  AND indid > 1
                  AND indid < 255
  		          AND (status & 64)=0

	    SET @tabid = OBJECT_ID(@tablename)

	    OPEN indexlist
	    FETCH NEXT FROM indexlist INTO @indexname, @indexid

	    WHILE @@FETCH_STATUS = 0
	    BEGIN
            --Build index key
            set @curkeyno = 2

            SET @indexkey = (SELECT indexfield FROM utb_drop_indexkeys WHERE indexname = @indexname AND keyno = 1)

            WHILE (SELECT MAX(keyno) FROM utb_drop_indexkeys WHERE indexname = @indexname) >= @curkeyno
            BEGIN
            SET @indexkey = (SELECT @indexkey+','+indexfield FROM utb_drop_indexkeys WHERE indexname = @indexname AND keyno = @curkeyno)
            SET @curkeyno = @curkeyno + 1
            END

            INSERT INTO utb_drop_indexinfo VALUES (@tablename,@indexname,@indexid,@indexkey)

            PRINT 'Alter_index, DROP ' + @tablename+'.['+@indexname+'] :'+CONVERT(CHAR,GETDATE())

            EXEC ('DROP INDEX '+@tablename+'.['+@indexname+']')

            IF EXISTS (SELECT * FROM #alter_index_sp_list WHERE stat_name = 'SP_'+@indexName)
            BEGIN
                SET @lccmd = 'DROP STATISTICS ' + @tablename + '.sp_' + @indexName 
                PRINT 'DROP STATISTICS ' + @tablename + '.sp_' + @indexName + '  :'+CONVERT(CHAR,GETDATE())
                EXEC (@lccmd)
            END

            FETCH NEXT FROM indexlist INTO @indexname, @indexid
	    END

        CLOSE indexlist
        DEALLOCATE indexlist

    END

END
IF @act_type = 'C'
BEGIN
	-- Re-Create indexes

    PRINT 'Alter_index, CREATE ' + @tablename+' :'+CONVERT(CHAR,GETDATE())

    IF EXISTS (SELECT * FROM utb_drop_indexinfo
		         WHERE UPPER(RTRIM(table_name)) = UPPER(RTRIM(@tablename)))
    BEGIN
        DECLARE indexlist CURSOR FOR
	        SELECT indexname, indexkey FROM utb_drop_indexinfo
	          WHERE UPPER(RTRIM(table_name)) = UPPER(RTRIM(@tablename))

        OPEN indexlist
        FETCH NEXT FROM indexlist INTO @indexname, @indexkey

        WHILE @@FETCH_STATUS = 0
        BEGIN
            PRINT 'Alter_index, CREATE [' + @indexname+'] ON '+@tablename+' ('+@indexkey+'):  '+CONVERT(CHAR,GETDATE())	
            SET @lcCmd = 'CREATE INDEX ['+@indexname+'] ON '+@tablename+' (['
			            +REPLACE(@indexkey,',','],[') + '])'
						+ CASE WHEN ISNULL(@file_grp,'') = '' THEN '' ELSE ' ON ' + @file_grp END

            EXEC (@lccmd)

            SET @lccmd = 'CREATE STATISTICS [sp_'+@indexname+'] ON '+@tablename+' (['
			            +REPLACE(@indexkey,',','],[') + '])'
    
            PRINT 'CREATE STATISTICS [sp_'+@indexname+'] ON '+@tablename+' (['
			            +REPLACE(@indexkey,',','],[') + ']) :  '+CONVERT(CHAR,GETDATE())	
            EXEC (@lccmd)

            FETCH NEXT FROM indexlist INTO @indexname, @indexkey

        END
        CLOSE indexlist
        DEALLOCATE indexlist
    END

    PRINT 'exec usp_remove_auto_status ' + @tablename + ' : ' + CONVERT(CHAR,GETDATE())	
    EXEC usp_remove_auto_stats @lcTab = @tablename, @lbexec = 1


-- Drop all records from utb_drop_indexinfo for this table
--	DELETE FROM utb_drop_indexinfo
--	  WHERE UPPER(RTRIM(table_name)) = UPPER(RTRIM(@tablename))
END







GO
