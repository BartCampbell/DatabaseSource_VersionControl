SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****************************************************************************************************************************************************
Description:	
Use:

EXEC CHSStaging.etl.spETLFileLoaderNotifyResult 
	@FileLogSessionID = 1000002

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2017-01-27	Michael Vlk			- CREATE
****************************************************************************************************************************************************/
CREATE PROCEDURE [etl].[spETLFileLoaderNotifyResult] (
	@FileLogSessionID INT
	)
AS
BEGIN
	
	DECLARE
		@profile_name VARCHAR(255) = 'CHSMail',
		@recipients VARCHAR(MAX),
		@copy_recipients VARCHAR(MAX),
		@blind_copy_recipient VARCHAR(MAX),
		@from_address VARCHAR(MAX),
		@reply_to VARCHAR(MAX),
		@subject NVARCHAR(255),
		@body NVARCHAR(MAX),
		@body_format VARCHAR(20) = 'HTML', -- TEXT / HTML 
		@importance VARCHAR(6) = 'Normal', -- Normal / Low / High
		@sensitivity VARCHAR(12) = 'Normal', -- Normal / Personal / Private / Confidential
		@file_attachments NVARCHAR(MAX),
		@query NVARCHAR(MAX),
		@execute_query_database VARCHAR(255),
		@attach_query_result_as_file BIT,
		@query_attachment_filename NVARCHAR(255),
		@query_result_header BIT,
		@query_result_width INT,
		@query_result_separator CHAR(1),
		@exclude_query_output BIT,
		@append_query_error BIT,
		@query_no_truncate BIT,
		@query_result_no_padding BIT,
		@mailitem_id INT
 
	SELECT @recipients = 'Michael.Vlk@CentauriHS.com'
	SELECT @subject = 'ETLFileLoader Results for Session: ' + CAST(@FileLogSessionID AS NVARCHAR)
	SELECT @body = 'Body here'

	EXEC msdb.dbo.sp_send_dbmail 
		@profile_name = @profile_name,
		@recipients = @recipients,
		--@copy_recipients = @copy_recipients,
		--@blind_copy_recipient = @blind_copy_recipient,
		--@from_address = @from_address,
		--@reply_to = @reply_to,
		@subject = @subject,
		@body = @body,
		@body_format = @body_format,
		@importance = @importance,
		@sensitivity = @sensitivity,
		--@file_attachments = @file_attachments,
		--@query = @query,
		--@execute_query_database = @execute_query_database,
		--@attach_query_result_as_file = @attach_query_result_as_file,
		--@query_attachment_filename = @query_attachment_filename,
		--@query_result_header = @query_result_header,
		--@query_result_width = @query_result_width,
		--@query_result_separator = @query_result_separator,
		--@exclude_query_output = @exclude_query_output,
		--@append_query_error = @append_query_error,
		--@query_no_truncate = @query_no_truncate,
		--@query_result_no_padding = @query_result_no_padding,
		@mailitem_id = @mailitem_id OUTPUT

END


GO
