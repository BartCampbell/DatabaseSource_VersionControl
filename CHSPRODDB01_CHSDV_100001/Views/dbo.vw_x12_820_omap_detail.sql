SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vw_x12_820_omap_detail]
AS  SELECT TOP 100 PERCENT
            dbo.x12_transaction.st02_transaction_control_no,
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
            dbo.x12_interchange.isa14_ack_requested,
            dbo.x12_820_remittance_advice.bpr02_total_prov_pmt_amt AS total_check_amount,
            dbo.x12_820_remittance_advice.bpr16_check_eff_date AS check_date,
            dbo.x12_820_remittance_advice.trn02_trace_number AS check_number,
            dbo.x12_820_remittance_advice.L1000A_n102_receiver_org_nm AS receiver_nm,
            dbo.x12_820_remittance_advice.L1000A_n104_receiver_id AS receiver_id,
            dbo.x12_820_remittance_advice.L1000B_n102_payer_nm AS payer_nm,
            dbo.x12_820_remittance_advice.L1000B_n103_payer_id AS payer_id,
            dbo.x12_820_remittance_advice.L2300A_rmr04_prem_payment_amount AS premium_paid,
            dbo.x12_820_remittance_advice.L2000B_ent04_org_id_code_omap_rate_group AS omap_rate_group,
            dbo.x12_820_remittance_advice.L2000B_ent04_org_id_code_omap_perc AS omap_perc,
            dbo.x12_820_remittance_advice.L2000B_ent04_org_id_code_omap_php AS omap_php,
            dbo.x12_820_remittance_advice.L2000B_ent04_org_id_code_omap_fips AS omap_fips,
            dbo.x12_820_remittance_advice.L2300A_rmr04_prem_payment_amount AS premium,
            dbo.x12_820_remittance_advice.L2100B_nm109_individual_id AS omap_id,
            dbo.x12_820_remittance_advice.L2300B_dtm06_coverage_period_begin AS cvg_begin_date,
            dbo.x12_820_remittance_advice.L2300B_dtm06_coverage_period_end AS cvg_end_date
    FROM    dbo.x12_820_remittance_advice 
    INNER JOIN dbo.x12_transaction
            ON dbo.x12_820_remittance_advice.x12_transaction_id = dbo.x12_transaction.x12_transaction_id 
    INNER JOIN dbo.x12_functional_group
            ON dbo.x12_functional_group.x12_functional_group_id = dbo.x12_transaction.x12_functional_group_id
    INNER JOIN dbo.x12_interchange
            ON dbo.x12_interchange.x12_interchange_id = dbo.x12_functional_group.x12_interchange_id
    ORDER BY
            dbo.x12_interchange.isa09_interchange_date
GO
