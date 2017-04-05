SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE PROC [dbo].[usp_create_cont_enrollment_res_asm]
	@lcCurYrStDate VARCHAR(8),
    @lcCurYrEndDate VARCHAR(8),
    @liPrevYearFlag INT,
    @liPrev2YearFlag INT,
    @liMaxAllowedDayDiff INT,
    @liYearlyBreakInCovCount INT,
    @liEligAtEndOfCurYear INT
AS
-- Dependencies:
--   Tables:
--     dw_hedis_member_elig
--     utb_hedis_cont_enroll
/*
modifications:
20070416 - Changed anchor date requirement of #MbrList to use dw_hedis_member_elig.
20070416 - Modified bic assessments to ensure year end breaks were counted and assessed.
20070417 - Modified bic assessments to ensure year end breaks were not counted in the next year


*/


DECLARE @lcPrevYrStDate VARCHAR(8),
    @lcPrevYrEndDate VARCHAR(8),
    @lcPrev2YrStDate VARCHAR(8),
    @lcPrev2YrEndDate VARCHAR(8)


--DECLARE @lcCurYrStDate VARCHAR(8),
--    @lcCurYrEndDate VARCHAR(8),
--    @liPrevYearFlag INT,
--    @liPrev2YearFlag INT,
--    @liMaxAllowedDayDiff INT,
--    @liYearlyBreakInCovCount INT,
--    @liEligAtEndOfCurYear INT
--
--
--SELECT @lcCurYrStDate ='20080101',
--    @lcCurYrEndDate = '20081231',
--    @liPrevYearFlag = 1,
--    @liPrev2YearFlag = 0,
--    @liMaxAllowedDayDiff = 45,
--    @liYearlyBreakInCovCount = 1,
--    @liEligAtEndOfCurYear = 1



-- 0,0,30,1,1 = 155,809, 107,193
-- 1,0,30,1,1 = 155,809,  71,857
-- 1,1,30,1,1 = 155,809,  36,411
-- 1,1,45,1,1 = 155,809,  37,665




SET @lcPrevYrStDate = CONVERT(VARCHAR(8),DATEADD(yy,-1,@lcCurYrStDate),112)
SET @lcprevYrEndDate = CONVERT(VARCHAR(8),DATEADD(yy,-1,@lcCurYrEndDate),112)
SET @lcPrev2YrStDate = CONVERT(VARCHAR(8),DATEADD(yy,-2,@lcCurYrStDate),112)
SET @lcprev2YrEndDate = CONVERT(VARCHAR(8),DATEADD(yy,-2,@lcCurYrEndDate),112)







-- Anchor LOB
IF OBJECT_ID('tempdb..#anchor_lob') IS NOT NULL
	DROP TABLE #anchor_lob

select	a.ihds_member_id,
		anchor_lob		= max(lob)
into	#anchor_lob
FROM	dw_hedis_member_elig a
WHERE	@lcCurYrEndDate between eff_date and term_date
group by a.ihds_member_id


IF OBJECT_ID('tempdb..#dw_hedis_member_elig') IS NOT NULL
    DROP TABLE #dw_hedis_member_elig

select	*
into	#dw_hedis_member_elig 
from	dw_hedis_member_elig


DELETE #dw_hedis_member_elig  
FROM	#dw_hedis_member_elig a 
		inner join #anchor_lob b on
			a.ihds_member_id = b.ihds_member_id and
			b.anchor_lob not in ('PPO','MP')
WHERE	lob in ('PPO','MP')


DELETE #dw_hedis_member_elig  
FROM	#dw_hedis_member_elig a 
		inner join #anchor_lob b on
			a.ihds_member_id = b.ihds_member_id and
			b.anchor_lob in ('PPO','MP')
WHERE lob not in ('PPO','MP')






-- Start with members that are either elig at end of the current year
--    or have eligibility at any part of the reporting period
IF OBJECT_ID('tempdb..#MbrList') IS NOT NULL
    DROP TABLE #MbrList

CREATE TABLE #MbrList (ihds_member_id INT)



IF @liEligAtEndOfCurYear = 1
    INSERT INTO #MbrList
    SELECT DISTINCT a.ihds_member_id 
        FROM #dw_hedis_member_elig a
        WHERE @lcCurYrEndDate BETWEEN a.eff_date AND a.term_date and
			 CoveragePharmacyFlag = 'Y'
ELSE
    IF @liPrev2YearFlag = 1
        INSERT INTO #MbrList
        SELECT DISTINCT a.ihds_member_id
            FROM #dw_hedis_member_elig a
            WHERE a.eff_date <= @lcCurYrEndDate 
                AND a.term_date >= @lcPrev2YrStDate
    ELSE
        IF @liPrevYearFlag = 1   
            INSERT INTO #MbrList
            SELECT DISTINCT a.ihds_member_id
                FROM #dw_hedis_member_elig a
                WHERE a.eff_date <= @lcCurYrEndDate 
                    AND a.term_date >= @lcPrevYrStDate
        ELSE
            INSERT INTO #MbrList
            SELECT DISTINCT a.ihds_member_id
                FROM #dw_hedis_member_elig a
                WHERE a.eff_date <= @lcCurYrEndDate 
                    AND a.term_date >= @lcCurYrStDate

--select * from #MbrList where ihds_member_id = '58831'


-- Create tables for current year stats
BEGIN
    IF OBJECT_ID('tempdb..#current_year') IS NOT NULL
        DROP TABLE #current_year

    SELECT a.*,
            break_in_coverage_count =	CASE	WHEN prev_day_diff <> 0 and a.eff_date = @lcCurYrStDate
												THEN 0
												WHEN prev_day_diff <> 0 
												THEN 1 
												ELSE 0 
										END,
            length_of_break_in_cov_in_year = 
							CASE	WHEN prev_term_date is null then DATEDIFF(dd,@lcCurYrStDate,a.eff_date)
									WHEN prev_day_diff = 0 THEN 0
									WHEN prev_term_date >= @lcCurYrStDate THEN prev_day_diff
                                    ELSE DATEDIFF(dd,@lcCurYrStDate,a.eff_date)
							END
        INTO #current_year 
        FROM utb_hedis_cont_enroll a
            INNER JOIN #MbrList b
                ON a.ihds_member_id = b.ihds_member_id
			INNER JOIN dw_hedis_member_elig c 
				ON a.ihds_member_id = c.ihds_member_id and
				   a.eff_date between c.eff_date and c.term_date and
				   c.CoveragePharmacyFlag		= 'Y'
        WHERE service_char_full_date BETWEEN @lcCurYrStDate and @lcCurYrEndDate
        ORDER BY a.ihds_member_id, a.service_char_full_date


--select * from #current_year_ext1 where ihds_member_id = '3436491'
--select * from dw_hedis_member_elig where ihds_member_id = '642601'
--select * from #current_year where ihds_member_id = '3436491'

    IF OBJECT_ID('tempdb..#current_year_ext1') IS NOT NULL
        DROP TABLE #current_year_ext1
            
    SELECT ihds_member_id,
            current_year_break_in_coverage_count = (SELECT COUNT(*)
                                                    FROM #current_year b
                                                    WHERE a.ihds_member_id = b.ihds_member_id
													    AND b.break_in_coverage_count > 0),
            current_year_length_over_max = (SELECT COUNT(*)
                                            FROM #current_year b
                                            WHERE a.ihds_member_id = b.ihds_member_id
                                                AND b.length_of_break_in_cov_in_year > @liMaxAllowedDayDiff),
            current_year_eff_first = (SELECT COUNT(*)
                                            FROM #dw_hedis_member_elig elig
                                            WHERE a.ihds_member_id = elig.ihds_member_id
												AND elig.CoveragePharmacyFlag = 'Y'
                                                AND @lcCurYrStDate BETWEEN elig.eff_date and elig.term_date
                                        ),
            Current_year_elig_on_max_bic_day = (SELECT COUNT(*)
                                            FROM #dw_hedis_member_elig elig
                                            WHERE a.ihds_member_id = elig.ihds_member_id
												AND elig.CoveragePharmacyFlag = 'Y'
                                                AND CONVERT(VARCHAR(8),CONVERT(DATETIME,@lcCurYrStDate)+@liMaxAllowedDayDiff,112)
                                                    BETWEEN elig.eff_date and elig.term_date
                                    ),
            Current_year_elig_on_min_bic_day = (SELECT COUNT(*)
                                            FROM #dw_hedis_member_elig elig
                                            WHERE a.ihds_member_id = elig.ihds_member_id
												AND elig.CoveragePharmacyFlag = 'Y'
                                                AND CONVERT(VARCHAR(8),CONVERT(DATETIME,@lcCurYrEndDate)-@liMaxAllowedDayDiff,112)
                                                    BETWEEN elig.eff_date and elig.term_date
                                    ),
            Current_year_end = (SELECT COUNT(*)
                                            FROM #dw_hedis_member_elig elig
                                            WHERE a.ihds_member_id = elig.ihds_member_id
												AND elig.CoveragePharmacyFlag = 'Y'
                                                AND @lcCurYrEndDate BETWEEN elig.eff_date and elig.term_date
                                    ),
            hedis_eligibility_flag = 0
        INTO #current_year_ext1
        FROM #MbrList a

        UPDATE #current_year_ext1
        SET hedis_eligibility_flag = CASE WHEN ((current_Year_break_in_coverage_count <= 1
                                                    AND current_year_length_over_max = 0
                                                    AND current_year_end = 1)
                                                OR (current_Year_break_in_coverage_count = 0
                                                    AND current_year_elig_on_max_bic_day = 1
                                                    AND current_year_end = 1)
                                                OR (current_Year_break_in_coverage_count = 0
                                                    AND current_year_elig_on_min_bic_day = 1
                                                    AND current_year_eff_first = 1))
                                        THEN 1 
                                        ELSE 0  
                                        END
END




--select * from #current_year_ext1 where ihds_member_id = '3045720'
--select * from #current_year_ext1 where ihds_member_id = '3045720'
--select * from #current_year_ext1 where ihds_member_id = '642601'
--select * from #current_year where ihds_member_id = '30242'


-- Create tables for previous year stats
IF @liPrevYearFlag = 1   
BEGIN
    IF OBJECT_ID('tempdb..#prev_year') IS NOT NULL
        DROP TABLE #prev_year

    SELECT a.*,
            break_in_coverage_count = 
										CASE	WHEN prev_day_diff <> 0 and eff_date = @lcPrevYrStDate
												THEN 0
												WHEN prev_day_diff <> 0 
												THEN 1 
												ELSE 0 
										END,
            length_of_break_in_cov_in_year = 
							CASE	WHEN prev_term_date is null then DATEDIFF(dd,@lcPrevYrStDate,eff_date)
									WHEN prev_day_diff = 0 THEN 0
									WHEN prev_term_date >= @lcPrevYrStDate THEN prev_day_diff
                                    ELSE DATEDIFF(dd,@lcPrevYrStDate,eff_date)
							END
        INTO #prev_year
        FROM utb_hedis_cont_enroll a
            INNER JOIN #MbrList b
                ON a.ihds_member_id = b.ihds_member_id
        WHERE service_char_full_date BETWEEN @lcPrevYrStDate and @lcPrevYrEndDate
        ORDER BY a.ihds_member_id, a.service_char_full_date


--select * from #current_year where ihds_member_id = '30242'

--select * from #prev_year where ihds_member_id = '8385'

    IF OBJECT_ID('tempdb..#prev_year_ext1') IS NOT NULL
        DROP TABLE #prev_year_ext1
            
    SELECT ihds_member_id,
            prev_year_break_in_coverage_count = (SELECT COUNT(*)
                                                    FROM #prev_year b
                                                    WHERE a.ihds_member_id = b.ihds_member_id
													    AND b.break_in_coverage_count > 0) +
												1 -
												(SELECT COUNT(*)
													FROM #dw_hedis_member_elig elig
													WHERE a.ihds_member_id = elig.ihds_member_id
														AND @lcPrevYrEndDate BETWEEN elig.eff_date and elig.term_date),
            prev_year_length_over_max = (SELECT COUNT(*)
                                            FROM #prev_year b
                                            WHERE a.ihds_member_id = b.ihds_member_id
                                                AND b.length_of_break_in_cov_in_year > @liMaxAllowedDayDiff)+
										(case	when	(SELECT COUNT(*)
															FROM #dw_hedis_member_elig elig
															WHERE a.ihds_member_id = elig.ihds_member_id
																AND @lcPrevYrEndDate BETWEEN elig.eff_date and elig.term_date)
														= 0
												then	case	when	datediff(	dd,
																					(select	max(term_date)
																					from	#dw_hedis_member_elig elig
																					WHERE	a.ihds_member_id = elig.ihds_member_id
																							AND elig.term_date between @lcPrevYrStDate and @lcPrevYrEndDate),
																					CONVERT(DATETIME,@lcPrevYrEndDate))>@liMaxAllowedDayDiff
																then	1
																else	0
														end
												else	0
										 end),
            prev_year_eff_first = (SELECT COUNT(*)
                                            FROM #dw_hedis_member_elig elig
                                            WHERE a.ihds_member_id = elig.ihds_member_id
                                                AND @lcPrevYrStDate BETWEEN elig.eff_date and elig.term_date
                                        ),
            prev_year_elig_on_max_bic_day = (SELECT COUNT(*)
                                            FROM #dw_hedis_member_elig elig
                                            WHERE a.ihds_member_id = elig.ihds_member_id
                                                AND CONVERT(VARCHAR(8),CONVERT(DATETIME,@lcPrevYrStDate)+@liMaxAllowedDayDiff,112)
                                                    BETWEEN elig.eff_date and elig.term_date
                                    ),
            prev_year_elig_on_min_bic_day = (SELECT COUNT(*)
                                            FROM #dw_hedis_member_elig elig
                                            WHERE a.ihds_member_id = elig.ihds_member_id
                                                AND CONVERT(VARCHAR(8),CONVERT(DATETIME,@lcPrevYrEndDate)-@liMaxAllowedDayDiff,112)
                                                    BETWEEN elig.eff_date and elig.term_date
                                    ),
            prev_year_end = (SELECT COUNT(*)
                                            FROM #dw_hedis_member_elig elig
                                            WHERE a.ihds_member_id = elig.ihds_member_id
                                                AND @lcPrevYrEndDate BETWEEN elig.eff_date and elig.term_date
                                    ),
            hedis_eligibility_flag = 0
        INTO #prev_year_ext1
        FROM #MbrList a

        UPDATE #prev_year_ext1
        SET hedis_eligibility_flag = CASE 
										WHEN b.ihds_member_id is null
										then 0
										WHEN ((prev_Year_break_in_coverage_count <= 1
                                                    AND prev_year_length_over_max = 0)
                                                OR (prev_Year_break_in_coverage_count = 0
                                                    AND prev_year_elig_on_max_bic_day = 1
                                                    AND prev_year_end = 1)
                                                OR (prev_Year_break_in_coverage_count = 0
                                                    AND prev_year_elig_on_min_bic_day = 1
                                                    AND prev_year_eff_first = 1))
                                        THEN 1 
                                        ELSE 0  
                                        END
		from #prev_year_ext1 a 
				left join #prev_year b  on
					a.ihds_member_id = b.ihds_member_id
END

--select * from #prev_year_ext1 where ihds_member_id = '3045720'
--select * from #res where ihds_member_id = '3045720'


-- Create tables for previous year2 stats
IF @liPrev2YearFlag = 1   
BEGIN
    IF OBJECT_ID('tempdb..#prev2_year') IS NOT NULL
        DROP TABLE #prev2_year

    SELECT a.*,
            break_in_coverage_count = 
										CASE	WHEN prev_day_diff <> 0 and eff_date = @lcprev2YrStDate
												THEN 0
												WHEN prev_day_diff <> 0 
												THEN 1 
												ELSE 0 
										END,
            length_of_break_in_cov_in_year = 
							CASE	WHEN prev_term_date is null then DATEDIFF(dd,@lcprev2YrStDate,eff_date)
									WHEN prev_day_diff = 0 THEN 0
									WHEN prev_term_date >= @lcprev2YrStDate THEN prev_day_diff
                                    ELSE DATEDIFF(dd,@lcprev2YrStDate,eff_date)
							END
        INTO #prev2_year
        FROM utb_hedis_cont_enroll a
            INNER JOIN #MbrList b
                ON a.ihds_member_id = b.ihds_member_id
        WHERE service_char_full_date BETWEEN @lcprev2YrStDate and @lcprev2YrEndDate
        ORDER BY a.ihds_member_id, a.service_char_full_date


    IF OBJECT_ID('tempdb..#prev2_year_ext1') IS NOT NULL
        DROP TABLE #prev2_year_ext1
            
    SELECT ihds_member_id,
            prev2_year_break_in_coverage_count = (SELECT COUNT(*)
                                                    FROM #prev2_year b
                                                    WHERE a.ihds_member_id = b.ihds_member_id
													    AND b.break_in_coverage_count > 0) +
												1 -
												(SELECT COUNT(*)
													FROM #dw_hedis_member_elig elig
													WHERE a.ihds_member_id = elig.ihds_member_id
														AND @lcprev2YrEndDate BETWEEN elig.eff_date and elig.term_date),
            prev2_year_length_over_max = (SELECT COUNT(*)
                                            FROM #prev2_year b
                                            WHERE a.ihds_member_id = b.ihds_member_id
                                                AND b.length_of_break_in_cov_in_year > @liMaxAllowedDayDiff)+
										(case	when	(SELECT COUNT(*)
															FROM #dw_hedis_member_elig elig
															WHERE a.ihds_member_id = elig.ihds_member_id
																AND @lcprev2YrEndDate BETWEEN elig.eff_date and elig.term_date)
														= 0
												then	case	when	datediff(	dd,
																					(select	max(term_date)
																					from	#dw_hedis_member_elig elig
																					WHERE	a.ihds_member_id = elig.ihds_member_id
																							AND elig.term_date between @lcprev2YrStDate and @lcprev2YrEndDate),
																					CONVERT(DATETIME,@lcprev2YrEndDate))>@liMaxAllowedDayDiff
																then	1
																else	0
														end
												else	0
										 end),
            prev2_year_eff_first = (SELECT COUNT(*)
                                            FROM #dw_hedis_member_elig elig
                                            WHERE a.ihds_member_id = elig.ihds_member_id
                                                AND @lcprev2YrStDate BETWEEN elig.eff_date and elig.term_date
                                        ),
            prev2_year_elig_on_max_bic_day = (SELECT COUNT(*)
                                            FROM #dw_hedis_member_elig elig
                                            WHERE a.ihds_member_id = elig.ihds_member_id
                                                AND CONVERT(VARCHAR(8),CONVERT(DATETIME,@lcprev2YrStDate)+@liMaxAllowedDayDiff,112)
                                                    BETWEEN elig.eff_date and elig.term_date
                                    ),
            prev2_year_elig_on_min_bic_day = (SELECT COUNT(*)
                                            FROM #dw_hedis_member_elig elig
                                            WHERE a.ihds_member_id = elig.ihds_member_id
                                                AND CONVERT(VARCHAR(8),CONVERT(DATETIME,@lcprev2YrEndDate)-@liMaxAllowedDayDiff,112)
                                                    BETWEEN elig.eff_date and elig.term_date
                                    ),
            prev2_year_end = (SELECT COUNT(*)
                                            FROM #dw_hedis_member_elig elig
                                            WHERE a.ihds_member_id = elig.ihds_member_id
                                                AND @lcprev2YrEndDate BETWEEN elig.eff_date and elig.term_date
                                    ),
            hedis_eligibility_flag = 0
        INTO #prev2_year_ext1
        FROM #MbrList a

        UPDATE #prev2_year_ext1
        SET hedis_eligibility_flag = CASE 
										WHEN b.ihds_member_id is null
										then 0
										WHEN ((prev2_Year_break_in_coverage_count <= 1
                                                    AND prev2_year_length_over_max = 0)
                                                OR (prev2_Year_break_in_coverage_count = 0
                                                    AND prev2_year_elig_on_max_bic_day = 1
                                                    AND prev2_year_end = 1)
                                                OR (prev2_Year_break_in_coverage_count = 0
                                                    AND prev2_year_elig_on_min_bic_day = 1
                                                    AND prev2_year_eff_first = 1))
                                        THEN 1 
                                        ELSE 0  
                                        END
		from #prev2_year_ext1 a 
				left join #prev2_year b  on
					a.ihds_member_id = b.ihds_member_id

END

IF object_id('tempdb..#res') IS NOT NULL
    DROP TABLE #res

CREATE TABLE #res (ihds_member_id INT, hedis_eligibility_flag int)

IF @liPrevYearFlag = 0
    AND @liPrev2YearFlag = 0


    INSERT INTO #res
    SELECT a.ihds_member_id,
            a.hedis_eligibility_flag
        FROM #current_year_ext1 a

ELSE
    IF @liPrev2YearFlag = 0
        INSERT INTO #res
        SELECT a.ihds_member_id,
                hedis_eligibility_flag = CASE WHEN a.hedis_eligibility_flag = 1
                                                AND b.hedis_eligibility_flag = 1
                                            THEN 1
                                            ELSE 0
                                            END
            FROM #current_year_ext1 a
                INNER JOIN #prev_year_ext1 b
                    ON a.ihds_member_id = b.ihds_member_id
    ELSE 
        INSERT INTO #res
        SELECT a.ihds_member_id,
                hedis_eligibility_flag = CASE WHEN a.hedis_eligibility_flag = 1
                                                AND b.hedis_eligibility_flag = 1
                                                AND c.hedis_eligibility_flag = 1
                                            THEN 1
                                            ELSE 0
                                            END
            FROM #current_year_ext1 a
                INNER JOIN #prev_year_ext1 b
                    ON a.ihds_member_id = b.ihds_member_id
                INNER JOIN #prev2_year_ext1 c
                    ON a.ihds_member_id = c.ihds_member_id



--select * from #current_year_ext1 where ihds_member_id = '3045720'
--select * from #current_year_ext1 where ihds_member_id = '8385'
--select * from #prev2_year_ext1 where ihds_member_id = '642601'


--select * from #res where ihds_member_id = '3045720'

SELECT	ihds_member_id, 
		hedis_eligibility_flag
    FROM #res

--SELECT COUNT(*) mbr_cnt,
--    SUM(hedis_eligibility_flag)
--    FROM #res

/*




IF OBJECT_ID('tempdb..#prev_year1') IS NOT NULL
    DROP TABLE #prev_year1

SELECT a.*,
        break_in_coverage_count = CASE WHEN prev_day_diff <> 0 THEN 1 ELSE 0 END,
        length_of_break_in_cov_in_year = CASE WHEN prev_day_diff = 0 THEN 0
                                    WHEN prev_term_date >= @lcPrevYearStartDate THEN prev_day_diff
                                    ELSE DATEDIFF(dd,@lcPrevYearStartDate,eff_date)
                                    END
    INTO #prev_year1
    FROM utb_hedis_cont_enroll a
    WHERE service_char_full_date BETWEEN @lcPrevYearStartDate and @lcPrevYearEndDate
        AND a.age_in_yr BETWEEN 52.0 and 69.9
        AND a.sex = 'F'
    ORDER BY a.ihds_member_id, a.service_char_full_date


SELECT *,
        current_year_break_in_coverage_count = (SELECT COUNT(*)
                                                FROM #current_year b
                                                WHERE a.ihds_member_id = b.ihds_member_id
													AND b.break_in_coverage_count > 0),
        current_year_length_over_45 = (SELECT COUNT(*)
                                        FROM #current_year b
                                        WHERE a.ihds_member_id = b.ihds_member_id
                                            AND b.length_of_break_in_cov_in_year > 45),
        current_year_eff_first = (SELECT COUNT(*)
                                        FROM dw_hedis_member_elig elig
                                        WHERE a.ihds_member_id = elig.ihds_member_id
                                            AND @lcCurYrStDate BETWEEN elig.eff_date and elig.term_date
                                    ),
        Current_year_day45 = (SELECT COUNT(*)
                                        FROM dw_hedis_member_elig elig
                                        WHERE a.ihds_member_id = elig.ihds_member_id
                                            AND CONVERT(VARCHAR(8),CONVERT(DATETIME,@lcCurYrStDate)+45,112) BETWEEN elig.eff_date and elig.term_date
                                ),
        Current_year_end = (SELECT COUNT(*)
                                        FROM dw_hedis_member_elig elig
                                        WHERE a.ihds_member_id = elig.ihds_member_id
                                            AND @lcCurYrEndDate BETWEEN elig.eff_date and elig.term_date
                                ),
        prev_year1_break_in_coverage_count = (SELECT COUNT(*)
                                                FROM #prev_year1 b
                                                WHERE a.ihds_member_id = b.ihds_member_id
                                                    AND b.break_in_coverage_count > 0),
        prev_year1_length_over_45 = (SELECT COUNT(*)
                                        FROM #prev_year1 b
                                        WHERE a.ihds_member_id = b.ihds_member_id
                                            AND b.length_of_break_in_cov_in_year > 45),
        prev_year1_eff_first = (SELECT COUNT(*)
                                        FROM dw_hedis_member_elig elig
                                        WHERE a.ihds_member_id = elig.ihds_member_id
                                            AND @lcPrevYearStartDate  BETWEEN elig.eff_date and elig.term_date
                                    ),
        prev_year1_day45 = (SELECT COUNT(*)
                                        FROM dw_hedis_member_elig elig
                                        WHERE a.ihds_member_id = elig.ihds_member_id
                                            AND CONVERT(VARCHAR(8),CONVERT(DATETIME,@lcPrevYearStartDate)+45,112) 
                                                BETWEEN elig.eff_date and elig.term_date
                                    ),
        prev_year1_end = (SELECT COUNT(*)
                                        FROM dw_hedis_member_elig elig
                                        WHERE a.ihds_member_id = elig.ihds_member_id
                                            AND @lcPrevYearEndDate  BETWEEN elig.eff_date and elig.term_date
                                    )
    INTO #pass1
    FROM #current_year a
    WHERE service_char_full_date = LEFT(@lcCurYrEndDate,6)+ '01'

select a.*,
        exclusion_flag = CASE WHEN b.ihds_member_id IS NULL THEN 0 ELSE 1 END,
        bcs_hedis_eligibility_flag = CASE WHEN ((current_Year_break_in_coverage_count <= 1
                                                AND current_year_length_over_45 = 0
                                                AND current_year_eff_first = 1
                                                AND current_year_end = 1)
                                            OR (current_Year_break_in_coverage_count = 0
                                                AND current_year_day45 = 1
                                                AND current_year_end = 1))
                                        AND ((prev_year1_break_in_coverage_count <= 1
                                                AND prev_year1_length_over_45 = 0
                                                AND prev_year1_eff_first = 1
                                                AND prev_year1_end = 1)
                                            OR (prev_year1_break_in_coverage_count = 0
                                                AND prev_year1_day45 = 1
                                                AND prev_year1_end = 1))
                                       THEN 1
                                    ELSE 0
                                    END
    INTO #bcs_den
    from #pass1 a
        LEFT JOIN (SELECT DISTINCT ihds_member_id
                    FROM #bcs_excl) b
            ON a.ihds_member_id = b.ihds_member_id
*/







GO
