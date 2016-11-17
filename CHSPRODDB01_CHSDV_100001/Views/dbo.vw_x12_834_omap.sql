SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vw_x12_834_omap]
AS  SELECT DISTINCT TOP 100 percent
            dbo.x12_834_benefit_enrollment.x12_834_benefit_enrollment_id,
            dbo.x12_834_benefit_enrollment.x12_transaction_id,
            dbo.x12_transaction.x12_transaction_uid,
            dbo.x12_functional_group.x12_functional_group_id,
            dbo.x12_functional_group.x12_interchange_id,
            dbo.x12_interchange_status.x12_interchange_status_id,
            dbo.x12_interchange_status.x12_interchange_status_ud,
            dbo.x12_834_benefit_enrollment.L2000_ref02_subscriber_id AS member_number,
            ISNULL(dbo.x12_834_benefit_enrollment.L2100A_nm103_subscriber_last_nm,
                   '') + ', '
            + ISNULL(dbo.x12_834_benefit_enrollment.L2100A_nm104_subscriber_first_nm,
                     '') + ' '
            + ISNULL(dbo.x12_834_benefit_enrollment.L2100A_nm105_subscriber_middle_nm,
                     '') AS full_name,
            dbo.x12_834_benefit_enrollment.L2100A_nm104_subscriber_first_nm as first_name,
            dbo.x12_834_benefit_enrollment.L2100A_nm103_subscriber_last_nm as last_name,
            dbo.x12_834_benefit_enrollment.L2100A_nm105_subscriber_middle_nm as middle_name,
            CASE WHEN L2100G_nm103_resp_party_last_nm = L2100G_nm104_resp_party_first_nm
                 THEN L2100G_nm103_resp_party_last_nm
                 WHEN L2100G_nm103_resp_party_last_nm = 'UNKNOWN' THEN NULL
                 ELSE case when (IsNull(L2100G_nm103_resp_party_last_nm, '')
                                 + ', '
                                 + IsNull(L2100G_nm104_resp_party_first_nm, '')
                                 + ' '
                                 + IsNull(L2100G_nm105_resp_party_middle_nm,
                                          '')) = ',  ' then null
                           else IsNull(L2100G_nm103_resp_party_last_nm, '')
                                + ', '
                                + IsNull(L2100G_nm104_resp_party_first_nm, '')
                                + ' '
                                + IsNull(L2100G_nm105_resp_party_middle_nm, '')
                      end
            END AS contact,
            dbo.x12_834_benefit_enrollment.L2100A_n301_subscriber_address1 AS address1,
            dbo.x12_834_benefit_enrollment.L2100A_n401_subscriber_city AS city,
            dbo.x12_834_benefit_enrollment.L2100A_n402_subscriber_state AS state,
            dbo.x12_834_benefit_enrollment.L2100A_n403_subscriber_zip AS zipcode,
            SUBSTRING(dbo.x12_834_benefit_enrollment.L2300_hd04_plan_cvg_desc,
                      30, 3) AS county,
            dbo.x12_834_benefit_enrollment.L2100A_dmg02_member_dob AS dob,
            dbo.x12_834_benefit_enrollment.L2100A_dmg03_member_gender AS sex, -- left in for backwards compatibility
            dbo.x12_834_benefit_enrollment.L2100A_dmg03_member_gender AS gender,
            dbo.x12_834_benefit_enrollment.L2100A_nm109_subscriber_id AS ssn,
            LEFT(dbo.x12_834_benefit_enrollment.L2100A_per104_member_comm, 3) AS area_code,
            SUBSTRING(dbo.x12_834_benefit_enrollment.L2100A_per104_member_comm,
                      4,
                      LEN(dbo.x12_834_benefit_enrollment.L2100A_per104_member_comm)
                      - 3) AS phone,
            COALESCE(dbo.x12_834_benefit_enrollment.L2300_dtp03_348_cvg_period,
                     dbo.x12_834_benefit_enrollment.L2000_dtp03_356_status_info_eff_date) AS eff_date,
            CASE L2000_ins03_maint_type_code
              WHEN '030' THEN IsNull(NULL, NULL)
              WHEN '021' THEN IsNull(NULL, NULL)
              ELSE COALESCE(L2000_dtp03_357_status_info_eff_date,
                            L2300_dtp03_349_cvg_period)
            END AS term_date,
            case when SUBSTRING(dbo.x12_834_benefit_enrollment.L2300_hd04_plan_cvg_desc,
                                26, 4) = '' then null
                 else SUBSTRING(dbo.x12_834_benefit_enrollment.L2300_hd04_plan_cvg_desc,
                                26, 4)
            end as branch_id,
            case when SUBSTRING(dbo.x12_834_benefit_enrollment.L2300_hd04_plan_cvg_desc,
                                33, 3) = '' then null
                 else SUBSTRING(dbo.x12_834_benefit_enrollment.L2300_hd04_plan_cvg_desc,
                                33, 3)
            end as worker_id,
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
              ELSE ISNULL(L2000_ins04_maint_reason_code, null)
            END AS reason,
            CASE L2000_ins03_maint_type_code + '-'
              + ISNULL(L2300_hd01_maint_type_code, '024')
              WHEN '001-024'
              THEN (CASE WHEN L2300_dtp03_349_cvg_period IS NOT NULL THEN 'T'
                         ELSE 'C'
                    END)
              WHEN '001-021' THEN 'N'
              WHEN '021-021' THEN 'N'
              WHEN '024-024' THEN 'C'
              WHEN '030-030' THEN 'O'
              when '001-001' then 'O'
            END AS [status],
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
            END AS [language],
            dbo.x12_834_benefit_enrollment.L2300_ref02_17_insured_grp_policy_num AS perc,
--    case when SUBSTRING(dbo.x12_834_benefit_enrollment.L2300_hd04_plan_cvg_desc, 46, 3) = '' then null
--		 else SUBSTRING(dbo.x12_834_benefit_enrollment.L2300_hd04_plan_cvg_desc, 46, 3) end AS cob,
            case L2000_ins06_medicare_plan_code
              when 'A' then 'MA'
              when 'B' then 'MB'
              when 'C' then 'MAB'
              when 'D' then 'MD'
              when 'E' then null
              else 'XX'
            end as cob,
            dbo.x12_834_benefit_enrollment.L2000_ref02_F6_subscriber_sup_id AS cob_id,
            SUBSTRING(dbo.x12_834_benefit_enrollment.L2300_hd04_plan_cvg_desc,
                      37, 1) AS rate_group,
            CASE L2100A_dmg05_member_ethnicity
              WHEN 'O' THEN 'W'
              when 'C' then 'W'
              WHEN '7' THEN 'U'
              WHEN 'E' THEN 'O'
              ELSE L2100A_dmg05_member_ethnicity
            END AS race,
            SUBSTRING(dbo.x12_834_benefit_enrollment.L2300_hd04_plan_cvg_desc,
                      38, 3) AS benefit_pkg,
            dbo.x12_834_benefit_enrollment.L2000_ref02_insured_grp_policy_num AS plan_number,
            CAST(SUBSTRING(dbo.x12_interchange.isa09_interchange_date, 3, 2)
            + '/' + RIGHT(dbo.x12_interchange.isa09_interchange_date, 2) + '/'
            + LEFT(dbo.x12_interchange.isa09_interchange_date, 2) AS datetime) AS interchange_date,
            dbo.x12_interchange.isa13_control_no,
            CASE WHEN dbo.x12_834_benefit_enrollment.L2320_1_cob02_insured_grp_policy_num LIKE 'M%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_1_cob02_insured_grp_policy_num
                 WHEN dbo.x12_834_benefit_enrollment.L2320_2_cob02_insured_grp_policy_num LIKE 'M%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_2_cob02_insured_grp_policy_num
                 WHEN dbo.x12_834_benefit_enrollment.L2320_3_cob02_insured_grp_policy_num LIKE 'M%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_3_cob02_insured_grp_policy_num
                 WHEN dbo.x12_834_benefit_enrollment.L2320_4_cob02_insured_grp_policy_num LIKE 'M%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_4_cob02_insured_grp_policy_num
                 WHEN dbo.x12_834_benefit_enrollment.L2320_5_cob02_insured_grp_policy_num LIKE 'M%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_5_cob02_insured_grp_policy_num
                 ELSE NULL
            end as php_mental,
            CASE WHEN dbo.x12_834_benefit_enrollment.L2320_1_cob02_insured_grp_policy_num LIKE 'H%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_1_cob02_insured_grp_policy_num
                 WHEN dbo.x12_834_benefit_enrollment.L2320_2_cob02_insured_grp_policy_num LIKE 'H%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_2_cob02_insured_grp_policy_num
                 WHEN dbo.x12_834_benefit_enrollment.L2320_3_cob02_insured_grp_policy_num LIKE 'H%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_3_cob02_insured_grp_policy_num
                 WHEN dbo.x12_834_benefit_enrollment.L2320_4_cob02_insured_grp_policy_num LIKE 'H%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_4_cob02_insured_grp_policy_num
                 WHEN dbo.x12_834_benefit_enrollment.L2320_5_cob02_insured_grp_policy_num LIKE 'H%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_5_cob02_insured_grp_policy_num
                 ELSE NULL
            end as php_medical,
            CASE WHEN dbo.x12_834_benefit_enrollment.L2320_1_cob02_insured_grp_policy_num LIKE 'D%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_1_cob02_insured_grp_policy_num
                 WHEN dbo.x12_834_benefit_enrollment.L2320_2_cob02_insured_grp_policy_num LIKE 'D%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_2_cob02_insured_grp_policy_num
                 WHEN dbo.x12_834_benefit_enrollment.L2320_3_cob02_insured_grp_policy_num LIKE 'D%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_3_cob02_insured_grp_policy_num
                 WHEN dbo.x12_834_benefit_enrollment.L2320_4_cob02_insured_grp_policy_num LIKE 'D%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_4_cob02_insured_grp_policy_num
                 WHEN dbo.x12_834_benefit_enrollment.L2320_5_cob02_insured_grp_policy_num LIKE 'D%'
                 THEN dbo.x12_834_benefit_enrollment.L2320_5_cob02_insured_grp_policy_num
                 ELSE null
            end as php_dental,
            CASE 
				WHEN dbo.x12_834_benefit_enrollment.L2320_1_cob02_insured_grp_policy_num LIKE 'b%' 
				THEN dbo.x12_834_benefit_enrollment.L2320_1_cob02_insured_grp_policy_num
				WHEN dbo.x12_834_benefit_enrollment.L2320_2_cob02_insured_grp_policy_num LIKE 'b%' 
				THEN dbo.x12_834_benefit_enrollment.L2320_2_cob02_insured_grp_policy_num		
				WHEN dbo.x12_834_benefit_enrollment.L2320_3_cob02_insured_grp_policy_num LIKE 'b%' 
				THEN dbo.x12_834_benefit_enrollment.L2320_3_cob02_insured_grp_policy_num
				WHEN dbo.x12_834_benefit_enrollment.L2320_4_cob02_insured_grp_policy_num LIKE 'b%' 
				THEN dbo.x12_834_benefit_enrollment.L2320_4_cob02_insured_grp_policy_num
				WHEN dbo.x12_834_benefit_enrollment.L2320_5_cob02_insured_grp_policy_num LIKE 'b%' 
				THEN dbo.x12_834_benefit_enrollment.L2320_5_cob02_insured_grp_policy_num
				ELSE NULL 
		    END AS php_cdo,
		    CASE 
				WHEN dbo.x12_834_benefit_enrollment.L2320_1_cob02_insured_grp_policy_num LIKE 'p%' 
				THEN dbo.x12_834_benefit_enrollment.L2320_1_cob02_insured_grp_policy_num
				WHEN dbo.x12_834_benefit_enrollment.L2320_2_cob02_insured_grp_policy_num LIKE 'p%' 
				THEN dbo.x12_834_benefit_enrollment.L2320_2_cob02_insured_grp_policy_num		
				WHEN dbo.x12_834_benefit_enrollment.L2320_3_cob02_insured_grp_policy_num LIKE 'p%' 
				THEN dbo.x12_834_benefit_enrollment.L2320_3_cob02_insured_grp_policy_num
				WHEN dbo.x12_834_benefit_enrollment.L2320_4_cob02_insured_grp_policy_num LIKE 'p%' 
				THEN dbo.x12_834_benefit_enrollment.L2320_4_cob02_insured_grp_policy_num
				WHEN dbo.x12_834_benefit_enrollment.L2320_5_cob02_insured_grp_policy_num LIKE 'p%' 
				THEN dbo.x12_834_benefit_enrollment.L2320_5_cob02_insured_grp_policy_num
			    ELSE NULL 
		    END AS php_pco,	
            Substring(L2300_hd04_plan_cvg_desc, 10, 6) AS previous_elig_end_date,
            dbo.x12_834_benefit_enrollment.L2320_1_cob02_insured_grp_policy_num,
            dbo.x12_834_benefit_enrollment.L2320_2_cob02_insured_grp_policy_num,
            dbo.x12_834_benefit_enrollment.L2320_3_cob02_insured_grp_policy_num,
            dbo.x12_834_benefit_enrollment.L2320_4_cob02_insured_grp_policy_num,
            dbo.x12_834_benefit_enrollment.L2320_5_cob02_insured_grp_policy_num,
            Substring(L2300_hd04_plan_cvg_desc, 18, 8) AS pregnancy_due_date, 
            Substring(L2300_hd04_plan_cvg_desc, 16, 2) AS alt_language_format
    FROM    dbo.x12_834_benefit_enrollment
    INNER JOIN dbo.x12_transaction
    ON      dbo.x12_834_benefit_enrollment.x12_transaction_id = dbo.x12_transaction.x12_transaction_id
    INNER JOIN dbo.x12_functional_group
    ON      dbo.x12_transaction.x12_functional_group_id = dbo.x12_functional_group.x12_functional_group_id
    INNER JOIN dbo.x12_interchange
    ON      dbo.x12_functional_group.x12_interchange_id = dbo.x12_interchange.x12_interchange_id
    LEFT OUTER JOIN dbo.x12_interchange_status
    ON      dbo.x12_interchange.x12_interchange_status_id = dbo.x12_interchange_status.x12_interchange_status_id
GO
