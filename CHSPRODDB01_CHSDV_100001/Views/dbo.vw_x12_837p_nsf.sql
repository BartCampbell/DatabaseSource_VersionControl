SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_x12_837p_nsf]
AS
SELECT     TOP 100 PERCENT dbo.x12_interchange.x12_interchange_id, dbo.x12_functional_group.x12_functional_group_id, 
                      dbo.x12_837_claim_professional.x12_837_claim_professional_id, dbo.x12_transaction.x12_transaction_id, 
                      dbo.x12_transaction.st02_transaction_control_no, dbo.x12_transaction.st01_transaction_id_code, dbo.x12_functional_group.gs08_version_id_code, 
                      dbo.x12_functional_group.gs07_resp_agency_code, dbo.x12_functional_group.gs06_group_control_no, dbo.x12_functional_group.gs05_time, 
                      dbo.x12_functional_group.gs04_date, dbo.x12_functional_group.gs03_app_receiver_code, dbo.x12_functional_group.gs02_app_sender_code, 
                      dbo.x12_interchange.isa13_control_no, dbo.x12_interchange.isa12_control_version_no, dbo.x12_interchange.isa11_control_standards_id, 
                      dbo.x12_interchange.isa10_interchange_time, dbo.x12_interchange.isa09_interchange_date, dbo.x12_interchange.isa08_receiver_id, 
                      dbo.x12_interchange.isa07_receiver_id_qual, dbo.x12_interchange.isa06_sender_id, dbo.x12_interchange.isa05_sender_id_qual, 
                      dbo.x12_interchange.isa04_security_info, dbo.x12_interchange.isa03_security_info_qual, dbo.x12_interchange.isa02_auth_info, 
                      dbo.x12_interchange.isa01_auth_info_qual, dbo.x12_interchange.isa14_ack_requested, dbo.x12_interchange.processed, 
                      dbo.x12_interchange.incoming, dbo.x12_functional_group.gs01_functional_id_code, 
                      CASE dbo.x12_interchange.isa15_usage_indicator WHEN 'T' THEN 'TEST' ELSE 'PROD' END AS AA0_TEST_PRODUCTION, 
                      dbo.x12_837_claim_professional.L1000A_nm103_submitter_last_nm AS AA0_SUBMITTER_NAME, 
                      dbo.x12_837_claim_professional.L1000A_nm109_submitter_id AS AA0_SUBMITTER_ID, 
                      ISNULL(dbo.x12_837_claim_professional.L2010AA_nm109_billing_prov_id, '') 
                      + '-' + ISNULL(COALESCE (dbo.x12_837_claim_professional.L2010AA_ref02_1C_billing_prov_id, 
                      dbo.x12_837_claim_professional.L2010AA_ref02_1D_billing_prov_id), '') AS BA0_EMC_PROVIDER_ID, 
                      dbo.x12_837_claim_professional.L2010AA_nm103_billing_prov_last_nm AS BA0_ORGANIZATION_NM, 
                      dbo.x12_837_claim_professional.L2010BA_nm103_subscriber_last_nm AS CA0_LAST_NAME, 
                      dbo.x12_837_claim_professional.L2010BA_nm104_subscriber_first_nm AS CA0_FIRST_NAME, 
                      dbo.x12_837_claim_professional.L2010BA_nm105_subscriber_middle_nm AS CA0_MIDDLE_NAME, 
                      dbo.x12_837_claim_professional.L2300_clm01_pt_acct_num AS CA0_PTCONTROL_NUM, 
                      dbo.x12_837_claim_professional.L2010BB_nm103_payer_nm AS DA0_PAYER_NAME, 
                      dbo.x12_837_claim_professional.L2010BB_nm109_payer_id AS DA0_PAYER_ORG_ID, 
                      dbo.x12_837_claim_professional.L2010BA_nm109_subscriber_id AS DA0_INSUREDID_NUM, 
                      dbo.x12_837_claim_professional.L2300_hi01_diag_code AS EA0_DX1, dbo.x12_837_claim_professional.L2300_hi02_diag_code AS EA0_DX2, 
                      dbo.x12_837_claim_professional.L2300_hi03_diag_code AS EA0_DX3, dbo.x12_837_claim_professional.L2300_hi04_diag_code AS EA0_DX4, 
                      ISNULL(dbo.x12_837_claim_professional.L2420A_nm109_rendering_prov_id + '-' + ISNULL(COALESCE (dbo.x12_837_claim_professional.L2420A_ref02_1C_rendering_prov_id,
                       dbo.x12_837_claim_professional.L2420A_ref02_1D_rendering_prov_id, dbo.x12_837_claim_professional.L2420A_ref02_1G_rendering_prov_id, 
                      dbo.x12_837_claim_professional.L2420A_ref02_EI_rendering_prov_id, dbo.x12_837_claim_professional.L2420A_ref02_SY_rendering_prov_id, 
                      dbo.x12_837_claim_professional.L2420A_ref02_FH_rendering_prov_id), ''), 
                      dbo.x12_837_claim_professional.L2310B_nm109_rendering_prov_id + '-' + ISNULL(COALESCE (dbo.x12_837_claim_professional.L2310B_ref02_1C_rendering_prov_id,
                       dbo.x12_837_claim_professional.L2310B_ref02_1D_rendering_prov_id, dbo.x12_837_claim_professional.L2310B_ref02_1G_rendering_prov_id, 
                      dbo.x12_837_claim_professional.L2310B_ref02_EI_rendering_prov_id, dbo.x12_837_claim_professional.L2310B_ref02_SY_rendering_prov_id, 
                      dbo.x12_837_claim_professional.L2310B_ref02_FH_rendering_prov_id), '')) AS FA0_RENDERING_PROV_ID, 
                      dbo.x12_837_claim_professional.L2310B_nm103_rendering_prov_last_nm AS FB1_PROV_LAST_NAME, 
                      dbo.x12_837_claim_professional.L2310B_nm104_rendering_prov_first_nm AS FB1_PROV_FIRST_NAME, 
                      dbo.x12_837_claim_professional.L2310B_nm105_rendering_prov_middle_nm AS FB1_PROV_MIDDLE_NAME, REPLICATE('0', 
                      2 - LEN(LTRIM(RTRIM(dbo.x12_837_claim_professional.L2400_lx01_assigned_num)))) 
                      + LTRIM(RTRIM(dbo.x12_837_claim_professional.L2400_lx01_assigned_num)) AS FA0_SEQ_NUM, 
                      dbo.x12_837_claim_professional.L2400_sv101_proc_code AS FA0_HCPCS_PROC, 
                      dbo.x12_837_claim_professional.L2400_sv101_proc_mod1 AS FA0_HCPCS_MOD1, 
                      dbo.x12_837_claim_professional.L2400_sv101_proc_mod2 AS FA0_HCPCS_MOD2, 
                      dbo.x12_837_claim_professional.L2400_sv101_proc_mod3 AS FA0_HCPCS_MOD3, 
                      dbo.x12_837_claim_professional.L2400_sv101_proc_mod4 AS FA0_HCPCS_MOD4, 
                      dbo.x12_837_claim_professional.L2400_sv102_line_charge AS FA0_LINE_CHGS, 
                      ISNULL(dbo.x12_837_claim_professional.L2400_sv105_place_of_service, dbo.x12_837_claim_professional.L2300_clm05_facility_type_code) 
                      AS FA0_POS, dbo.x12_837_claim_professional.L2400_sv107_dx_pointer1 AS FA0_DX_SEQ1, 
                      dbo.x12_837_claim_professional.L2400_sv107_dx_pointer2 AS FA0_DX_SEQ2, 
                      dbo.x12_837_claim_professional.L2400_sv107_dx_pointer3 AS FA0_DX_SEQ3, 
                      dbo.x12_837_claim_professional.L2400_sv107_dx_pointer4 AS FA0_DX_SEQ4, 
                      dbo.x12_837_claim_professional.L2400_sv104_service_unit_count AS FA0_UNITS, 
                      dbo.x12_837_claim_professional.L2400_dtp02_472_from_service_date AS FA0_FROM_SVC_DT, 
                      dbo.x12_837_claim_professional.L2400_dtp02_472_to_service_date AS FA0_TO_SVC_DATE, 
                      STR(dbo.x12_837_claim_professional.L2300_clm02_total_claim_chg_amt) AS XA0_TOTAL_CLAIM_CHGS, 
                      dbo.x12_837_claim_professional.L2430_svd02_service_line_paid AS FA0_COB, 
                      dbo.x12_837_claim_professional.L2430_svd02_service_line_paid AS DA1_PAYER_AMT_PD, -- added 1/21/2008
                      CASE dbo.x12_837_claim_professional.L2430_cas01_adjustment_group_code WHEN 'PR' THEN IsNull(dbo.x12_837_claim_professional.L2430_cas03_adjustment_amt,
                       0) + IsNull(dbo.x12_837_claim_professional.L2430_cas06_adjustment_amt, 0) 
                      + IsNull(dbo.x12_837_claim_professional.L2430_cas09_adjustment_amt, 0) ELSE NULL END AS FA0_PATIENT_RESPONSIBILITY, 
                      dbo.x12_interchange.created_date AS DateLastModified, dbo.x12_interchange.created_date AS received_date, '' AS Mode, 
                      'ISA-' + dbo.x12_interchange.isa13_control_no + ' GS-' + dbo.x12_functional_group.gs06_group_control_no + ' ST-' + dbo.x12_transaction.st02_transaction_control_no
                       AS FauxName, dbo.x12_transaction.se01_num_transaction_segments * 100 AS [Size], 'file' AS Type, 
                      dbo.x12_interchange.x12_interchange_uid AS Name, dbo.x12_interchange.filename, dbo.x12_interchange.archive_filename, 
                      dbo.x12_interchange_status.x12_interchange_status_ud, dbo.x12_interchange_status.x12_interchange_status_nm, 
                      dbo.x12_transaction_schema.x12_transaction_schema_ud, 
                      dbo.x12_837_claim_professional.L2400_ref02_6R_line_item_control_num AS FA0_LINE_ITEM_CONTROL_NO, 
                      COALESCE (dbo.x12_837_claim_professional.L2420A_prv03_taxonomy_code, dbo.x12_837_claim_professional.L2310B_prv03_taxonomy_code, 
                      dbo.x12_837_claim_professional.L2000A_prv03_taxonomy_code) AS rendering_taxonomy_code,
                      dbo.x12_837_claim_professional.L2410_1_lin03_N4_ndc AS ndc_ud
FROM         dbo.x12_837_claim_professional INNER JOIN
                      dbo.x12_transaction ON dbo.x12_837_claim_professional.x12_transaction_id = dbo.x12_transaction.x12_transaction_id INNER JOIN
                      dbo.x12_functional_group ON dbo.x12_functional_group.x12_functional_group_id = dbo.x12_transaction.x12_functional_group_id INNER JOIN
                      dbo.x12_interchange ON dbo.x12_interchange.x12_interchange_id = dbo.x12_functional_group.x12_interchange_id INNER JOIN
                      dbo.x12_interchange_status ON 
                      dbo.x12_interchange.x12_interchange_status_id = dbo.x12_interchange_status.x12_interchange_status_id INNER JOIN
                      dbo.x12_transaction_schema ON 
                      dbo.x12_functional_group.x12_transaction_schema_id = dbo.x12_transaction_schema.x12_transaction_schema_id
GROUP BY dbo.x12_transaction.st02_transaction_control_no, dbo.x12_transaction.st01_transaction_id_code, dbo.x12_functional_group.gs08_version_id_code, 
                      dbo.x12_functional_group.gs07_resp_agency_code, dbo.x12_functional_group.gs06_group_control_no, dbo.x12_functional_group.gs05_time, 
                      dbo.x12_functional_group.gs04_date, dbo.x12_functional_group.gs03_app_receiver_code, dbo.x12_functional_group.gs02_app_sender_code, 
                      dbo.x12_functional_group.gs01_functional_id_code, dbo.x12_interchange.isa15_usage_indicator, dbo.x12_interchange.isa13_control_no, 
                      dbo.x12_interchange.isa12_control_version_no, dbo.x12_interchange.isa11_control_standards_id, dbo.x12_interchange.isa10_interchange_time, 
                      dbo.x12_interchange.isa09_interchange_date, dbo.x12_interchange.isa08_receiver_id, dbo.x12_interchange.isa07_receiver_id_qual, 
                      dbo.x12_interchange.isa06_sender_id, dbo.x12_interchange.isa05_sender_id_qual, dbo.x12_interchange.isa04_security_info, 
                      dbo.x12_interchange.isa03_security_info_qual, dbo.x12_interchange.isa02_auth_info, dbo.x12_interchange.isa01_auth_info_qual, 
                      dbo.x12_transaction.x12_transaction_id, dbo.x12_837_claim_professional.x12_837_claim_professional_id, 
                      dbo.x12_interchange.isa14_ack_requested, dbo.x12_837_claim_professional.L1000A_nm103_submitter_last_nm, 
                      dbo.x12_837_claim_professional.L1000A_nm109_submitter_id, ISNULL(dbo.x12_837_claim_professional.L2010AA_nm109_billing_prov_id, '') 
                      + '-' + ISNULL(COALESCE (dbo.x12_837_claim_professional.L2010AA_ref02_1C_billing_prov_id, 
                      dbo.x12_837_claim_professional.L2010AA_ref02_1D_billing_prov_id), ''), dbo.x12_837_claim_professional.L2010AA_nm103_billing_prov_last_nm, 
                      dbo.x12_837_claim_professional.L2010BA_nm103_subscriber_last_nm, dbo.x12_837_claim_professional.L2010BA_nm104_subscriber_first_nm, 
                      dbo.x12_837_claim_professional.L2010BA_nm105_subscriber_middle_nm, dbo.x12_837_claim_professional.L2300_clm01_pt_acct_num, 
                      dbo.x12_837_claim_professional.L2010BB_nm103_payer_nm, dbo.x12_837_claim_professional.L2010BB_nm109_payer_id, 
                      dbo.x12_837_claim_professional.L2010BA_nm109_subscriber_id, dbo.x12_837_claim_professional.L2300_hi01_diag_code, 
                      dbo.x12_837_claim_professional.L2300_hi02_diag_code, dbo.x12_837_claim_professional.L2300_hi03_diag_code, 
                      dbo.x12_837_claim_professional.L2300_hi04_diag_code, dbo.x12_837_claim_professional.L2400_lx01_assigned_num, 
                      dbo.x12_837_claim_professional.L2400_sv101_proc_code, dbo.x12_837_claim_professional.L2400_sv101_proc_mod1, 
                      dbo.x12_837_claim_professional.L2400_sv101_proc_mod2, dbo.x12_837_claim_professional.L2400_sv101_proc_mod3, 
                      dbo.x12_837_claim_professional.L2400_sv101_proc_mod4, dbo.x12_837_claim_professional.L2400_sv102_line_charge, 
                      ISNULL(dbo.x12_837_claim_professional.L2400_sv105_place_of_service, dbo.x12_837_claim_professional.L2300_clm05_facility_type_code), 
                      dbo.x12_837_claim_professional.L2400_sv107_dx_pointer1, dbo.x12_837_claim_professional.L2400_sv107_dx_pointer2, 
                      dbo.x12_837_claim_professional.L2400_sv107_dx_pointer3, dbo.x12_837_claim_professional.L2400_sv107_dx_pointer4, 
                      dbo.x12_837_claim_professional.L2400_sv104_service_unit_count, dbo.x12_837_claim_professional.L2400_dtp02_472_from_service_date, 
                      dbo.x12_837_claim_professional.L2400_dtp02_472_to_service_date, dbo.x12_837_claim_professional.L2300_clm02_total_claim_chg_amt, 
                      dbo.x12_837_claim_professional.L2430_svd02_service_line_paid, 
                      CASE dbo.x12_837_claim_professional.L2430_cas01_adjustment_group_code WHEN 'PR' THEN IsNull(dbo.x12_837_claim_professional.L2430_cas03_adjustment_amt,
                       0) + IsNull(dbo.x12_837_claim_professional.L2430_cas06_adjustment_amt, 0) 
                      + IsNull(dbo.x12_837_claim_professional.L2430_cas09_adjustment_amt, 0) ELSE NULL END, dbo.x12_interchange.processed, 
                      dbo.x12_interchange.incoming, dbo.x12_functional_group.x12_functional_group_id, dbo.x12_interchange.x12_interchange_id, 
                      dbo.x12_interchange.created_date, 
                      'ISA-' + dbo.x12_interchange.isa13_control_no + ' GS-' + dbo.x12_functional_group.gs06_group_control_no + ' ST-' + dbo.x12_transaction.st02_transaction_control_no,
                       dbo.x12_interchange.x12_interchange_uid, dbo.x12_837_claim_professional.L2420A_nm109_rendering_prov_id, 
                      ISNULL(dbo.x12_837_claim_professional.L2420A_nm109_rendering_prov_id + '-' + ISNULL(COALESCE (dbo.x12_837_claim_professional.L2420A_ref02_1C_rendering_prov_id,
                       dbo.x12_837_claim_professional.L2420A_ref02_1D_rendering_prov_id, dbo.x12_837_claim_professional.L2420A_ref02_1G_rendering_prov_id, 
                      dbo.x12_837_claim_professional.L2420A_ref02_EI_rendering_prov_id, dbo.x12_837_claim_professional.L2420A_ref02_SY_rendering_prov_id, 
                      dbo.x12_837_claim_professional.L2420A_ref02_FH_rendering_prov_id), ''), 
                      dbo.x12_837_claim_professional.L2310B_nm109_rendering_prov_id + '-' + ISNULL(COALESCE (dbo.x12_837_claim_professional.L2310B_ref02_1C_rendering_prov_id,
                       dbo.x12_837_claim_professional.L2310B_ref02_1D_rendering_prov_id, dbo.x12_837_claim_professional.L2310B_ref02_1G_rendering_prov_id, 
                      dbo.x12_837_claim_professional.L2310B_ref02_EI_rendering_prov_id, dbo.x12_837_claim_professional.L2310B_ref02_SY_rendering_prov_id, 
                      dbo.x12_837_claim_professional.L2310B_ref02_FH_rendering_prov_id), '')), dbo.x12_transaction.se01_num_transaction_segments * 100, 
                      dbo.x12_837_claim_professional.L2310B_nm103_rendering_prov_last_nm, 
                      dbo.x12_837_claim_professional.L2310B_nm104_rendering_prov_first_nm, 
                      dbo.x12_837_claim_professional.L2310B_nm105_rendering_prov_middle_nm, dbo.x12_interchange.filename, dbo.x12_interchange.archive_filename, 
                      dbo.x12_interchange_status.x12_interchange_status_ud, dbo.x12_interchange_status.x12_interchange_status_nm, 
                      dbo.x12_transaction_schema.x12_transaction_schema_ud, dbo.x12_837_claim_professional.L2400_ref02_6R_line_item_control_num, 
                      dbo.x12_837_claim_professional.L2420A_prv03_taxonomy_code, dbo.x12_837_claim_professional.L2310B_prv03_taxonomy_code, 
                      dbo.x12_837_claim_professional.L2000A_prv03_taxonomy_code, dbo.x12_837_claim_professional.L2410_1_lin03_N4_ndc
ORDER BY dbo.x12_837_claim_professional.x12_837_claim_professional_id


GO
