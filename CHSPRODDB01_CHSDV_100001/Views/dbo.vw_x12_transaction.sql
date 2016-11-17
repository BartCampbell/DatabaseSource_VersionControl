SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vw_x12_transaction]
AS  SELECT  dest_x12_organization.x12_organization_nm AS dest_x12_organization_nm,
            src_x12_organization.x12_organization_nm AS src_x12_organization_nm,
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
            dbo.x12_interchange.isa15_usage_indicator,
            dbo.x12_interchange.isa16_component_element_seperator,
            dbo.x12_interchange.element_separator,
            dbo.x12_interchange.segment_separator,
            dbo.x12_interchange.dest_x12_organization_id,
            dbo.x12_interchange.src_x12_organization_id,
            dbo.x12_interchange.x12_interchange_uid,
            dbo.x12_interchange.x12_interchange_id,
            dbo.x12_interchange.iea01_num_functional_groups,
            dbo.x12_interchange.filename,
            dbo.x12_interchange.archive_filename,
            dbo.x12_functional_group.x12_functional_group_id,
            dbo.x12_functional_group.x12_transaction_schema_id,
            dbo.x12_functional_group.gs01_functional_id_code,
            dbo.x12_functional_group.gs02_app_sender_code,
            dbo.x12_functional_group.gs03_app_receiver_code,
            dbo.x12_functional_group.gs04_date,
            dbo.x12_functional_group.gs05_time,
            dbo.x12_functional_group.gs06_group_control_no,
            dbo.x12_functional_group.gs07_resp_agency_code,
            dbo.x12_functional_group.gs08_version_id_code,
            dbo.x12_functional_group.ge01_num_transaction_sets,
            dbo.x12_transaction.x12_transaction_id,
            dbo.x12_transaction.x12_transaction_uid,
            dbo.x12_transaction.st01_transaction_id_code,
            dbo.x12_transaction.st02_transaction_control_no,
            dbo.x12_transaction.se01_num_transaction_segments,
            dbo.x12_interchange.created_date,
            dbo.x12_interchange.error,
            dbo.x12_interchange.processed,
            dbo.x12_interchange.incoming,
            dbo.x12_interchange.outgoing,
            dbo.x12_transaction_schema.x12_transaction_schema_ud,
            dbo.x12_transaction_schema.x12_transaction_schema_nm,
            dbo.x12_transaction_schema.transaction_id_code,
            dbo.x12_transaction_schema.functional_group_id_code,
            dbo.x12_transaction_schema.functional_version_id_code,
            dest_x12_organization.x12_organization_ud AS dest_x12_organization_ud,
            dest_x12_organization.x12_organization_uid AS dest_x12_organization_uid,
            src_x12_organization.x12_organization_ud AS src_x12_organization_ud,
            src_x12_organization.x12_organization_uid AS src_x12_organization_uid,
            dbo.x12_interchange_status.x12_interchange_status_ud,
            dbo.x12_interchange_status.x12_interchange_status_nm,
            interchange_date = CAST(SUBSTRING(dbo.x12_interchange.isa09_interchange_date, 3, 2) + '/' + RIGHT(dbo.x12_interchange.isa09_interchange_date, 2) + '/' + LEFT(dbo.x12_interchange.isa09_interchange_date, 2) AS datetime),
            dbo.x12_interchange.x12_interchange_status_id
    FROM    dbo.x12_interchange
    INNER JOIN dbo.x12_functional_group
    ON      dbo.x12_interchange.x12_interchange_id = dbo.x12_functional_group.x12_interchange_id
    INNER JOIN dbo.x12_transaction
    ON      dbo.x12_functional_group.x12_functional_group_id = dbo.x12_transaction.x12_functional_group_id
    INNER JOIN dbo.x12_transaction_schema
    ON      dbo.x12_functional_group.x12_transaction_schema_id = dbo.x12_transaction_schema.x12_transaction_schema_id
    LEFT OUTER JOIN dbo.x12_interchange_status
    ON      dbo.x12_interchange.x12_interchange_status_id = dbo.x12_interchange_status.x12_interchange_status_id
    LEFT OUTER JOIN dbo.x12_organization AS src_x12_organization
    ON      dbo.x12_interchange.src_x12_organization_id = src_x12_organization.x12_organization_id
    LEFT OUTER JOIN dbo.x12_organization AS dest_x12_organization
    ON      dbo.x12_interchange.dest_x12_organization_id = dest_x12_organization.x12_organization_id

GO
