SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 11/17/2015
-- Description:	Get list of files to be deleted. 
-- =============================================
CREATE PROCEDURE [dbo].[prFTPOutboundFilesToBeDeleted]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

     Select FTPOutBoundAuditID,[FTPDirectory] + '\' + [FileName] as 'FilePath' from FTPOutboundAuditLog
     where LogDate < Getdate() - 1 
	 and IsDeletedFromFTP = 0
END
GO
