SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/*

EXEC prRunMeasures
    @iLoadInstanceID = 1,
	@lcCurYearMonth = '200712',
	@lcStartDate = '20070101',
	@lcEndDate = '20071231',
	@liRunMeasures  = 1

GO

EXEC usp_send_mail 'leon.dowling@imihealth.com', 
'leon.dowling@imihealth.com', 
'usp_prep_hedis_fact complete', 
'usp_prep_hedis_fact complete'


*/


-- INSERT INTO dw_build_metrics_hdr (rundate) SELECT getdate()
--/*
CREATE PROC [dbo].[prRunMeasures]

@iLoadInstanceID INT, 
@lcCurYearMonth VARCHAR(6),
@lcStartDate char(8),
@lcEndDate char(8),
@liRunMeasures INT = 1

AS
--*/
/*----------------------------------------
DECLARE @iLoadInstanceID INT, 
    @lcCurYearMonth VARCHAR(6),
    @lcStartDate char(8),
    @lcEndDate char(8),
	@liRunMeasures INT

SET @iLoadInstanceID = 1
SET @liRunMeasures = 1
SET @lcCurYearMonth = '20071231'
SET @lcStartDate = '20070101'
SET @lcEndDate = '20071231'
*/----------------------------------------

DECLARE @liMember_key INT,
    @liAge_key INT,
    @lccmd VARCHAR(8000),
    @libm_hdr_key INT,
    @ldrundate DATETIME,
    @lcCurDB VARCHAR(50),
	@lcMeas_id VARCHAR(3),
	@lcMeas_sql VARCHAR(50),
	@liRecCnt INT,
    @liPcpKey INT,
    @liMedicalGroupKey INT,
    @liReportEndingDateKey INT,
    @lcArcDateTime VARCHAR(20)




SET @lcCurDB = (SELECT MIN(table_catalog) FROM information_schema.columns)

SET @lcArcDateTime = CONVERT(VARCHAR(8),GETDATE(),112)+'_' 
                     + REPLICATE('0',2-LEN(CONVERT(VARCHAR(2),DATEPART(hh,GETDATE())))) + CONVERT(VARCHAR(2),DATEPART(hh,GETDATE()))
                     + REPLICATE('0',2-LEN(CONVERT(VARCHAR(2),DATEPART(mi,GETDATE())))) + CONVERT(VARCHAR(2),DATEPART(mi,GETDATE()))



EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID,'prRunMeasures', 'Started'

BEGIN 

    print 'run measures'
	IF OBJECT_ID('tempdb..#meas_list') IS NOT NULL
		DROP TABLE #meas_list

	CREATE TABLE #meas_list (meas_id VARCHAR(3), meas_sp VARCHAR(50))
	
--	INSERT INTO #meas_list SELECT 'AAB','POP_HEDIS_FACT_AAB'
	INSERT INTO #meas_list SELECT 'AAP','POP_HEDIS_FACT_AAP'
--	INSERT INTO #meas_list SELECT 'ADD','POP_HEDIS_FACT_ADD'
	INSERT INTO #meas_list SELECT 'AMB','POP_HEDIS_FACT_AMB'
--	INSERT INTO #meas_list SELECT 'AMM','POP_HEDIS_FACT_AMM'
--	INSERT INTO #meas_list SELECT 'APC','POP_HEDIS_FACT_APC'
--	INSERT INTO #meas_list SELECT 'ART','POP_HEDIS_FACT_ART'
	INSERT INTO #meas_list SELECT 'ASM','POP_HEDIS_FACT_ASM'
--	INSERT INTO #meas_list SELECT 'AWC','POP_HEDIS_FACT_AWC'
	INSERT INTO #meas_list SELECT 'BCS','POP_HEDIS_FACT_BCS'
--	INSERT INTO #meas_list SELECT 'CAP','POP_HEDIS_FACT_CAP'
--	INSERT INTO #meas_list SELECT 'CBP','POP_HEDIS_FACT_CBP'
--	INSERT INTO #meas_list SELECT 'CCS','POP_HEDIS_FACT_CCS'
	INSERT INTO #meas_list SELECT 'CDC','POP_HEDIS_FACT_CDC'
--	INSERT INTO #meas_list SELECT 'CHL','POP_HEDIS_FACT_CHL'
--	INSERT INTO #meas_list SELECT 'CIS','POP_HEDIS_FACT_CCS'
--	INSERT INTO #meas_list SELECT 'CMC','POP_HEDIS_FACT_CMC'
--	INSERT INTO #meas_list SELECT 'COL','POP_HEDIS_FACT_COL'
--	INSERT INTO #meas_list SELECT 'CWP','POP_HEDIS_FACT_CWP'
	INSERT INTO #meas_list SELECT 'DAE','POP_HEDIS_FACT_DAE'
	INSERT INTO #meas_list SELECT 'DDE','POP_HEDIS_FACT_DDE'
--	INSERT INTO #meas_list SELECT 'EBC','POP_HEDIS_FACT_EBC'
--	INSERT INTO #meas_list SELECT 'FPC','POP_HEDIS_FACT_FPC'
--	INSERT INTO #meas_list SELECT 'FSP','POP_HEDIS_FACT_FSP'
--	INSERT INTO #meas_list SELECT 'FUH','POP_HEDIS_FACT_FUH'
	INSERT INTO #meas_list SELECT 'GSO','POP_HEDIS_FACT_GSO'
	INSERT INTO #meas_list SELECT 'IPU','POP_HEDIS_FACT_IPU'
	INSERT INTO #meas_list SELECT 'LBP','POP_HEDIS_FACT_LBP'
--	INSERT INTO #meas_list SELECT 'LSC','POP_HEDIS_FACT_LSC'
	INSERT INTO #meas_list SELECT 'MPM','POP_HEDIS_FACT_MPM'
	INSERT INTO #meas_list SELECT 'OMW','POP_HEDIS_FACT_OMW'
	INSERT INTO #meas_list SELECT 'PBH','POP_HEDIS_FACT_PBH'
	INSERT INTO #meas_list SELECT 'PCE','POP_HEDIS_FACT_PCE'
--	INSERT INTO #meas_list SELECT 'PPC','POP_HEDIS_FACT_PPC'
	INSERT INTO #meas_list SELECT 'RAS','POP_HEDIS_FACT_RAS'
--	INSERT INTO #meas_list SELECT 'RCA','POP_HEDIS_FACT_RCA'
--	INSERT INTO #meas_list SELECT 'RCO','POP_HEDIS_FACT_RCO'
	INSERT INTO #meas_list SELECT 'RDI','POP_HEDIS_FACT_RDI'
--	INSERT INTO #meas_list SELECT 'RHY','POP_HEDIS_FACT_RHY'
--	INSERT INTO #meas_list SELECT 'RLB','POP_HEDIS_FACT_RLB'
	INSERT INTO #meas_list SELECT 'SPR','POP_HEDIS_FACT_SPR'
--	INSERT INTO #meas_list SELECT 'URI','POP_HEDIS_FACT_URI'
--	INSERT INTO #meas_list SELECT 'W15','POP_HEDIS_FACT_W15'
--	INSERT INTO #meas_list SELECT 'W34','POP_HEDIS_FACT_W34'

	SET @lcmeas_id = (SELECT MIN(meas_id) FROM #meas_list)
	SET @lcmeas_sql = (SELECT meas_sp FROM #meas_list WHERE meas_id = @lcMeas_id)

	IF OBJECT_ID('tempdb..#reccnt') IS NOT NULL
		DROP TABLE #reccnt

	CREATE TABLE #reccnt (rec int)

    IF OBJECT_ID('tempdb..#index') IS NOT NULL
        DROP TABLE #index
    
    CREATE TABLE #index (index_name VARCHAR(200), index_desc VARCHAR(1000), index_keys VARCHAR(2000))

    IF OBJECT_ID('tempdb..#stats') IS NOT NULL
        DROP TABLE #stats

    CREATE TABLE #stats (stat_name VARCHAR(100), stat_keys VARCHAR(1000))


	WHILE @lcmeas_id IS NOT NULL
	BEGIN

        SET @lccmd = 'prRunMeasures: process ' + @lcMeas_id+ ': ' + @lcStartDate + ' - ' + @lcEndDate 
      
        EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID,@lccmd, 'Started'

		SET @lcCmd = 'EXEC POP_HEDIS_FACT_'+@lcMeas_id + ' '''+@lcCurYearMonth+''',''' + @lcStartdate + ''',''' + @lcEnddate + ''''
		PRINT @lccmd
		EXEC (@lccmd)

		SET @lccmd = 'SELECT COUNT(*) FROM utb_hedis_' + @lcMeas_id
		PRINT @lccmd
		TRUNCATE TABLE #reccnt

		INSERT INTO #reccnt
		EXEC (@lccmd)

		SET @liRecCnt = (SELECT rec FROM #reccnt)

        SET @lccmd = 'utb_hedis_'+@lcMeas_id

        EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted', @liRecCnt, 'prRunMeasures', @lccmd , @liRecCnt

        -- Confirm index
        SET @lccmd = 'sp_helpindex utb_hedis_' + @lcMeas_id
        PRINT @lccmd

        TRUNCATE TABLE #index
    
        INSERT INTO #index
        EXEC (@lccmd)

        IF NOT EXISTS (SELECT * FROM #index
                        WHERE index_name = 'fk_utb_hedis_' + @lcMeas_id)
        BEGIN
            SET @lccmd = 'CREATE INDEX fk_utb_hedis_' + @lcMeas_id + ' on utb_hedis_' + @lcMeas_id + ' (ihds_member_id,service_char_full_date)'
            PRINT @lccmd
            EXEC (@lccmd)
    
            TRUNCATE TABLE #stats
            SET @Lccmd = 'sp_helpstats utb_hedis_' + @lcMeas_id
            PRINT @lccmd
            
            INSERT INTO #stats
            EXEC (@lccmd)

            IF EXISTS (SELECT * FROM #stats
                         WHERE stat_name = 'sp_fk_utb_hedis_' + @lcMeas_id)
            BEGIN
                SET @lccmd = 'DROP STATISTICS utb_hedis_' + @lcMeas_id + '.sp_fk_utb_hedis_' + @lcMeas_ID
                PRINT @lccmd
                EXEC (@lccmd)
            END

            SET @lccmd = 'CREATE STATISTICS sp_fk_utb_hedis_' + @lcMeas_id + ' on utb_hedis_' + @lcMeas_id + ' (ihds_member_id,service_char_full_date)'
            PRINT @lccmd
            EXEC (@lccmd)
        END                

--        -- Create arc
--
--        SET @lccmd = 'arc_utb_hedis_' + @lcMeas_ID + '_' + @lcArcDateTime
--        IF EXISTS (SELECT table_name FROM hh08_ihds_ds01_arc.information_schema.tables WHERE TABLE_NAME = @lccmd)
--        BEGIN
--            SET @lccmd = 'DROP TABLE HH08_IHDS_DS01_ARC..' + @lccmd
--            PRINT @lccmd
--            EXEC (@lccmd)
--        END
--
--        SET @lccmd = 'select a.*, LOB = ISNULL(b.lob,''''), health_plan = ISNULL(b.health_plan,''''), ' + CHAR(13)
--                    + ' eff_date = ISNULL(b.eff_date,''''), term_date = ISNULL(b.term_date,''''), ' + CHAR(13)
--                    + ' c.mem_pk1, c.mem_pk2, c.mem_pk3, c.mem_pk4,  '+ CHAR(13)
--					+ ' start_date = '''+@lcstartDate+''', end_date = '''+@lcenddate+'''' + CHAR(13)
--                    + ' into HH08_IHDS_DS01_ARC..arc_utb_hedis_' + @lcMeas_ID + '_' + @lcArcDateTime+ CHAR(13)
--                    + ' from utb_hedis_' + @lcMeas_ID + ' a '+ CHAR(13)
--                    + ' LEFT JOIN dw_hedis_member_elig b '+ CHAR(13) 
--                    + ' ON a.ihds_member_id = b.ihds_member_id '+ CHAR(13)
--                    + ' AND '''+ LEFT(@lcEndDate,6) + '01'' BETWEEN b.eff_date and b.term_date '+ CHAR(13)
--                    + ' INNER JOIN dw_xref_ihds_member_id c '+ CHAR(13)
--                    + ' ON a.ihds_member_id = c.ihds_member_id '
--
--        PRINT @lccmd
--        EXEC (@lccmd)

        SET @lccmd = 'prRunMeasures: process ' + @lcMeas_id+ ': ' + @lcStartDate + ' - ' + @lcEndDate 
      
        EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID,@lccmd, 'Completed'


		SET @lcmeas_id = (SELECT MIN(meas_id) FROM #meas_list
							WHERE meas_id > @lcMEas_id)
		SET @lcmeas_sql = (SELECT meas_sp FROM #meas_list WHERE meas_id = @lcMeas_id)

	END


END
EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID,'prRunMeasures', 'Complete'




GO
