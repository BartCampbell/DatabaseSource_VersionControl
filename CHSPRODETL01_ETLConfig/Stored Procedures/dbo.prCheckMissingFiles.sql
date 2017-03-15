SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 09/29/2016
-- Description:	Check to see if files are missing
-- Sample: exec dbo.prCheckMissingFiles 'CCAI_PROD', '720', '100002'
-- =============================================
CREATE PROCEDURE [dbo].[prCheckMissingFiles]
	-- Add the parameters for the stored procedure here
	@FilenameFormatString varchar(1000),
	@Hours INT=720,
	@ClientID VARCHAR(20)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

		SELECT COUNT(1) AS [Count], lg.LogDate
		INTO #FTPAudit
		FROM dbo.FTPInboundAuditLog lg
		WHERE lg.FileName LIKE '%'+@FilenameFormatString+'%'
		AND lg.LogDate > dateadd(hh,-@Hours,getdate())
		AND lg.ClientID=@ClientID
		GROUP BY lg.LogDate
		ORDER BY lg.LogDate DESC

		DECLARE @Count INT 
		SET @Count = (SELECT COUNT(1) FROM #FTPAudit)

		IF(@Count=0)
			BEGIN
				SELECT TOP 1 '0', lg.LogDate
				FROM dbo.FTPInboundAuditLog lg
				WHERE lg.FileName LIKE '%'+@FilenameFormatString+'%'
				--AND lg.LogDate > dateadd(hh,-@Hours,getdate())
				AND lg.ClientID=@ClientID
				GROUP BY lg.LogDate
				ORDER BY lg.LogDate DESC
			END
			ELSE
            BEGIN
				SELECT * FROM #FTPAudit
			END
        

END
GO
