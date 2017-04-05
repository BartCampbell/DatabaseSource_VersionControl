SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Stored Procedure

/*
exec sp_helpindex pde_extract_log_dtl
exec sp_helpstats pde_extract_log_dtl

drop statistics pde_extract_log_dtl.sp_fk_pde_log_file_rec

drop index pde_resp_det.fk_pdp_resp_det


create index fk_error_code on pde_on_hold_dtl (error_code)

create index fk_det_file_rec_no on pde_resp_det (det_file_rec_no)
create statistics sp_fk_det_file_rec_no on pde_resp_det (det_file_rec_no)

create statistics sp_fk_pd
sp_helpstats pde_data_bhd

exec usp_remove_auto_stats 'pde_data_bhd',1,0
*/

CREATE PROC [dbo].[usp_remove_auto_stats]

@lcTab VARCHAR(200)= '',
@lbexec BIT = 0,
@lbReCreateIndex BIT = 0

AS

/*-------------------------------------------
DECLARE @lcTab VARCHAR(200), @lbExec BIT
set @lcTab = 'pde_on_hold_dtl'
SET @lbExec = 0
*/-------------------------------------------
PRINT 'usp_remove_auto_stats'
DECLARE @lcstat VARCHAR(200),
    @lcCmd VARCHAR(2000),
    @lcKeys VARCHAR(200),
    @liSingleTab INT,
    @lcInd VARCHAR(200)

IF ISNULL(@lcTab,'') = ''
    SET @liSingleTab = 1
ELSE
    SET @liSingleTab = 0

IF OBJECT_ID('tempdb..#tab') IS NOT NULL
    DROP TABLE #tab
CREATE TABLE #tab (stat_name VARCHAR(200), stat_keys VARCHAR(1000))

IF OBJECT_ID('tempdb..#ind') IS NOT NULL
    DROP TABLE #ind
CREATE TABLE #ind (index_name VARCHAR(200), index_desc VARCHAR(1000), index_keys VARCHAR(2000))

IF OBJECT_ID('tempdb..#out') IS NOT NULL
    DROP TABLE #out
CREATE TABLE #out (txt VARCHAR(2000), rec_id INT IDENTITY(1,1))

IF @liSingleTab = 1
    SET @lcTab = (SELECT MIN(table_name) FROM INFORMATION_SCHEMA.TABLES)

WHILE @lcTab IS NOT NULL
BEGIN

    INSERT INTO #out SELECT '--'+ @lcTab

    INSERT INTO #tab
    EXEC sp_helpstats @lcTab

    INSERT INTO #ind
    EXEC sp_helpindex @lcTab

--    SELECT * FROM #tab

--    SELECT * FROM #ind

    SET @lcStat = (SELECT MIN(stat_name) FROM #tab WHERE LEFT(stat_name,3) = '_WA')
    WHILE @lcStat IS NOT NULL
    BEGIN

        SET @lckeys = (SELECT stat_keys FROM #tab WHERE stat_name = @lcStat)

        SET @lccmd = 'DROP STATISTICS ' + @lcTab + '.' + @lcStat + '-- ' + @lcKeys
        PRINT @lccmd
        IF @lbexec = 1
            EXEC (@lccmd)

        INSERT INTO #out SELECT @lccmd

        IF NOT EXISTS (SELECT * FROM #tab a
                        WHERE stat_keys = @lcKeys
                            AND LEFT(stat_name,3) <> '_WA')
            AND NOT EXISTS (SELECT *
                                FROM #ind b
                                WHERE index_keys= @lcKeys)
			AND @lbReCreateIndex = 1
        BEGIN
            SET @lccmd = 'CREATE INDEX fk'+@lcKeys + ' ON ' + @lcTab + ' (' + @lcKeys + ')'
            PRINT @lccmd
            IF @lbexec = 1
                EXEC (@lccmd)

            INSERT INTO #out SELECT @lccmd

            SET @lccmd = 'CREATE STATISTICS sp_fk'+@lcKeys + ' ON ' + @lcTab + ' (' + @lcKeys + ')'
            PRINT @Lccmd
            IF @lbexec = 1
                EXEC (@lccmd)

            INSERT INTO #out SELECT @lccmd
        END

        SET @lcStat = (SELECT MIN(stat_name) FROM #tab WHERE LEFT(stat_name,3) = '_WA'
                        AND stat_name > @lcStat)

    END

    -- make sure all indexes have stats
    SET @lcInd = (SELECT MIN(index_name) FROM #ind)
    WHILE @lcInd IS NOT NULL
    BEGIN

        SET @lcKeys = (SELECT index_keys FROM #ind WHERE index_name = @lcInd)

        IF NOT EXISTS (SELECT *
                        FROM #tab
                        WHERE stat_keys = @lcKeys
                            AND LEFT(stat_name,3) <> '_WA')
        BEGIN

            SELECT @lccmd = 'CREATE STATISTICS sp_' + index_name + ' ON ' + @lcTab + ' ( ' + index_keys + ')'
                FROM #ind
                WHERE index_name = @lcInd
            PRINT (@lccmd)
            IF @lbexec = 1
                EXEC (@lccmd)

            INSERT INTO #out SELECT @lccmd

        END

        SET @lcInd = (SELECT MIN(index_name) FROM #ind WHERE index_name > @lcInd)
    END


    TRUNCATE TABLE #tab
    TRUNCATE TABLE #ind

    IF @liSingleTab = 0
        SET @lcTab = NULL
    ELSE
        SET @lcTab = (SELECT MIN(table_name) FROM INFORMATION_SCHEMA.TABLES
                         WHERE table_name > @lcTab)

END


--SELECT txt 
--    FROM #out
--    ORDER BY rec_id





GO
