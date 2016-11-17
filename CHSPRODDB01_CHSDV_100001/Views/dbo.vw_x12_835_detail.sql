SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_x12_835_detail]
AS
SELECT     TOP 100 PERCENT dbo.x12_interchange.x12_interchange_id, dbo.x12_functional_group.x12_functional_group_id, 
                      dbo.x12_transaction.x12_transaction_id, dbo.x12_transaction.st02_transaction_control_no, dbo.x12_transaction.st01_transaction_id_code, 
                      dbo.x12_functional_group.gs08_version_id_code, dbo.x12_functional_group.gs07_resp_agency_code, 
                      dbo.x12_functional_group.gs06_group_control_no, dbo.x12_functional_group.gs05_time, dbo.x12_functional_group.gs04_date, 
                      dbo.x12_functional_group.gs03_app_receiver_code, dbo.x12_functional_group.gs02_app_sender_code, 
                      dbo.x12_functional_group.gs01_functional_id_code, dbo.x12_interchange.isa15_usage_indicator, dbo.x12_interchange.isa13_control_no, 
                      dbo.x12_interchange.isa12_control_version_no, dbo.x12_interchange.isa11_control_standards_id, dbo.x12_interchange.isa10_interchange_time, 
                      dbo.x12_interchange.isa09_interchange_date, dbo.x12_interchange.isa08_receiver_id, dbo.x12_interchange.isa07_receiver_id_qual, 
                      dbo.x12_interchange.isa06_sender_id, dbo.x12_interchange.isa05_sender_id_qual, dbo.x12_interchange.isa04_security_info, 
                      dbo.x12_interchange.isa03_security_info_qual, dbo.x12_interchange.isa02_auth_info, dbo.x12_interchange.isa01_auth_info_qual, 
                      dbo.x12_interchange.isa14_ack_requested, dbo.x12_835_claim_payment_advice.bpr09_sender_account_num AS sender_account_num, 
                      dbo.x12_835_claim_payment_advice.bpr10_payer_id AS payer_id, dbo.x12_835_claim_payment_advice.bpr13_receiver_dfi_id AS receiver_id, 
                      dbo.x12_835_claim_payment_advice.bpr16_check_date AS check_date, dbo.x12_835_claim_payment_advice.L1000A_n102_payer_nm AS payer_nm, 
                      dbo.x12_835_claim_payment_advice.L1000B_n102_payee_nm AS payee_nm, 
                      dbo.x12_835_claim_payment_advice.L2100_clp02_claim_status_code AS claim_status_code, 
                      dbo.x12_835_claim_payment_advice.L2110_1_cas02_adj_reason_code AS adj_reason_code_1, 
                      dbo.x12_835_claim_payment_advice.L2110_1_cas05_adj_reason_code AS adj_reason_code_2, 
                      dbo.x12_835_claim_payment_advice.L2110_1_cas08_adj_reason_code AS adj_reason_code_3, 
                      dbo.x12_835_claim_payment_advice.L2110_1_cas11_adj_reason_code AS adj_reason_code_4, 
                      dbo.x12_835_claim_payment_advice.L2110_1_cas14_adj_reason_code AS adj_reason_code_5, 
                      COUNT(dbo.x12_835_claim_payment_advice.L2100_clp01_pt_control_no) AS claim_count, 
                      dbo.x12_835_claim_payment_advice.L2100_clp07_payer_claim_control_no, 
                      dbo.x12_835_claim_payment_advice.L2100_ref02_F8_other_claim_ref_id, dbo.x12_835_claim_payment_advice.L2100_ref02_EA_other_claim_ref_id, 
                      dbo.x12_835_claim_payment_advice.L2100_ref02_G1_other_claim_ref_id, dbo.x12_835_claim_payment_advice.L2100_ref02_BB_other_claim_ref_id, 
                      dbo.x12_835_claim_payment_advice.L2100_ref02_9A_other_claim_ref_id, dbo.x12_835_claim_payment_advice.L2110_lq02_remark_code_01, 
                      dbo.x12_835_claim_payment_advice.L2110_lq02_remark_code_02, dbo.x12_835_claim_payment_advice.L2110_lq02_remark_code_03, 
                      dbo.x12_835_claim_payment_advice.L2110_lq02_remark_code_04, dbo.x12_835_claim_payment_advice.L2110_lq02_remark_code_05
FROM         dbo.x12_835_claim_payment_advice INNER JOIN
                      dbo.x12_transaction ON dbo.x12_835_claim_payment_advice.x12_transaction_id = dbo.x12_transaction.x12_transaction_id INNER JOIN
                      dbo.x12_functional_group ON dbo.x12_functional_group.x12_functional_group_id = dbo.x12_transaction.x12_functional_group_id INNER JOIN
                      dbo.x12_interchange ON dbo.x12_interchange.x12_interchange_id = dbo.x12_functional_group.x12_interchange_id
GROUP BY dbo.x12_transaction.st02_transaction_control_no, dbo.x12_transaction.st01_transaction_id_code, dbo.x12_functional_group.gs08_version_id_code, 
                      dbo.x12_functional_group.gs07_resp_agency_code, dbo.x12_functional_group.gs06_group_control_no, dbo.x12_functional_group.gs05_time, 
                      dbo.x12_functional_group.gs04_date, dbo.x12_functional_group.gs03_app_receiver_code, dbo.x12_functional_group.gs02_app_sender_code, 
                      dbo.x12_functional_group.gs01_functional_id_code, dbo.x12_interchange.isa15_usage_indicator, dbo.x12_interchange.isa13_control_no, 
                      dbo.x12_interchange.isa12_control_version_no, dbo.x12_interchange.isa11_control_standards_id, dbo.x12_interchange.isa10_interchange_time, 
                      dbo.x12_interchange.isa09_interchange_date, dbo.x12_interchange.isa08_receiver_id, dbo.x12_interchange.isa07_receiver_id_qual, 
                      dbo.x12_interchange.isa06_sender_id, dbo.x12_interchange.isa05_sender_id_qual, dbo.x12_interchange.isa04_security_info, 
                      dbo.x12_interchange.isa03_security_info_qual, dbo.x12_interchange.isa02_auth_info, dbo.x12_interchange.isa01_auth_info_qual, 
                      dbo.x12_transaction.x12_transaction_id, dbo.x12_interchange.isa14_ack_requested, 
                      dbo.x12_835_claim_payment_advice.bpr09_sender_account_num, dbo.x12_835_claim_payment_advice.bpr10_payer_id, 
                      dbo.x12_835_claim_payment_advice.bpr13_receiver_dfi_id, dbo.x12_835_claim_payment_advice.bpr16_check_date, 
                      dbo.x12_835_claim_payment_advice.L1000A_n102_payer_nm, dbo.x12_835_claim_payment_advice.L1000B_n102_payee_nm, 
                      dbo.x12_835_claim_payment_advice.L2100_clp02_claim_status_code, dbo.x12_835_claim_payment_advice.L2110_1_cas02_adj_reason_code, 
                      dbo.x12_835_claim_payment_advice.L2110_1_cas05_adj_reason_code, dbo.x12_835_claim_payment_advice.L2110_1_cas08_adj_reason_code, 
                      dbo.x12_835_claim_payment_advice.L2110_1_cas11_adj_reason_code, dbo.x12_835_claim_payment_advice.L2110_1_cas14_adj_reason_code, 
                      dbo.x12_functional_group.x12_functional_group_id, dbo.x12_interchange.x12_interchange_id, 
                      dbo.x12_835_claim_payment_advice.L2100_clp07_payer_claim_control_no, 
                      dbo.x12_835_claim_payment_advice.L2100_ref02_F8_other_claim_ref_id, dbo.x12_835_claim_payment_advice.L2100_ref02_EA_other_claim_ref_id, 
                      dbo.x12_835_claim_payment_advice.L2100_ref02_G1_other_claim_ref_id, dbo.x12_835_claim_payment_advice.L2100_ref02_BB_other_claim_ref_id, 
                      dbo.x12_835_claim_payment_advice.L2100_ref02_9A_other_claim_ref_id, dbo.x12_835_claim_payment_advice.L2110_lq02_remark_code_01, 
                      dbo.x12_835_claim_payment_advice.L2110_lq02_remark_code_02, dbo.x12_835_claim_payment_advice.L2110_lq02_remark_code_03, 
                      dbo.x12_835_claim_payment_advice.L2110_lq02_remark_code_04, dbo.x12_835_claim_payment_advice.L2110_lq02_remark_code_05
GO
