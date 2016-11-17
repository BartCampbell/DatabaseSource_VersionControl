SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vw_x12_837d_nsf]
AS  SELECT TOP 100 PERCENT
            'D' AS claim_type_ud,
            dbo.x12_interchange.x12_interchange_id,
            dbo.x12_functional_group.x12_functional_group_id,
            dbo.x12_837_claim_dental.x12_837_claim_dental_id,
            dbo.x12_transaction.x12_transaction_id,
            dbo.x12_transaction.st01_transaction_id_code,
            dbo.x12_transaction.st02_transaction_control_no,
            dbo.x12_functional_group.gs01_functional_id_code,
            dbo.x12_functional_group.gs02_app_sender_code,
            dbo.x12_functional_group.gs03_app_receiver_code,
            dbo.x12_functional_group.gs04_date,
            dbo.x12_functional_group.gs05_time,
            dbo.x12_functional_group.gs06_group_control_no,
            dbo.x12_functional_group.gs07_resp_agency_code,
            dbo.x12_functional_group.gs08_version_id_code,
            dbo.x12_interchange.isa01_auth_info_qual,
            dbo.x12_interchange.isa02_auth_info,
            dbo.x12_interchange.isa03_security_info_qual,
            dbo.x12_interchange.isa04_security_info,
            dbo.x12_interchange.isa05_sender_id_qual,
            dbo.x12_interchange.isa06_sender_id,
            dbo.x12_interchange.isa07_receiver_id_qual,
            dbo.x12_interchange.isa08_receiver_id,
            dbo.x12_interchange.isa09_interchange_date,
            dbo.x12_interchange.isa10_interchange_time,
            dbo.x12_interchange.isa11_control_standards_id,
            dbo.x12_interchange.isa12_control_version_no,
            dbo.x12_interchange.isa13_control_no,
            dbo.x12_interchange.isa14_ack_requested,
            dbo.x12_interchange.processed,
            dbo.x12_interchange.incoming,
            CASE dbo.x12_interchange.isa15_usage_indicator
              WHEN 'T' THEN 'TEST'
              ELSE 'PROD'
            END AS AA0_TEST_PRODUCTION,
            dbo.x12_837_claim_dental.L1000A_nm103_submitter_last_nm AS AA0_SUBMITTER_NAME,
            dbo.x12_837_claim_dental.L1000A_nm109_submitter_id AS AA0_SUBMITTER_ID,
            ISNULL(dbo.x12_837_claim_dental.L2010AA_nm109_billing_prov_id, '')
            + '-'
            + ISNULL(COALESCE(dbo.x12_837_claim_dental.L2010AA_ref02_1C_billing_prov_id,
                              dbo.x12_837_claim_dental.L2010AA_ref02_1D_billing_prov_id),
                     '') AS BA0_EMC_PROVIDER_ID,
            dbo.x12_837_claim_dental.L2010AA_nm103_billing_prov_last_nm AS BA0_ORGANIZATION_NM,
            dbo.x12_837_claim_dental.L2010BA_nm103_subscriber_last_nm AS CA0_LAST_NAME,
            dbo.x12_837_claim_dental.L2010BA_nm104_subscriber_first_nm AS CA0_FIRST_NAME,
            dbo.x12_837_claim_dental.L2010BA_nm105_subscriber_middle_nm AS CA0_MIDDLE_NAME,
            dbo.x12_837_claim_dental.L2300_clm01_pt_acct_num AS CA0_PTCONTROL_NUM,
            dbo.x12_837_claim_dental.L2010BB_nm103_payer_nm AS DA0_PAYER_NAME,
            dbo.x12_837_claim_dental.L2010BB_nm109_payer_id AS DA0_PAYER_ORG_ID,
            dbo.x12_837_claim_dental.L2010BA_nm109_subscriber_id AS DA0_INSUREDID_NUM,
            CAST(NULL AS VARCHAR(6)) AS EA0_DX1,
            CAST(NULL AS VARCHAR(6)) AS EA0_DX2,
            CAST(NULL AS VARCHAR(6)) AS EA0_DX3,
            CAST(NULL AS VARCHAR(6)) AS EA0_DX4,
            ISNULL(dbo.x12_837_claim_dental.L2420A_nm109_rendering_prov_id
                   + '-'
                   + ISNULL(COALESCE(dbo.x12_837_claim_dental.L2420A_ref02_1C_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2420A_ref02_1D_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2420A_ref02_1E_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2420A_ref02_EI_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2420A_ref02_SY_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2420A_ref02_TJ_rendering_prov_id),
                            ''),
                   dbo.x12_837_claim_dental.L2310B_nm109_rendering_prov_id
                   + '-'
                   + ISNULL(COALESCE(dbo.x12_837_claim_dental.L2310B_ref02_1C_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2310B_ref02_1D_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2310B_ref02_1E_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2310B_ref02_EI_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2310B_ref02_SY_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2310B_ref02_TJ_rendering_prov_id),
                            '')) AS FA0_RENDERING_PROV_ID,
            dbo.x12_837_claim_dental.L2310B_nm103_rendering_prov_last_nm AS FB1_PROV_LAST_NAME,
            dbo.x12_837_claim_dental.L2310B_nm104_rendering_prov_first_nm AS FB1_PROV_FIRST_NAME,
            dbo.x12_837_claim_dental.L2310B_nm105_rendering_prov_middle_nm AS FB1_PROV_MIDDLE_NAME,
            REPLICATE('0',
                      2
                      - LEN(LTRIM(RTRIM(dbo.x12_837_claim_dental.L2400_lx01_assigned_num))))
            + LTRIM(RTRIM(dbo.x12_837_claim_dental.L2400_lx01_assigned_num)) AS FA0_SEQ_NUM,
            dbo.x12_837_claim_dental.L2400_sv301_proc_code AS FA0_HCPCS_PROC,
            dbo.x12_837_claim_dental.L2400_sv301_proc_mod1 AS FA0_HCPCS_MOD1,
            dbo.x12_837_claim_dental.L2400_sv301_proc_mod2 AS FA0_HCPCS_MOD2,
            dbo.x12_837_claim_dental.L2400_sv301_proc_mod3 AS FA0_HCPCS_MOD3,
            dbo.x12_837_claim_dental.L2400_sv301_proc_mod4 AS FA0_HCPCS_MOD4,
            dbo.x12_837_claim_dental.L2400_sv302_line_charge AS FA0_LINE_CHGS,
            ISNULL(dbo.x12_837_claim_dental.L2400_sv303_facility_type_code,
                   dbo.x12_837_claim_dental.L2300_clm05_facility_type_code) AS FA0_POS, --dbo.x12_837_claim_dental.L2400_sv107_dx_pointer1 AS FA0_DX_SEQ1, 
                      --dbo.x12_837_claim_dental.L2400_sv107_dx_pointer2 AS FA0_DX_SEQ2, 
                      --dbo.x12_837_claim_dental.L2400_sv107_dx_pointer3 AS FA0_DX_SEQ3, 
                      --dbo.x12_837_claim_dental.L2400_sv107_dx_pointer4 AS FA0_DX_SEQ4, 
            REPLACE(dbo.x12_837_claim_dental.L2400_sv304_oral_cavity_designation_code_1
                    + COALESCE(','
                               + dbo.x12_837_claim_dental.L2400_sv304_oral_cavity_designation_code_2,
                               '') + COALESCE(','
                                              + dbo.x12_837_claim_dental.L2400_sv304_oral_cavity_designation_code_3,
                                              '') + COALESCE(','
                                                             + dbo.x12_837_claim_dental.L2400_sv304_oral_cavity_designation_code_4,
                                                             '')
                    + COALESCE(','
                               + dbo.x12_837_claim_dental.L2400_sv304_oral_cavity_designation_code_5,
                               ''), ' ', '') as oral_cavity_code_list,
            dbo.x12_837_claim_dental.L2400_sv305_prosthesis_crown_inlay_code AS prosthesis_code,
            dbo.x12_837_claim_dental.L2400_sv306_procedure_count AS FA0_UNITS,
            REPLACE(coalesce(dbo.x12_837_claim_dental.L2400_1_too02_JP_tooth_code
                             + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_1_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_1_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_1_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_1_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_1_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_2_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_2_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_2_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_2_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_2_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_2_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_3_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_3_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_3_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_3_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_3_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_3_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_4_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_4_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_4_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_4_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_4_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_4_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_5_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_5_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_5_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_5_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_5_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_5_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_6_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_6_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_6_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_6_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_6_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_6_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_7_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_7_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_7_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_7_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_7_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_7_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_8_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_8_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_8_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_8_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_8_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_8_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_9_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_9_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_9_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_9_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_9_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_9_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_10_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_10_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_10_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_10_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_10_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_10_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_11_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_11_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_11_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_11_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_11_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_11_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_12_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_12_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_12_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_12_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_12_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_12_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_13_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_13_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_13_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_13_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_13_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_13_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_14_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_14_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_14_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_14_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_14_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_14_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_15_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_15_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_15_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_15_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_15_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_15_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_16_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_16_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_16_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_16_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_16_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_16_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_17_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_17_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_17_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_17_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_17_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_17_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_18_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_18_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_18_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_18_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_18_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_18_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_19_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_19_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_19_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_19_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_19_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_19_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_20_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_20_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_20_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_20_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_20_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_20_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_21_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_21_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_21_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_21_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_21_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_21_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_22_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_22_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_22_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_22_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_22_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_22_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_23_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_23_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_23_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_23_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_23_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_23_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_24_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_24_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_24_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_24_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_24_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_24_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_25_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_25_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_25_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_25_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_25_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_25_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_26_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_26_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_26_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_26_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_26_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_26_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_27_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_27_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_27_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_27_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_27_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_27_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_28_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_28_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_28_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_28_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_28_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_28_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_29_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_29_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_29_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_29_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_29_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_29_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_30_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_30_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_30_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_30_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_30_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_30_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_31_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_31_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_31_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_31_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_31_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_31_too03_tooth_surface_code_5,
                               '') + coalesce(','
                                              + dbo.x12_837_claim_dental.L2400_32_too02_JP_tooth_code
                                              + '-', '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_32_too03_tooth_surface_code_1,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_32_too03_tooth_surface_code_2,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_32_too03_tooth_surface_code_3,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_32_too03_tooth_surface_code_4,
                               '')
                    + coalesce(dbo.x12_837_claim_dental.L2400_32_too03_tooth_surface_code_5,
                               ''), ' ', '') AS claim_proc_tooth_surface_list,
            COALESCE(dbo.x12_837_claim_dental.L2400_dtp02_472_service_date,
                     dbo.x12_837_claim_dental.L2300_dtp03_472_service_date) AS FA0_FROM_SVC_DT,
            COALESCE(dbo.x12_837_claim_dental.L2400_dtp02_472_service_date,
                     dbo.x12_837_claim_dental.L2300_dtp03_472_service_date) AS FA0_TO_SVC_DATE,
            STR(dbo.x12_837_claim_dental.L2300_clm02_total_claim_chg_amt) AS XA0_TOTAL_CLAIM_CHGS,
            dbo.x12_837_claim_dental.L2430_svd02_service_line_paid AS FA0_COB,
            dbo.x12_837_claim_dental.L2430_svd02_service_line_paid AS DA1_PAYER_AMT_PD, -- added 1/21/2008
            CASE dbo.x12_837_claim_dental.L2430_cas01_adjustment_group_code
              WHEN 'PR'
              THEN IsNull(dbo.x12_837_claim_dental.L2430_cas03_adjustment_amt,
                          0)
                   + IsNull(dbo.x12_837_claim_dental.L2430_cas06_adjustment_amt,
                            0)
                   + IsNull(dbo.x12_837_claim_dental.L2430_cas09_adjustment_amt,
                            0)
              ELSE NULL
            END AS FA0_PATIENT_RESPONSIBILITY,
            dbo.x12_interchange.created_date AS DateLastModified,
            dbo.x12_interchange.created_date AS received_date,
            '' AS Mode,
            'ISA-' + dbo.x12_interchange.isa13_control_no + ' GS-'
            + dbo.x12_functional_group.gs06_group_control_no + ' ST-'
            + dbo.x12_transaction.st02_transaction_control_no AS FauxName,
            dbo.x12_transaction.se01_num_transaction_segments * 100 AS [Size],
            'file' AS Type,
            dbo.x12_interchange.x12_interchange_uid AS Name,
            dbo.x12_interchange.filename,
            dbo.x12_interchange.archive_filename,
            dbo.x12_interchange_status.x12_interchange_status_ud,
            dbo.x12_interchange_status.x12_interchange_status_nm,
            dbo.x12_transaction_schema.x12_transaction_schema_ud,
            dbo.x12_837_claim_dental.L2400_ref02_6R_line_item_control_num AS FA0_LINE_ITEM_CONTROL_NO,
            COALESCE(dbo.x12_837_claim_dental.L2420A_prv03_taxonomy_code,
                     dbo.x12_837_claim_dental.L2310B_prv03_taxonomy_code,
                     dbo.x12_837_claim_dental.L2000A_prv03_taxonomy_code) AS rendering_taxonomy_code,
            coalesce(dbo.x12_837_claim_dental.L2300_1_dn201_tooth_number + '-',
                     '')
            + coalesce(dbo.x12_837_claim_dental.L2300_1_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_2_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_2_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_3_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_3_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_4_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_4_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_5_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_5_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_6_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_6_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_7_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_7_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_8_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_8_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_9_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_9_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_10_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_10_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_11_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_11_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_12_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_12_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_13_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_13_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_14_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_14_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_15_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_15_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_16_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_16_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_17_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_17_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_18_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_18_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_19_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_19_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_20_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_20_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_21_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_21_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_22_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_22_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_23_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_23_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_24_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_24_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_25_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_25_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_26_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_26_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_27_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_27_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_28_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_28_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_29_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_29_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_30_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_30_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_31_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_31_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_32_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_32_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_33_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_33_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_34_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_34_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_35_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_35_dn202_tooth_status_code,
                       '') AS claim_tooth_status_list,
            CASE WHEN [x12_837_claim_dental].L2310A_nm108_id_code_qual = 'XX'
                      AND L2310A_nm109_referring_prov_id IS NOT NULL
                 THEN L2310A_nm109_referring_prov_id
                 ELSE NULL
            END AS FA0_REFERRING_PROV_NPI,
            CASE WHEN [x12_837_claim_dental].L2310A_nm108_id_code_qual != 'XX'
                      AND L2310A_nm109_referring_prov_id IS NOT NULL
                 THEN L2310A_nm109_referring_prov_id
                 ELSE NULL
            END AS FB1_REFERRING_PROV_UPIN,
            CASE WHEN L2400_sv305_prosthesis_crown_inlay_code = 'R'
                 THEN L2400_dtp02_446_replacement_date
                 ELSE null
            END AS prosthesis_placement_date,
            CASE WHEN L2300_clm11_related_causes_code1 = 'AA'
                      OR L2300_clm11_related_causes_code2 = 'AA'
                      OR L2300_clm11_related_causes_code3 = 'AA' THEN 1
                 ELSE 0
            END AS rel_to_auto,
            CASE WHEN L2300_clm11_related_causes_code1 = 'EM'
                      OR L2300_clm11_related_causes_code2 = 'EM'
                      OR L2300_clm11_related_causes_code3 = 'EM' THEN 1
                 ELSE 0
            END AS rel_to_employment,
            CASE WHEN L2300_clm11_related_causes_code1 = 'OA'
                      OR L2300_clm11_related_causes_code2 = 'OA'
                      OR L2300_clm11_related_causes_code3 = 'OA' THEN 1
                 ELSE 0
            END AS rel_to_other,
            L2300_dn101_orthodontic_treatment_months_count AS ortho_tx_months,
            L2300_dn102_orthodontic_treatment_months_remaining_count AS ortho_tx_months_remaining,
            dbo.x12_837_claim_dental.L2300_dtp03_452_orthodontic_banding_date as ortho_placement_date
    FROM    dbo.x12_837_claim_dental
    INNER JOIN dbo.x12_transaction
    ON      dbo.x12_837_claim_dental.x12_transaction_id = dbo.x12_transaction.x12_transaction_id
    INNER JOIN dbo.x12_functional_group
    ON      dbo.x12_functional_group.x12_functional_group_id = dbo.x12_transaction.x12_functional_group_id
    INNER JOIN dbo.x12_interchange
    ON      dbo.x12_interchange.x12_interchange_id = dbo.x12_functional_group.x12_interchange_id
    INNER JOIN dbo.x12_interchange_status
    ON      dbo.x12_interchange.x12_interchange_status_id = dbo.x12_interchange_status.x12_interchange_status_id
    INNER JOIN dbo.x12_transaction_schema
    ON      dbo.x12_functional_group.x12_transaction_schema_id = dbo.x12_transaction_schema.x12_transaction_schema_id
    GROUP BY dbo.x12_transaction.st02_transaction_control_no,
            dbo.x12_transaction.st01_transaction_id_code,
            dbo.x12_functional_group.gs08_version_id_code,
            dbo.x12_functional_group.gs07_resp_agency_code,
            dbo.x12_functional_group.gs06_group_control_no,
            dbo.x12_functional_group.gs05_time,
            dbo.x12_functional_group.gs04_date,
            dbo.x12_functional_group.gs03_app_receiver_code,
            dbo.x12_functional_group.gs02_app_sender_code,
            dbo.x12_functional_group.gs01_functional_id_code,
            dbo.x12_interchange.isa15_usage_indicator,
            dbo.x12_interchange.isa13_control_no,
            dbo.x12_interchange.isa12_control_version_no,
            dbo.x12_interchange.isa11_control_standards_id,
            dbo.x12_interchange.isa10_interchange_time,
            dbo.x12_interchange.isa09_interchange_date,
            dbo.x12_interchange.isa08_receiver_id,
            dbo.x12_interchange.isa07_receiver_id_qual,
            dbo.x12_interchange.isa06_sender_id,
            dbo.x12_interchange.isa05_sender_id_qual,
            dbo.x12_interchange.isa04_security_info,
            dbo.x12_interchange.isa03_security_info_qual,
            dbo.x12_interchange.isa02_auth_info,
            dbo.x12_interchange.isa01_auth_info_qual,
            dbo.x12_transaction.x12_transaction_id,
            dbo.x12_837_claim_dental.x12_837_claim_dental_id,
            dbo.x12_interchange.isa14_ack_requested,
            dbo.x12_837_claim_dental.L1000A_nm103_submitter_last_nm,
            dbo.x12_837_claim_dental.L1000A_nm109_submitter_id,
            ISNULL(dbo.x12_837_claim_dental.L2010AA_nm109_billing_prov_id, '')
            + '-'
            + ISNULL(COALESCE(dbo.x12_837_claim_dental.L2010AA_ref02_1C_billing_prov_id,
                              dbo.x12_837_claim_dental.L2010AA_ref02_1D_billing_prov_id),
                     ''),
            dbo.x12_837_claim_dental.L2010AA_nm103_billing_prov_last_nm,
            dbo.x12_837_claim_dental.L2010BA_nm103_subscriber_last_nm,
            dbo.x12_837_claim_dental.L2010BA_nm104_subscriber_first_nm,
            dbo.x12_837_claim_dental.L2010BA_nm105_subscriber_middle_nm,
            dbo.x12_837_claim_dental.L2300_clm01_pt_acct_num,
            dbo.x12_837_claim_dental.L2010BB_nm103_payer_nm,
            dbo.x12_837_claim_dental.L2010BB_nm109_payer_id,
            dbo.x12_837_claim_dental.L2010BA_nm109_subscriber_id, --dbo.x12_837_claim_dental.L2300_hi01_diag_code, 
                      --dbo.x12_837_claim_dental.L2300_hi02_diag_code, dbo.x12_837_claim_dental.L2300_hi03_diag_code, 
                      --dbo.x12_837_claim_dental.L2300_hi04_diag_code, 
            dbo.x12_837_claim_dental.L2400_lx01_assigned_num,
            dbo.x12_837_claim_dental.L2400_sv301_proc_code,
            dbo.x12_837_claim_dental.L2400_sv301_proc_mod1,
            dbo.x12_837_claim_dental.L2400_sv301_proc_mod2,
            dbo.x12_837_claim_dental.L2400_sv301_proc_mod3,
            dbo.x12_837_claim_dental.L2400_sv301_proc_mod4,
            dbo.x12_837_claim_dental.L2400_sv302_line_charge,
            ISNULL(dbo.x12_837_claim_dental.L2400_sv303_facility_type_code,
                   dbo.x12_837_claim_dental.L2300_clm05_facility_type_code), 
                      --dbo.x12_837_claim_dental.L2400_sv107_dx_pointer1, dbo.x12_837_claim_dental.L2400_sv107_dx_pointer2, 
                      --dbo.x12_837_claim_dental.L2400_sv107_dx_pointer3, dbo.x12_837_claim_dental.L2400_sv107_dx_pointer4, 
            dbo.x12_837_claim_dental.L2400_sv304_oral_cavity_designation_code_1
            + COALESCE(','
                       + dbo.x12_837_claim_dental.L2400_sv304_oral_cavity_designation_code_2,
                       '') + COALESCE(','
                                      + dbo.x12_837_claim_dental.L2400_sv304_oral_cavity_designation_code_3,
                                      '') + COALESCE(','
                                                     + dbo.x12_837_claim_dental.L2400_sv304_oral_cavity_designation_code_4,
                                                     '') + COALESCE(',' + dbo.x12_837_claim_dental.L2400_sv304_oral_cavity_designation_code_5, ''),
            dbo.x12_837_claim_dental.L2400_sv305_prosthesis_crown_inlay_code,
            dbo.x12_837_claim_dental.L2400_sv306_procedure_count,
            coalesce(dbo.x12_837_claim_dental.L2400_1_too02_JP_tooth_code
                     + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_1_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_1_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_1_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_1_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_1_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_2_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_2_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_2_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_2_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_2_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_2_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_3_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_3_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_3_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_3_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_3_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_3_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_4_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_4_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_4_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_4_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_4_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_4_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_5_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_5_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_5_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_5_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_5_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_5_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_6_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_6_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_6_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_6_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_6_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_6_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_7_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_7_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_7_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_7_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_7_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_7_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_8_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_8_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_8_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_8_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_8_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_8_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_9_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_9_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_9_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_9_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_9_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_9_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_10_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_10_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_10_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_10_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_10_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_10_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_11_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_11_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_11_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_11_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_11_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_11_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_12_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_12_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_12_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_12_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_12_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_12_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_13_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_13_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_13_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_13_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_13_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_13_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_14_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_14_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_14_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_14_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_14_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_14_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_15_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_15_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_15_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_15_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_15_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_15_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_16_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_16_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_16_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_16_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_16_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_16_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_17_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_17_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_17_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_17_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_17_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_17_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_18_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_18_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_18_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_18_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_18_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_18_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_19_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_19_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_19_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_19_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_19_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_19_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_20_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_20_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_20_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_20_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_20_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_20_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_21_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_21_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_21_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_21_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_21_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_21_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_22_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_22_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_22_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_22_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_22_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_22_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_23_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_23_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_23_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_23_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_23_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_23_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_24_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_24_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_24_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_24_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_24_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_24_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_25_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_25_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_25_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_25_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_25_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_25_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_26_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_26_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_26_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_26_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_26_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_26_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_27_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_27_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_27_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_27_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_27_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_27_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_28_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_28_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_28_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_28_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_28_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_28_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_29_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_29_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_29_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_29_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_29_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_29_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_30_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_30_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_30_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_30_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_30_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_30_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_31_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_31_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_31_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_31_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_31_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_31_too03_tooth_surface_code_5,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2400_32_too02_JP_tooth_code
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2400_32_too03_tooth_surface_code_1,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_32_too03_tooth_surface_code_2,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_32_too03_tooth_surface_code_3,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_32_too03_tooth_surface_code_4,
                       '')
            + coalesce(dbo.x12_837_claim_dental.L2400_32_too03_tooth_surface_code_5,
                       ''),
            dbo.x12_837_claim_dental.L2400_dtp02_472_service_date,
            dbo.x12_837_claim_dental.L2300_dtp03_472_service_date,
            dbo.x12_837_claim_dental.L2300_clm02_total_claim_chg_amt,
            dbo.x12_837_claim_dental.L2430_svd02_service_line_paid,
            CASE dbo.x12_837_claim_dental.L2430_cas01_adjustment_group_code
              WHEN 'PR'
              THEN IsNull(dbo.x12_837_claim_dental.L2430_cas03_adjustment_amt,
                          0)
                   + IsNull(dbo.x12_837_claim_dental.L2430_cas06_adjustment_amt,
                            0)
                   + IsNull(dbo.x12_837_claim_dental.L2430_cas09_adjustment_amt,
                            0)
              ELSE NULL
            END,
            dbo.x12_interchange.processed,
            dbo.x12_interchange.incoming,
            dbo.x12_functional_group.x12_functional_group_id,
            dbo.x12_interchange.x12_interchange_id,
            dbo.x12_interchange.created_date,
            'ISA-' + dbo.x12_interchange.isa13_control_no + ' GS-'
            + dbo.x12_functional_group.gs06_group_control_no + ' ST-'
            + dbo.x12_transaction.st02_transaction_control_no,
            dbo.x12_interchange.x12_interchange_uid,
            dbo.x12_837_claim_dental.L2420A_nm109_rendering_prov_id,
            ISNULL(dbo.x12_837_claim_dental.L2420A_nm109_rendering_prov_id
                   + '-'
                   + ISNULL(COALESCE(dbo.x12_837_claim_dental.L2420A_ref02_1C_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2420A_ref02_1D_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2420A_ref02_1E_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2420A_ref02_EI_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2420A_ref02_SY_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2420A_ref02_TJ_rendering_prov_id),
                            ''),
                   dbo.x12_837_claim_dental.L2310B_nm109_rendering_prov_id
                   + '-'
                   + ISNULL(COALESCE(dbo.x12_837_claim_dental.L2310B_ref02_1C_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2310B_ref02_1D_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2310B_ref02_1E_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2310B_ref02_EI_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2310B_ref02_SY_rendering_prov_id,
                                     dbo.x12_837_claim_dental.L2310B_ref02_TJ_rendering_prov_id),
                            '')),
            dbo.x12_transaction.se01_num_transaction_segments * 100,
            dbo.x12_837_claim_dental.L2310B_nm103_rendering_prov_last_nm,
            dbo.x12_837_claim_dental.L2310B_nm104_rendering_prov_first_nm,
            dbo.x12_837_claim_dental.L2310B_nm105_rendering_prov_middle_nm,
            dbo.x12_interchange.filename,
            dbo.x12_interchange.archive_filename,
            dbo.x12_interchange_status.x12_interchange_status_ud,
            dbo.x12_interchange_status.x12_interchange_status_nm,
            dbo.x12_transaction_schema.x12_transaction_schema_ud,
            dbo.x12_837_claim_dental.L2400_ref02_6R_line_item_control_num,
            dbo.x12_837_claim_dental.L2420A_prv03_taxonomy_code,
            dbo.x12_837_claim_dental.L2310B_prv03_taxonomy_code,
            dbo.x12_837_claim_dental.L2000A_prv03_taxonomy_code,
            coalesce(dbo.x12_837_claim_dental.L2300_1_dn201_tooth_number + '-',
                     '')
            + coalesce(dbo.x12_837_claim_dental.L2300_1_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_2_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_2_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_3_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_3_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_4_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_4_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_5_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_5_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_6_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_6_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_7_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_7_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_8_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_8_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_9_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_9_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_10_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_10_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_11_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_11_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_12_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_12_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_13_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_13_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_14_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_14_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_15_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_15_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_16_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_16_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_17_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_17_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_18_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_18_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_19_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_19_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_20_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_20_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_21_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_21_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_22_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_22_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_23_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_23_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_24_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_24_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_25_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_25_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_26_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_26_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_27_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_27_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_28_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_28_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_29_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_29_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_30_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_30_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_31_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_31_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_32_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_32_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_33_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_33_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_34_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_34_dn202_tooth_status_code,
                       '') + coalesce(','
                                      + dbo.x12_837_claim_dental.L2300_35_dn201_tooth_number
                                      + '-', '')
            + coalesce(dbo.x12_837_claim_dental.L2300_35_dn202_tooth_status_code,
                       ''),
            CASE WHEN [x12_837_claim_dental].L2310A_nm108_id_code_qual = 'XX'
                      AND L2310A_nm109_referring_prov_id IS NOT NULL
                 THEN L2310A_nm109_referring_prov_id
                 ELSE NULL
            END,
            CASE WHEN [x12_837_claim_dental].L2310A_nm108_id_code_qual != 'XX'
                      AND L2310A_nm109_referring_prov_id IS NOT NULL
                 THEN L2310A_nm109_referring_prov_id
                 ELSE NULL
            END,
            CASE WHEN L2400_sv305_prosthesis_crown_inlay_code = 'R'
                 THEN L2400_dtp02_446_replacement_date
                 ELSE null
            END,
            CASE WHEN L2300_clm11_related_causes_code1 = 'AA'
                      OR L2300_clm11_related_causes_code2 = 'AA'
                      OR L2300_clm11_related_causes_code3 = 'AA' THEN 1
                 ELSE 0
            END,
            CASE WHEN L2300_clm11_related_causes_code1 = 'EM'
                      OR L2300_clm11_related_causes_code2 = 'EM'
                      OR L2300_clm11_related_causes_code3 = 'EM' THEN 1
                 ELSE 0
            END,
            CASE WHEN L2300_clm11_related_causes_code1 = 'OA'
                      OR L2300_clm11_related_causes_code2 = 'OA'
                      OR L2300_clm11_related_causes_code3 = 'OA' THEN 1
                 ELSE 0
            END,
            L2300_dn101_orthodontic_treatment_months_count,
            L2300_dn102_orthodontic_treatment_months_remaining_count,
            dbo.x12_837_claim_dental.L2300_dtp03_452_orthodontic_banding_date
    ORDER BY dbo.x12_837_claim_dental.x12_837_claim_dental_id


GO
