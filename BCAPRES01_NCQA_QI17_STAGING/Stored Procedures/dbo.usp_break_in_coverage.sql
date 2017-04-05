SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






/*
20071030	- Changes added by Randy Wilson to accomodate multiple gaps in the same month.



IF OBJECT_ID('tempdb..#test') IS NOT NULL
DROP TABLE #test


CREATE TABLE #test (
    ihds_member_id INT,
    [service_char_full_date] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
    [prev_day_diff] [int] NULL ,
    [prev_term_date] varchar(8) NULL ,
    [eff_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
    [term_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
    [bic_30_min_eff_dt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
    [bic_45_min_eff_dt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
    [min_eff_dt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
    [bic_30_eff_dt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
    [bic_45_eff_dt] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
    [tot_months_without_bic_30] [int] NULL ,
    [tot_months_without_bic_45] [int] NULL,
	dob varchar(8),
	sex varchar(1),
	age_in_years int,
	age_in_months int)

INSERT INTO utb_hedis_cont_enroll
EXEC usp_break_in_coverage  '20060101','20061231'

*/
--/*

--use ncqa_ihds_dw01_test1

CREATE     PROC [dbo].[usp_break_in_coverage]

@lcStartDate VARCHAR(8), --= '20040101',
@lcEndDate VARCHAR(8) --= '20041231'

AS
--*/
-----------------------------------------------------
--DECLARE @lcStartDate VARCHAR(8),
--    @lcEndDate VARCHAR(8),
--    @liBreak_In_coverage INT
--
--SET @lcStartDate = '20070101'
--SET @lcEndDate = '20071231'
--SET @liBreak_In_coverage = 45
------------------------------------------------------



-- SEt the startdate back 2years
SET @lcStartDate = CONVERT(VARCHAR(8),DATEADD(yy,-2,CONVERT(datetime,@lcStartDate)),112)



IF 1 = 1
BEGIN 

	-- Anchor LOB
	IF OBJECT_ID('tempdb..#anchor_lob') IS NOT NULL
		DROP TABLE #anchor_lob

	select	a.ihds_member_id,
			anchor_lob		= max(lob)
		into #anchor_lob
		FROM dw_hedis_member_elig a
		WHERE @lcEndDate between eff_date and term_date
		group by a.ihds_member_id


	-- Elig List
	IF OBJECT_ID('tempdb..#mbr_elig') IS NOT NULL
		DROP TABLE #mbr_elig

	CREATE TABLE #mbr_elig
		(elig_seq VARCHAR(30),
		ihds_member_id int,
		eff_date DATETIME,
		term_date DATETIME,
		elig_hist_seq VARCHAR(10),
		lob varchar(20))

	INSERT INTO #mbr_elig
    SELECT a.dw_hedis_member_elig_key,
            a.ihds_member_id,
            a.eff_date,
            term_date = CASE WHEN a.term_date = '' THEN '29981231' ELSE a.term_date END,
            elig_hist_seq = a.dw_hedis_member_elig_key,
			lob
        FROM dw_hedis_member_elig a
        ORDER BY a.ihds_member_id, a.eff_date

	DELETE #mbr_elig  
		FROM #mbr_elig a 
		inner join #anchor_lob b on
			a.ihds_member_id = b.ihds_member_id and
			b.anchor_lob not in ('PPO','MP')
		WHERE lob in ('PPO','MP')


	DELETE #mbr_elig  
		FROM #mbr_elig a 
		inner join #anchor_lob b on
			a.ihds_member_id = b.ihds_member_id and
			b.anchor_lob in ('PPO','MP')
		WHERE lob not in ('PPO','MP')

--added by RLW to remove overlapping eligibility:
	UPDATE #mbr_elig 
	set	term_date = dateadd(dd,-1,b.eff_date)
		FROM #mbr_elig 
		inner join #mbr_elig b on
			#mbr_elig.ihds_member_id = b.ihds_member_id and
			#mbr_elig.term_date between b.eff_date and b.term_date and
			not (#mbr_elig.eff_date = b.eff_date and #mbr_elig.term_date = b.term_date)

    CREATE INDEX fk_mbr_elig ON #mbr_elig (ihds_member_id)
    CREATE STATISTICS sp_fk_mbr_elig ON #mbr_elig (ihds_member_id)

END 



IF OBJECT_ID('tempdb..#mbr') IS NOT NULL
    DROP TABLE #mbr

SELECT DISTINCT a.ihds_member_id
    INTO #mbr
    FROM #mbr_elig a
    WHERE CONVERT(VARCHAR(8),eff_date,112) <= @lcEndDate
        and (term_date IS NULL
            OR CONVERT(VARCHAR(8),term_date,112) >= @lcStartDate)
    GROUP BY a.ihds_member_id


IF OBJECT_ID('tempdb..#elig_history') IS NOT NULL
    DROP TABLE #elig_history

SELECT a.ihds_member_id,
    a.elig_seq,
    a.eff_date,
    a.term_date
    INTO #elig_history
    FROM #mbr_elig a
        INNER JOIN #mbr b
            ON a.ihds_member_id = b.ihds_member_id

CREATE INDEX fk_#elig_history ON #elig_history (ihds_member_id, term_date)
CREATE STATISTICS sp_fk_#elig_history ON #elig_history (ihds_member_id, term_date)





IF OBJECT_ID('tempdb..#pass1a') IS NOT NULL
    DROP TABLE #pass1a

SELECT a.ihds_member_id,
        a.elig_seq,
        eff_date  = CONVERT(VARCHAR(8),a.eff_date,112),
        term_date = ISNULL(CONVERT(VARCHAR(8),a.term_date,112),'99981231'),
        MAX(b.term_date) prev_term_date
    INTO #pass1a
    FROM #elig_history a
        LEFT JOIN #elig_history b
            ON a.ihds_member_id = b.ihds_member_id
            AND CONVERT(VARCHAR(8),a.eff_date,112) > CONVERT(VARCHAR(8),b.term_date,112)
        INNER JOIN #mbr c
            ON a.ihds_member_id = c.ihds_member_id
    GROUP BY a.ihds_member_id, a.elig_seq, a.eff_date, a.term_date


IF OBJECT_ID('tempdb..#pass1') IS NOT NULL
    DROP TABLE #pass1

SELECT a.*, day_diff = CASE
                        WHEN ISNULL(prev_term_date,'')  = ''
                            THEN 0
                        ELSE DATEDIFF(dd,prev_term_date, eff_date) - 1
                        END
    INTO #pass1
    FROM #pass1a a
    ORDER BY a.ihds_member_id, a.eff_date, a.term_date

CREATE INDEX fk_#pass1 ON #pass1 (ihds_member_id, eff_date)
CREATE STATISTICS sp_fk_#pass1 ON #pass1 (ihds_member_id, eff_date)



DECLARE @lcHoldDate VARCHAR(8)

IF OBJECT_ID('tempdb..#month') IS NOT NULL
    DROP TABLE #month

CREATE TABLE #month (mth VARCHAR(8))

SET @lcHoldDate = @lcStartDate

WHILE @lcHOldDate < @lcEndDate
BEGIN
	INSERT INTO #month SELECT @lcHOldDate
	SET @lcHoldDate = CONVERT(VARCHAR(8),DATEADD(mm,1,@lcHoldDate),112)
END





IF OBJECT_ID('tempdb..#pass2') IS NOT NULL
    DROP TABLE #pass2

SELECT ihds_member_id,
        elig_seq,
        CONVERT(DATETIME,b.mth) srv_dt,
        prev_day_diff = CASE WHEN LEFT(eff_date,6) = LEFT(b.mth,6) THEN day_diff ELSE 0 END,
        prev_term_date = CASE WHEN LEFT(eff_date,6) = left(mth,6) THEN prev_term_date ELSE dateadd(dd,-1,mth) END,
        a.eff_date,
        a.term_date,
        b.mth,
		old_prev_term_date = a.prev_term_date
    INTO #pass2
    FROM #pass1 a
        INNER JOIN #month b
            ON b.mth BETWEEN a.eff_date AND a.term_date

--need to add rows for any non first of the month starts to their end date, or the end of the month.
--should be able to replace next step with this code.


insert into #pass2
select	ihds_member_id,
        elig_seq,
        srv_dt				= CONVERT(DATETIME,eff_date),
        prev_day_diff		= day_diff,
        prev_term_date		= prev_term_date,
        eff_date,
        term_date,
        mth					= eff_date,
		old_prev_term_date	= NULL
from	#pass1
where	right(eff_date,2) <> '01' and
		(convert(varchar(8),dateadd(dd,1,prev_term_date),112)<> eff_date or
		prev_term_date is null)
		

--select * from #pass1 where ihds_member_id = '70230'
--
--
--IF OBJECT_ID('tempdb..#unduplicated_non_first_of_month') IS NOT NULL
--    DROP TABLE #unduplicated_non_first_of_month
--
--select	a.ihds_member_id,
--		b.mth,
--		min(a.eff_date) as eff_date_min
--	into #unduplicated_non_first_of_month
--   FROM #pass1 a
--        INNER JOIN #month b
--            ON left(b.mth,6) BETWEEN left(a.eff_date,6) AND left(a.term_date,6)
--		left join #pass2 c 
--			on a.ihds_member_id = c.ihds_member_id and
--			   b.mth = c.mth
--where c.ihds_member_id is null
--group by a.ihds_member_id,
--		b.mth
--
--
--
--insert into #pass2
--SELECT a.ihds_member_id,
--        a.elig_seq,
--        CONVERT(DATETIME,b.mth) srv_dt,
--        prev_day_diff = CASE WHEN LEFT(a.eff_date,6) = LEFT(b.mth,6) THEN day_diff ELSE 0 END,
--        prev_term_date = CASE WHEN LEFT(a.eff_date,6) = left(b.mth,6) THEN a.prev_term_date ELSE dateadd(dd,-1,b.mth) END,
--        a.eff_date,
--        a.term_date,
--        b.mth,
--		a.prev_term_date
--    FROM #pass1 a
--        INNER JOIN #month b
--            ON left(b.mth,6) BETWEEN left(a.eff_date,6) AND left(a.term_date,6)
--		inner join #unduplicated_non_first_of_month uniq
--			on a.ihds_member_id = uniq.ihds_member_id and
--			   b.mth = uniq.mth and
--			   a.eff_date = uniq.eff_date_min
--		left join #pass2 c 
--			on a.ihds_member_id = c.ihds_member_id and
--			   b.mth = c.mth
--where c.ihds_member_id is null

CREATE INDEX fk_pass2 ON #pass2 (ihds_member_id, srv_dt)

--select * from #pass2 where ihds_member_id = '70230'

truncate table utb_hedis_cont_enroll
INSERT INTO utb_hedis_cont_enroll
SELECT a.ihds_member_id,
        a.elig_seq,
        a.mth,
        prev_day_diff,
        CONVERT(VARCHAR(8),prev_term_date,112),
        CONVERT(VARCHAR(8),a.eff_date,112),
        CONVERT(VARCHAR(8),a.term_date,112),
        bic_30_min_eff_dt,
        bic_45_min_eff_dt,
        min_eff_dt,
        bic_30_eff_dt = CASE WHEN bic_30_min_eff_dt IS NULL THEN min_eff_dt
                        ELSE bic_30_min_eff_dt
                        END,
        bic_45_eff_dt = CASE WHEN bic_45_min_eff_dt IS NULL THEN min_eff_dt
                        ELSE bic_45_min_eff_dt
                        END,
        tot_months_without_bic_30 = DATEDIFF(mm,CASE WHEN bic_30_min_eff_dt IS NULL THEN min_eff_dt
                                                    ELSE bic_30_min_eff_dt
                                                    END,srv_dt) + 1,
        tot_months_without_bic_45 = DATEDIFF(mm,CASE WHEN bic_45_min_eff_dt IS NULL THEN min_eff_dt
                                                    ELSE bic_45_min_eff_dt
                                                    END,srv_dt) + 1,
        c.dob,
		c.gender,
        age_in_years = CONVERT(NUMERIC(6,1),DATEDIFF(mm,c.dob,a.mth)/12.0),
        age_in_months = DATEDIFF(mm,c.dob,a.mth)
    FROM (SELECT *, bic_30_min_eff_dt = (SELECT max(eff_date)
                                        FROM #pass2 b
                                        WHERE a.ihds_member_id = b.ihds_member_id
                                            AND b.srv_dt <= a.srv_dt
                                            AND prev_day_diff > 30),
                bic_45_min_eff_dt = (SELECT max(eff_date)
                                        FROM #pass2 b
                                        WHERE a.ihds_member_id = b.ihds_member_id
                                            AND b.srv_dt <= a.srv_dt
                                            AND prev_day_diff > 45),
                min_eff_dt = (SELECT MIN(eff_date)
                                        FROM #pass2 b
                                        WHERE a.ihds_member_id = b.ihds_member_id)
            FROM #pass2 a
            ) a
		INNER JOIN dbo.dw_hedis_member c
            ON a.ihds_member_id = c.ihds_member_id
    ORDER BY a.ihds_member_id, a.mth





GO
