SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Monitor the threads for a given session. Send notifications when needed.
Use:

DECLARE @FileLogSessionID INT = 2000002
EXEC CHSStaging.etl.spThreadWatcher @FileLogSessionID, 1

SELECT * FROM etl.ThreadLog WHERE FileLogSessionID = @FileLogSessionID


Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2017-05-05	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [etl].[spThreadWatcher] (
	@FileLogSessionID INT
	,@Debug INT = 0
	)
AS
BEGIN
	SET NOCOUNT ON
/*
	,CASE [status]
		WHEN 1 THEN 'Created'
		WHEN 2 THEN 'Running'
		WHEN 3 THEN 'Canceled'
		WHEN 4 THEN 'Failed'
		WHEN 5 THEN 'Pending'
		WHEN 6 THEN 'Ended unexpectedly'
		WHEN 7 THEN 'Succeeded'
		WHEN 8 THEN 'Stopping'
		WHEN 9 THEN 'Completed'
		ELSE 'Unknown'
		END
*/
	DECLARE
		
		@NewFailure INT = 0
		,@Completed INT = 0

	IF OBJECT_ID('#ThreadLogCur') IS NOT NULL
		DROP TABLE #ThreadLogCur

	SELECT
		ThreadLogID
		,tl.Thread
		,tl.StatusCd AS StatusCdPrev 
		,sx.status AS StatusCdCur
	INTO #ThreadLogCur
	FROM etl.ThreadLog tl
	LEFT OUTER JOIN SSISDB.catalog.executions sx 
		ON tl.ExecutionId = sx.execution_id
	WHERE 1=1
		AND tl.FileLogSessionID = @FileLogSessionID

	-- Check for new Error status
	IF EXISTS(SELECT 1 
				FROM #ThreadLogCur 
				WHERE 1=1
					AND StatusCdPrev <> StatusCdCur
					AND StatusCdCur IN (3,4,6)
				)
		SET @NewFailure = 1

	-- Check for Completion status
	IF NOT EXISTS(SELECT 1 
				FROM #ThreadLogCur 
				WHERE 1=1
					AND StatusCdCur NOT IN (4,7)
				)
		SET @Completed = 1

	-- Send notification message if needed
	IF (@NewFailure = 1 OR @Completed = 1) OR @Debug >= 1
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
			@mailitem_id INT,
			@xml NVARCHAR(MAX)
 
		SELECT @recipients = 'Michael.Vlk@CentauriHS.com'

		SELECT @subject = 'ETLFileLoader Results for Session: ' + CAST(@FileLogSessionID AS NVARCHAR)
							 + ': '  + (	SELECT DISTINCT zfs.FileSetDesc
											 FROM etl.FileLog zfl
											 INNER JOIN etl.FileConfig zfc ON zfl.FileConfigID = zfc.FileConfigID
											 INNER JOIN etl.FileSet zfs ON zfc.FileSetID = zfs.FileSetID
											 WHERE zfl.FileLogSessionID = @FileLogSessionID
											)

		SELECT @body = '<p><span style="color: #003366;"><strong>Session Started:</strong></span>' 
							+ ' ' + CAST((SELECT zfls.FileLogSessionDate FROM etl.FileLogSession zfls WHERE zfls.FileLogSessionID = @FileLogSessionID) AS VARCHAR)
							+ '</p>'
						+ '<p><span style="color: #003366;"><strong>Status:</strong></span>' 
							+ ' ' + CASE
										WHEN @NewFailure = 1 THEN 'Failure'
										WHEN @Completed = 1 THEN 'Complete'
										ELSE '!!!Unknown!!!'
										END
							+ '</p>'
						+ '<p>&nbsp;</p>'

		SET @xml = CAST ((
			SELECT 
				FileLogID AS 'td'
				,'',FileNameIntake AS 'td'
				,'',fl.RowCntRDSM AS 'td'
			FROM etl.FileLog fl
			WHERE FileLogSessionID = @FileLogSessionID
			ORDER BY FileNameIntake
			FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))

		SET @body = @body 
					+ '<html><body><H3>File List</H3>
						<table border = 1> 
						<tr>
							<th> File Log ID </th> <th> File Name </th> <th> Row Count </th>
						</tr>'    

		SET @body = @body + @xml +'</table></body></html>'

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

	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	-- If not complete, wait a minute and setup next watcher job execution

	IF @Completed = 0
	BEGIN
		WAITFOR DELAY '00:01' -- TODO: Probably not the best way to do this... 
		DECLARE @ExecutionStatus INT
		EXEC etl.spRunETLFileLoaderThreadWatcher
			@FileLogSessionID
			,@ExecutionStatus OUTPUT
	END
END
GO
