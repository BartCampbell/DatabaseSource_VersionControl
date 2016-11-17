SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_x12_interchange_error]
AS
SELECT DISTINCT 
                      TOP 100 PERCENT dbo.x12_interchange.x12_interchange_id, dbo.x12_functional_group.x12_functional_group_id, 
                      dbo.x12_transaction.x12_transaction_id, dbo.x12_transaction.st02_transaction_control_no, dbo.x12_transaction.st01_transaction_id_code, 
                      dbo.x12_functional_group.gs08_version_id_code, dbo.x12_functional_group.gs07_resp_agency_code, 
                      dbo.x12_functional_group.gs06_group_control_no, dbo.x12_functional_group.gs05_time, dbo.x12_functional_group.gs04_date, 
                      dbo.x12_functional_group.gs03_app_receiver_code, dbo.x12_functional_group.gs02_app_sender_code, 
                      dbo.x12_functional_group.gs01_functional_id_code, dbo.x12_interchange.isa15_usage_indicator, dbo.x12_interchange.isa13_control_no, 
                      dbo.x12_interchange.isa12_control_version_no, dbo.x12_interchange.isa11_control_standards_id, dbo.x12_interchange.isa10_interchange_time, 
                      dbo.x12_interchange.isa09_interchange_date, dbo.x12_interchange.isa08_receiver_id, dbo.x12_interchange.isa07_receiver_id_qual, 
                      dbo.x12_interchange.isa06_sender_id, dbo.x12_interchange.isa05_sender_id_qual, dbo.x12_interchange.isa04_security_info, 
                      dbo.x12_interchange.isa03_security_info_qual, dbo.x12_interchange.isa02_auth_info, dbo.x12_interchange.isa01_auth_info_qual, 
                      dbo.x12_interchange.isa14_ack_requested, dbo.x12_interchange_message.loop_id, dbo.x12_interchange_message.segment_id, 
                      dbo.x12_interchange_message.segment_pos_in_tran, dbo.x12_interchange_message.element_pos_in_segment, 
                      dbo.x12_interchange_message.element_no, dbo.x12_interchange_message.element_value, dbo.x12_interchange_message.message_code, 
                      dbo.x12_interchange_message.message_text, dbo.x12_transaction.error AS transaction_error, 
                      dbo.x12_functional_group.error AS functional_group_error, dbo.x12_interchange.error AS interchange_error
FROM         dbo.x12_transaction INNER JOIN
                      dbo.x12_functional_group ON dbo.x12_functional_group.x12_functional_group_id = dbo.x12_transaction.x12_functional_group_id INNER JOIN
                      dbo.x12_interchange ON dbo.x12_interchange.x12_interchange_id = dbo.x12_functional_group.x12_interchange_id LEFT OUTER JOIN
                      dbo.x12_interchange_message ON dbo.x12_interchange.x12_interchange_uid = dbo.x12_interchange_message.x12_interchange_uid
GROUP BY dbo.x12_transaction.st02_transaction_control_no, dbo.x12_transaction.st01_transaction_id_code, dbo.x12_functional_group.gs08_version_id_code, 
                      dbo.x12_functional_group.gs07_resp_agency_code, dbo.x12_functional_group.gs06_group_control_no, dbo.x12_functional_group.gs05_time, 
                      dbo.x12_functional_group.gs04_date, dbo.x12_functional_group.gs03_app_receiver_code, dbo.x12_functional_group.gs02_app_sender_code, 
                      dbo.x12_functional_group.gs01_functional_id_code, dbo.x12_interchange.isa15_usage_indicator, dbo.x12_interchange.isa13_control_no, 
                      dbo.x12_interchange.isa12_control_version_no, dbo.x12_interchange.isa11_control_standards_id, dbo.x12_interchange.isa10_interchange_time, 
                      dbo.x12_interchange.isa09_interchange_date, dbo.x12_interchange.isa08_receiver_id, dbo.x12_interchange.isa07_receiver_id_qual, 
                      dbo.x12_interchange.isa06_sender_id, dbo.x12_interchange.isa05_sender_id_qual, dbo.x12_interchange.isa04_security_info, 
                      dbo.x12_interchange.isa03_security_info_qual, dbo.x12_interchange.isa02_auth_info, dbo.x12_interchange.isa01_auth_info_qual, 
                      dbo.x12_transaction.x12_transaction_id, dbo.x12_interchange.isa14_ack_requested, dbo.x12_interchange_message.loop_id, 
                      dbo.x12_interchange_message.segment_id, dbo.x12_interchange_message.segment_pos_in_tran, 
                      dbo.x12_interchange_message.element_pos_in_segment, dbo.x12_interchange_message.element_no, 
                      dbo.x12_interchange_message.element_value, dbo.x12_interchange_message.message_code, dbo.x12_interchange_message.message_text, 
                      dbo.x12_transaction.error, dbo.x12_functional_group.error, dbo.x12_interchange.error, dbo.x12_interchange.x12_interchange_id, 
                      dbo.x12_functional_group.x12_functional_group_id
HAVING      (dbo.x12_transaction.error = 1) OR
                      (dbo.x12_functional_group.error = 1) OR
                      (dbo.x12_interchange.error = 1)
GO
