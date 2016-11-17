SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_x12_834_detail]
AS
SELECT DISTINCT 
                      TOP 100 PERCENT dbo.x12_interchange.x12_interchange_id, dbo.x12_functional_group.x12_functional_group_id, 
                      dbo.x12_transaction.x12_transaction_id, src_x12_organization.x12_organization_id AS src_x12_organization_id, 
                      src_x12_organization.x12_organization_ud AS src_x12_organization_ud, src_x12_organization.x12_organization_nm AS src_x12_organization_nm, 
                      dest_x12_organization.x12_organization_id AS dest_x12_organization_id, dest_x12_organization.x12_organization_ud AS dest_x12_organization_ud, 
                      dest_x12_organization.x12_organization_nm AS dest_x12_organization_nm, dbo.x12_interchange.isa01_auth_info_qual, 
                      dbo.x12_interchange.isa02_auth_info, dbo.x12_interchange.isa03_security_info_qual, dbo.x12_interchange.isa04_security_info, 
                      dbo.x12_interchange.isa05_sender_id_qual, dbo.x12_interchange.isa06_sender_id, dbo.x12_interchange.isa07_receiver_id_qual, 
                      dbo.x12_interchange.isa08_receiver_id, dbo.x12_interchange.isa09_interchange_date, dbo.x12_interchange.isa10_interchange_time, 
                      dbo.x12_interchange.isa11_control_standards_id, dbo.x12_interchange.isa15_usage_indicator, dbo.x12_interchange.isa14_ack_requested, 
                      dbo.x12_interchange.isa13_control_no, dbo.x12_interchange.isa12_control_version_no, dbo.x12_functional_group.gs01_functional_id_code, 
                      dbo.x12_functional_group.gs02_app_sender_code, dbo.x12_functional_group.gs03_app_receiver_code, 
                      dbo.x12_functional_group.gs08_version_id_code, dbo.x12_functional_group.gs07_resp_agency_code, 
                      dbo.x12_functional_group.gs06_group_control_no, dbo.x12_functional_group.gs05_time, dbo.x12_functional_group.gs04_date, 
                      dbo.x12_transaction.st01_transaction_id_code, dbo.x12_transaction.st02_transaction_control_no, 
                      dbo.x12_834_benefit_enrollment.L2000_ins03_maint_type_code AS maint_type, 
                      CASE L2000_ins03_maint_type_code + '-' + ISNULL(L2300_hd01_maint_type_code, '024') 
                      WHEN '001-024' THEN 'CLOSE' WHEN '001-021' THEN 'NEW' WHEN '021-021' THEN 'NEW' WHEN '024-024' THEN 'CLOSE' WHEN '030-030' THEN 'OPEN'
                       END AS plan_maint_type, dbo.x12_834_benefit_enrollment.L2100A_amt02_P3_contract_amt AS premium_amount, 
                      dbo.x12_834_benefit_enrollment.L2100A_amt02_D2_contract_amt AS deduct_amount, 
                      dbo.x12_834_benefit_enrollment.L2100A_amt02_C1_contract_amt AS copay_amount, 
                      dbo.x12_834_benefit_enrollment.L2100A_amt02_B9_contract_amt AS coins_amount, 
                      dbo.x12_834_benefit_enrollment.L2000_ref02_insured_grp_policy_num AS group_number, 
                      dbo.x12_834_benefit_enrollment.L2000_ref02_subscriber_id AS subscriber_id, 
                      dbo.x12_834_benefit_enrollment.L2100A_nm103_subscriber_last_nm AS subscriber_last_name, 
                      dbo.x12_834_benefit_enrollment.L2100A_nm104_subscriber_first_nm AS subscriber_first_name, 
                      dbo.x12_834_benefit_enrollment.L2100A_nm105_subscriber_middle_nm AS subscriber_middle_name, 
                      dbo.x12_834_benefit_enrollment.L2100A_nm106_subscriber_name_prefix AS subscriber_name_prefix, 
                      dbo.x12_834_benefit_enrollment.L2100A_nm107_subscriber_name_suffix AS subscriber_name_suffix, 
                      dbo.x12_834_benefit_enrollment.L2100A_n301_subscriber_address1 AS address1, 
                      dbo.x12_834_benefit_enrollment.L2100A_n302_subscriber_address2 AS address2, 
                      dbo.x12_834_benefit_enrollment.L2100A_n402_subscriber_state AS state, dbo.x12_834_benefit_enrollment.L2100A_n401_subscriber_city AS city, 
                      dbo.x12_834_benefit_enrollment.L2100A_n403_subscriber_zip AS zip, dbo.x12_834_benefit_enrollment.L2100A_dmg02_member_dob AS dob, 
                      dbo.x12_834_benefit_enrollment.L2100A_dmg03_member_gender AS gender, dbo.x12_834_benefit_enrollment.L2100A_nm109_subscriber_id AS ssn, 
                      dbo.x12_834_benefit_enrollment.L2100A_per104_member_comm AS phone, 
                      COALESCE (dbo.x12_834_benefit_enrollment.L2000_dtp03_356_status_info_eff_date, dbo.x12_834_benefit_enrollment.L2300_dtp03_348_cvg_period) 
                      AS eff_date, CASE L2000_ins03_maint_type_code WHEN '030' THEN IsNull(NULL, NULL) WHEN '021' THEN IsNull(NULL, NULL) 
                      ELSE COALESCE (L2000_dtp03_357_status_info_eff_date, L2300_dtp03_349_cvg_period) END AS term_date, 
                      dbo.x12_834_benefit_enrollment.L2300_hd04_plan_cvg_desc AS plan_desc
FROM         dbo.x12_organization dest_x12_organization RIGHT OUTER JOIN
                      dbo.x12_834_benefit_enrollment INNER JOIN
                      dbo.x12_transaction ON dbo.x12_834_benefit_enrollment.x12_transaction_id = dbo.x12_transaction.x12_transaction_id INNER JOIN
                      dbo.x12_functional_group ON dbo.x12_functional_group.x12_functional_group_id = dbo.x12_transaction.x12_functional_group_id INNER JOIN
                      dbo.x12_interchange ON dbo.x12_interchange.x12_interchange_id = dbo.x12_functional_group.x12_interchange_id ON 
                      dest_x12_organization.x12_organization_id = dbo.x12_interchange.dest_x12_organization_id LEFT OUTER JOIN
                      dbo.x12_organization src_x12_organization ON dbo.x12_interchange.src_x12_organization_id = src_x12_organization.x12_organization_id
GO
