SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vw_x12_834_summary]
AS
SELECT     TOP 100 PERCENT dbo.x12_transaction.st02_transaction_control_no, dbo.x12_transaction.st01_transaction_id_code, 
                      dbo.x12_functional_group.gs08_version_id_code, dbo.x12_functional_group.gs07_resp_agency_code, 
                      dbo.x12_functional_group.gs06_group_control_no, dbo.x12_functional_group.gs05_time, dbo.x12_functional_group.gs04_date, 
                      dbo.x12_functional_group.gs03_app_receiver_code, dbo.x12_functional_group.gs02_app_sender_code, 
                      dbo.x12_functional_group.gs01_functional_id_code, dbo.x12_interchange.isa15_usage_indicator, 
                      dbo.x12_interchange.isa13_control_no, dbo.x12_interchange.isa12_control_version_no, 
                      dbo.x12_interchange.isa11_control_standards_id, dbo.x12_interchange.isa10_interchange_time, 
                      dbo.x12_interchange.isa09_interchange_date, dbo.x12_interchange.isa08_receiver_id, 
                      dbo.x12_interchange.isa07_receiver_id_qual, dbo.x12_interchange.isa06_sender_id, 
                      dbo.x12_interchange.isa05_sender_id_qual, dbo.x12_interchange.isa04_security_info, 
                      dbo.x12_interchange.isa03_security_info_qual, dbo.x12_interchange.isa02_auth_info, 
                      dbo.x12_interchange.isa01_auth_info_qual, dbo.x12_transaction.x12_transaction_id, 
                      dbo.x12_interchange.isa14_ack_requested, dbo.x12_834_benefit_enrollment.L2000_ins03_maint_type_code AS maint_type, 
                      COUNT(dbo.x12_834_benefit_enrollment.L2100A_nm109_subscriber_id) AS subscriber_count, 
                      SUM(dbo.x12_834_benefit_enrollment.L2100A_amt02_P3_contract_amt) AS premium_amount, 
                      SUM(dbo.x12_834_benefit_enrollment.L2100A_amt02_D2_contract_amt) AS deduct_amount, 
                      SUM(dbo.x12_834_benefit_enrollment.L2100A_amt02_C1_contract_amt) AS copay_amount, 
                      SUM(dbo.x12_834_benefit_enrollment.L2100A_amt02_B9_contract_amt) AS coins_amount, 
                      dbo.x12_834_benefit_enrollment.L2000_ref02_insured_grp_policy_num AS group_number
FROM dbo.x12_834_benefit_enrollment
INNER JOIN dbo.x12_transaction
	ON dbo.x12_834_benefit_enrollment.x12_transaction_id = dbo.x12_transaction.x12_transaction_id
INNER JOIN dbo.x12_functional_group
	ON dbo.x12_functional_group.x12_functional_group_id = dbo.x12_transaction.x12_functional_group_id
INNER JOIN dbo.x12_interchange
	ON dbo.x12_interchange.x12_interchange_id = dbo.x12_functional_group.x12_interchange_id
GROUP BY	dbo.x12_transaction.st02_transaction_control_no, dbo.x12_transaction.st01_transaction_id_code, 
		dbo.x12_functional_group.gs08_version_id_code, dbo.x12_functional_group.gs07_resp_agency_code, 
		dbo.x12_functional_group.gs06_group_control_no, dbo.x12_functional_group.gs05_time, dbo.x12_functional_group.gs04_date, 
		dbo.x12_functional_group.gs03_app_receiver_code, dbo.x12_functional_group.gs02_app_sender_code, 
		dbo.x12_functional_group.gs01_functional_id_code, dbo.x12_interchange.isa15_usage_indicator, 
		dbo.x12_interchange.isa13_control_no, dbo.x12_interchange.isa12_control_version_no, 
		dbo.x12_interchange.isa11_control_standards_id, dbo.x12_interchange.isa10_interchange_time, 
		dbo.x12_interchange.isa09_interchange_date, dbo.x12_interchange.isa08_receiver_id, 
		dbo.x12_interchange.isa07_receiver_id_qual, dbo.x12_interchange.isa06_sender_id, 
		dbo.x12_interchange.isa05_sender_id_qual, dbo.x12_interchange.isa04_security_info, 
		dbo.x12_interchange.isa03_security_info_qual, dbo.x12_interchange.isa02_auth_info, 
		dbo.x12_interchange.isa01_auth_info_qual, dbo.x12_transaction.x12_transaction_id, 
		dbo.x12_interchange.isa14_ack_requested, dbo.x12_834_benefit_enrollment.L2000_ins03_maint_type_code, 
		dbo.x12_834_benefit_enrollment.L2000_ref02_insured_grp_policy_num

GO
