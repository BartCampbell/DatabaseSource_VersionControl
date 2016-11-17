SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_x12_997_detail]
AS
SELECT     dbo.x12_transaction.st02_transaction_control_no, dbo.x12_transaction.st01_transaction_id_code, dbo.x12_functional_group.gs08_version_id_code, 
                      dbo.x12_functional_group.gs07_resp_agency_code, dbo.x12_functional_group.gs06_group_control_no, dbo.x12_functional_group.gs05_time, 
                      dbo.x12_functional_group.gs04_date, dbo.x12_functional_group.gs03_app_receiver_code, dbo.x12_functional_group.gs02_app_sender_code, 
                      dbo.x12_functional_group.gs01_functional_id_code, dbo.x12_interchange.isa15_usage_indicator, dbo.x12_interchange.isa13_control_no, 
                      dbo.x12_interchange.isa12_control_version_no, dbo.x12_interchange.isa11_control_standards_id, dbo.x12_interchange.isa10_interchange_time, 
                      dbo.x12_interchange.isa09_interchange_date, dbo.x12_interchange.isa08_receiver_id, dbo.x12_interchange.isa07_receiver_id_qual, 
                      dbo.x12_interchange.isa06_sender_id, dbo.x12_interchange.isa05_sender_id_qual, dbo.x12_interchange.isa04_security_info, 
                      dbo.x12_interchange.isa03_security_info_qual, dbo.x12_interchange.isa02_auth_info, dbo.x12_interchange.isa01_auth_info_qual, 
                      dbo.x12_transaction.x12_transaction_id, dbo.x12_interchange.isa14_ack_requested, dbo.x12_997_functional_ack.ak301_segment_id_code, 
                      dbo.x12_997_functional_ack.ak304_segment_syntax_error_code, dbo.x12_997_functional_ack.ak501_tran_ack_code, 
                      dbo.x12_997_functional_ack.ak902_num_tran_sets, dbo.x12_997_functional_ack.ak903_num_rcvd_tran_sets, 
                      dbo.x12_997_functional_ack.ak904_num_accept_tran_sets, dbo.x12_997_functional_ack.ak202_st02_transaction_control_no, 
                      dbo.x12_997_functional_ack.ak102_gs06_group_control_no, src_x12_interchange.isa06_sender_id AS src_isa06_sender_id, 
                      src_x12_interchange.isa08_receiver_id AS src_isa08_receiver_id, src_x12_interchange.isa13_control_no AS src_isa13_control_no, 
                      dbo.x12_997_functional_ack.src_x12_functional_group_id, src_x12_transaction.st01_transaction_id_code AS src_st01_transaction_id_code, 
                      src_x12_transaction.st02_transaction_control_no AS src_st02_transaction_control_no, 
                      src_x12_transaction.x12_transaction_id AS src_x12_transaction_id, dbo.x12_997_functional_ack.ak302_segment_pos, 
                      dbo.x12_997_functional_ack.ak303_loop_id_code, dbo.x12_997_functional_ack.ak401_element_pos, 
                      dbo.x12_997_functional_ack.ak402_data_element_ref_no, dbo.x12_997_functional_ack.ak403_element_syntax_error_code, 
                      dbo.x12_997_functional_ack.ak404_copy_of_bad_element, dbo.x12_997_functional_ack.ak502_tran_syntax_error_code, 
                      dbo.x12_997_functional_ack.ak504_tran_syntax_error_code, dbo.x12_997_functional_ack.ak503_tran_syntax_error_code, 
                      dbo.x12_997_functional_ack.ak506_tran_syntax_error_code, dbo.x12_997_functional_ack.ak505_tran_syntax_error_code, 
                      dbo.x12_997_functional_ack.ak901_funct_ack_code, dbo.x12_997_functional_ack.ak905_func_syntax_error_code, 
                      dbo.x12_997_functional_ack.ak906_func_syntax_error_code, dbo.x12_997_functional_ack.ak907_func_syntax_error_code, 
                      dbo.x12_997_functional_ack.ak908_func_syntax_error_code, dbo.x12_997_functional_ack.ak909_func_syntax_error_code, 
                      dbo.x12_997_functional_ack.ak201_st01_transaction_id_code
FROM         dbo.x12_997_functional_ack INNER JOIN
                      dbo.x12_transaction ON dbo.x12_997_functional_ack.x12_transaction_id = dbo.x12_transaction.x12_transaction_id INNER JOIN
                      dbo.x12_functional_group ON dbo.x12_functional_group.x12_functional_group_id = dbo.x12_transaction.x12_functional_group_id INNER JOIN
                      dbo.x12_interchange ON dbo.x12_interchange.x12_interchange_id = dbo.x12_functional_group.x12_interchange_id LEFT OUTER JOIN
                      dbo.x12_functional_group src_x12_functional_group ON 
                      dbo.x12_997_functional_ack.src_x12_functional_group_id = src_x12_functional_group.x12_functional_group_id LEFT OUTER JOIN
                      dbo.x12_transaction src_x12_transaction ON 
                      src_x12_functional_group.x12_functional_group_id = src_x12_transaction.x12_functional_group_id LEFT OUTER JOIN
                      dbo.x12_interchange src_x12_interchange ON src_x12_functional_group.x12_interchange_id = src_x12_interchange.x12_interchange_id
GROUP BY dbo.x12_transaction.st02_transaction_control_no, dbo.x12_transaction.st01_transaction_id_code, dbo.x12_functional_group.gs08_version_id_code, 
                      dbo.x12_functional_group.gs07_resp_agency_code, dbo.x12_functional_group.gs06_group_control_no, dbo.x12_functional_group.gs05_time, 
                      dbo.x12_functional_group.gs04_date, dbo.x12_functional_group.gs03_app_receiver_code, dbo.x12_functional_group.gs02_app_sender_code, 
                      dbo.x12_functional_group.gs01_functional_id_code, dbo.x12_interchange.isa15_usage_indicator, dbo.x12_interchange.isa13_control_no, 
                      dbo.x12_interchange.isa12_control_version_no, dbo.x12_interchange.isa11_control_standards_id, dbo.x12_interchange.isa10_interchange_time, 
                      dbo.x12_interchange.isa09_interchange_date, dbo.x12_interchange.isa08_receiver_id, dbo.x12_interchange.isa07_receiver_id_qual, 
                      dbo.x12_interchange.isa06_sender_id, dbo.x12_interchange.isa05_sender_id_qual, dbo.x12_interchange.isa04_security_info, 
                      dbo.x12_interchange.isa03_security_info_qual, dbo.x12_interchange.isa02_auth_info, dbo.x12_interchange.isa01_auth_info_qual, 
                      dbo.x12_transaction.x12_transaction_id, dbo.x12_interchange.isa14_ack_requested, dbo.x12_997_functional_ack.ak301_segment_id_code, 
                      dbo.x12_997_functional_ack.ak304_segment_syntax_error_code, dbo.x12_997_functional_ack.ak501_tran_ack_code, 
                      dbo.x12_997_functional_ack.ak202_st02_transaction_control_no, dbo.x12_997_functional_ack.ak102_gs06_group_control_no, 
                      src_x12_interchange.isa06_sender_id, src_x12_interchange.isa08_receiver_id, src_x12_interchange.isa13_control_no, 
                      dbo.x12_997_functional_ack.src_x12_functional_group_id, src_x12_transaction.st01_transaction_id_code, 
                      src_x12_transaction.st02_transaction_control_no, src_x12_transaction.x12_transaction_id, dbo.x12_997_functional_ack.ak902_num_tran_sets, 
                      dbo.x12_997_functional_ack.ak903_num_rcvd_tran_sets, dbo.x12_997_functional_ack.ak904_num_accept_tran_sets, 
                      dbo.x12_997_functional_ack.ak302_segment_pos, dbo.x12_997_functional_ack.ak303_loop_id_code, 
                      dbo.x12_997_functional_ack.ak401_element_pos, dbo.x12_997_functional_ack.ak402_data_element_ref_no, 
                      dbo.x12_997_functional_ack.ak403_element_syntax_error_code, dbo.x12_997_functional_ack.ak404_copy_of_bad_element, 
                      dbo.x12_997_functional_ack.ak502_tran_syntax_error_code, dbo.x12_997_functional_ack.ak504_tran_syntax_error_code, 
                      dbo.x12_997_functional_ack.ak503_tran_syntax_error_code, dbo.x12_997_functional_ack.ak506_tran_syntax_error_code, 
                      dbo.x12_997_functional_ack.ak505_tran_syntax_error_code, dbo.x12_997_functional_ack.ak901_funct_ack_code, 
                      dbo.x12_997_functional_ack.ak905_func_syntax_error_code, dbo.x12_997_functional_ack.ak906_func_syntax_error_code, 
                      dbo.x12_997_functional_ack.ak907_func_syntax_error_code, dbo.x12_997_functional_ack.ak908_func_syntax_error_code, 
                      dbo.x12_997_functional_ack.ak909_func_syntax_error_code, dbo.x12_997_functional_ack.ak201_st01_transaction_id_code
GO
