SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 11/6/2015
--Update 2/13/2017 Adding IsExternal to the WHERE clause PJ
-- Description:	Get FTP Config dataset
-- =============================================
CREATE PROCEDURE [dbo].[prGetFTPConfigDataSet_AdvanceIntake_ACK]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select 
		cfg.FTPConfigID, cfg.ClientName, 
		cfg.FTPPath, cfg.ArchivePath, cfg.IncomingPath, 
		cfg.EmailNotification, cfg.CreateDirectory, ACKFile, AdvanceIntakeDumpDir, clientid
	from [dbo].[FTPConfig] cfg
	where IsActive=1
	AND cfg.AdvanceIntakeFile = 1
	AND cfg.ACKFile=1
	AND cfg.IsExternal =0


END
GO
