SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_x12_837p_summary]
AS
SELECT     TOP 100 PERCENT dbo.x12_transaction.st02_transaction_control_no, dbo.x12_transaction.st01_transaction_id_code, 
                      dbo.x12_functional_group.gs08_version_id_code, dbo.x12_functional_group.gs07_resp_agency_code, 
                      dbo.x12_functional_group.gs06_group_control_no, dbo.x12_functional_group.gs05_time, dbo.x12_functional_group.gs04_date, 
                      dbo.x12_functional_group.gs03_app_receiver_code, dbo.x12_functional_group.gs02_app_sender_code, 
                      dbo.x12_functional_group.gs01_functional_id_code, dbo.x12_interchange.isa15_usage_indicator, dbo.x12_interchange.isa13_control_no, 
                      dbo.x12_interchange.isa12_control_version_no, dbo.x12_interchange.isa11_control_standards_id, dbo.x12_interchange.isa10_interchange_time, 
                      dbo.x12_interchange.isa09_interchange_date, dbo.x12_interchange.isa08_receiver_id, dbo.x12_interchange.isa07_receiver_id_qual, 
                      dbo.x12_interchange.isa06_sender_id, dbo.x12_interchange.isa05_sender_id_qual, dbo.x12_interchange.isa04_security_info, 
                      dbo.x12_interchange.isa03_security_info_qual, dbo.x12_interchange.isa02_auth_info, dbo.x12_interchange.isa01_auth_info_qual, 
                      dbo.x12_transaction.x12_transaction_id, dbo.x12_interchange.isa14_ack_requested, 
                      dbo.x12_837_claim_professional.L1000A_nm103_submitter_last_nm AS submitter_last_nm, 
                      dbo.x12_837_claim_professional.L1000A_nm104_submitter_first_nm AS submitter_first_nm, 
                      dbo.x12_837_claim_professional.L1000B_nm103_receiver_last_nm AS receiver_last_nm, 
                      COUNT(COALESCE (dbo.x12_837_claim_professional.L2300_ref02_F8_original_ref_num, 
                      dbo.x12_837_claim_professional.L2300_clm01_pt_acct_num)) AS claim_count, 
                      dbo.x12_837_claim_professional.L2300_clm05_claim_freq_code AS claim_freq_code, 
                      SUM(dbo.x12_837_claim_professional.L2400_sv102_line_charge) AS total_charges
FROM         dbo.x12_837_claim_professional INNER JOIN
                      dbo.x12_transaction ON dbo.x12_837_claim_professional.x12_transaction_id = dbo.x12_transaction.x12_transaction_id INNER JOIN
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
                      dbo.x12_837_claim_professional.L1000A_nm103_submitter_last_nm, dbo.x12_837_claim_professional.L1000A_nm104_submitter_first_nm, 
                      dbo.x12_837_claim_professional.L1000B_nm103_receiver_last_nm, dbo.x12_837_claim_professional.L2300_clm05_claim_freq_code
GO
