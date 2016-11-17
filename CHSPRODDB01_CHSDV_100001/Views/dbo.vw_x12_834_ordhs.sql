SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_x12_834_ordhs]
AS  SELECT DISTINCT TOP 100 PERCENT
            dbo.x12_834_benefit_enrollment.x12_834_benefit_enrollment_id,
            dbo.x12_834_benefit_enrollment.x12_transaction_id,
            dbo.x12_functional_group.x12_functional_group_id,
            dbo.x12_functional_group.x12_interchange_id,
            dbo.x12_interchange_status.x12_interchange_status_id,
            dbo.x12_interchange_status.x12_interchange_status_ud,
            dbo.x12_834_benefit_enrollment.L2000_ref02_subscriber_id AS NMBR_PER_PRIM_ID,
            dbo.x12_834_benefit_enrollment.L2100A_nm103_subscriber_last_nm as subscriber_last_nm,
            dbo.x12_834_benefit_enrollment.L2100A_nm104_subscriber_first_nm as subscriber_first_nm,
            dbo.x12_834_benefit_enrollment.L2100A_nm105_subscriber_middle_nm as subscriber_middle_name,
            dbo.x12_834_benefit_enrollment.L2100G_nm103_resp_party_last_nm as contact_last_name,
            dbo.x12_834_benefit_enrollment.L2100G_nm104_resp_party_first_nm as contact_first_name,
            dbo.x12_834_benefit_enrollment.L2100A_n301_subscriber_address1 AS subscriber_address1,
            dbo.x12_834_benefit_enrollment.L2100A_n401_subscriber_city AS subscriber_city,
            dbo.x12_834_benefit_enrollment.L2100A_n402_subscriber_state AS subscriber_state,
            dbo.x12_834_benefit_enrollment.L2100A_n403_subscriber_zip AS subscriber_zipcode,
            SUBSTRING(dbo.x12_834_benefit_enrollment.L2300_hd04_plan_cvg_desc,
                      30, 3) AS county,
            dbo.x12_834_benefit_enrollment.L2100A_dmg02_member_dob AS dob,
            dbo.x12_834_benefit_enrollment.L2100A_dmg03_member_gender AS gender,
            dbo.x12_834_benefit_enrollment.L2100A_nm109_subscriber_id AS SSN,
            SUBSTRING(dbo.x12_834_benefit_enrollment.L2100A_per104_member_comm,
                      4,
                      LEN(dbo.x12_834_benefit_enrollment.L2100A_per104_member_comm) - 3) AS phone,
            LEFT(dbo.x12_834_benefit_enrollment.L2100A_per104_member_comm, 3) AS area_code,
            SUBSTRING(dbo.x12_834_benefit_enrollment.L2300_hd04_plan_cvg_desc,
                      33, 3) AS worker_id,
            CASE L2000_ins04_maint_reason_code
              WHEN 'AI' THEN 'LE'
              WHEN '03' THEN 'DP'
              WHEN '05' THEN 'AD'
              WHEN '07' THEN 'LE'
              WHEN '14' THEN 'EE'
              WHEN '16' THEN 'AC'
              WHEN '18' THEN 'EX'
              WHEN '22' THEN 'TR'
              WHEN 'XN' THEN NULL
              ELSE L2000_ins04_maint_reason_code
            END AS reason,
            CASE L2000_ins03_maint_type_code + '-' + ISNULL(L2300_hd01_maint_type_code,
                                                            '024')
              WHEN '001-024' THEN (CASE WHEN L2300_dtp03_349_cvg_period IS NOT NULL THEN 'T'
                                        ELSE 'C'
                                   END)
              WHEN '001-021' THEN 'NEW'
              WHEN '021-021' THEN 'NEW'
              WHEN '024-024' THEN 'CLOSED'
              WHEN '030-030' THEN 'OPEN' 
		      END AS status,
            CASE L2100A_lui02_language_code
              WHEN 'CHI' THEN 'CT'
              WHEN 'ENG' THEN 'EN'
              WHEN 'GUJ' THEN 'GU'
              WHEN 'HIN' THEN 'HI'
              WHEN 'HMN' THEN 'HM'
              WHEN 'HUN' THEN 'HU'
              WHEN 'ITA' THEN 'IT'
              WHEN 'JPN' THEN 'JA'
              WHEN 'KHM' THEN 'EN'
              WHEN 'KOR' THEN 'KO'
              WHEN 'LAO' THEN 'LA'
              WHEN 'RUM' THEN 'RO'
              WHEN 'RUS' THEN 'RU'
              WHEN 'SGN' THEN 'SI'
              WHEN 'SPA' THEN 'SP'
              WHEN 'SWE' THEN 'SQ'
              WHEN 'VIE' THEN 'VI'
              ELSE 'XX'
            END AS language_code,
            dbo.x12_834_benefit_enrollment.L2300_ref02_17_insured_grp_policy_num AS CODE_RPT_ELIG_PROG,
            dbo.x12_834_benefit_enrollment.L2000_ref02_F6_subscriber_sup_id AS NMBR_CLM_SSA,
            Substring(L2300_hd04_plan_cvg_desc, 1, 1) as FLAG_ENRL_PHP,
            Substring(L2300_hd04_plan_cvg_desc, 2, 8) as AMT_ORIG_ADJUST,
            Substring(L2300_hd04_plan_cvg_desc, 10, 6) as DATE_END_PREV_ENRL_PHP,
            Substring(L2300_hd04_plan_cvg_desc, 16, 2) as CODE_NOTE_FRMT_PRNT_IREG,
            Substring(L2300_hd04_plan_cvg_desc, 18, 8) as DATE_DELV_EXP,
            Substring(L2300_hd04_plan_cvg_desc, 26, 4) as CODE_BR_OFF,
            Substring(L2300_hd04_plan_cvg_desc, 30, 3) as CODE_CNTY_FIPS_RES,
            Substring(L2300_hd04_plan_cvg_desc, 33, 3) as CODE_WKR_ID,
            Substring(L2300_hd04_plan_cvg_desc, 36, 1) as CODE_LVL_SVC_PHP,
            Substring(L2300_hd04_plan_cvg_desc, 37, 1) as CODE_GRP_REQR_PHP_1CHAR,
            Substring(L2300_hd04_plan_cvg_desc, 38, 3) as CODE_PKG_BEN_MEDL,
            Substring(L2300_hd04_plan_cvg_desc, 41, 2) as CODE_PROG_ELIG,
            Substring(L2300_hd04_plan_cvg_desc, 43, 3) as CODE_REAS_LVL_SVC_PHP,
            Substring(L2300_hd04_plan_cvg_desc, 46, 3) as CODE_TYPE_COV_INS_HLTH,
            Substring(L2300_hd04_plan_cvg_desc, 49, 2) as CODE_END_MC_ELIG,
            CASE WHEN Substring(L2300_hd04_plan_cvg_desc, 49, 2) BETWEEN '01' AND '12' THEN Substring(L2300_hd04_plan_cvg_desc, 49, 2) + '/' + LTRIM(RTRIM(STR(Cast(Left(isa09_interchange_date, 2) as int) + 2000)))
                 WHEN Substring(L2300_hd04_plan_cvg_desc, 49, 2) BETWEEN '13' AND '24' THEN LTRIM(RTRIM(STR(CAST(Substring(L2300_hd04_plan_cvg_desc, 49, 2) as int) - 12))) + '/' + LTRIM(RTRIM(STR(CAST(Left(isa09_interchange_date, 2) as int) + 2001)))
     END as DATE_END_MC_ELIG,
            CASE L2100A_dmg05_member_ethnicity
              WHEN 'O' THEN 'W'
              WHEN '7' THEN 'U'
              WHEN 'E' THEN 'O'
              ELSE L2100A_dmg05_member_ethnicity
            END AS ethnicity,
            COALESCE(dbo.x12_834_benefit_enrollment.L2000_dtp03_356_status_info_eff_date,
                     dbo.x12_834_benefit_enrollment.L2300_dtp03_348_cvg_period) AS eff_date,
            CASE L2000_ins03_maint_type_code
              WHEN '030' THEN IsNull(NULL, NULL)
              WHEN '021' THEN IsNull(NULL, NULL)
              ELSE COALESCE(L2000_dtp03_357_status_info_eff_date,
                            L2300_dtp03_349_cvg_period)
            END AS term_date,
            dbo.x12_834_benefit_enrollment.L2000_ref02_insured_grp_policy_num AS plan_number,
            (CAST(SUBSTRING(dbo.x12_interchange.isa09_interchange_date, 3, 2) + ' / ' + RIGHT(dbo.x12_interchange.isa09_interchange_date, 2) + ' / ' + LEFT(dbo.x12_interchange.isa09_interchange_date, 2) as datetime)) as omap_file_date
    FROM    dbo.x12_834_benefit_enrollment 
    INNER JOIN dbo.x12_transaction
            ON dbo.x12_834_benefit_enrollment.x12_transaction_id = dbo.x12_transaction.x12_transaction_id 
    INNER JOIN dbo.x12_functional_group
            ON dbo.x12_transaction.x12_functional_group_id = dbo.x12_functional_group.x12_functional_group_id 
    INNER JOIN x12_interchange
            ON x12_functional_group.x12_interchange_id = x12_interchange.x12_interchange_id
    LEFT JOIN dbo.x12_interchange_status
            ON dbo.x12_interchange.x12_interchange_status_id = dbo.x12_interchange_status.x12_interchange_status_id
    ORDER BY
            status,
            dbo.x12_834_benefit_enrollment.x12_834_benefit_enrollment_id

GO
