SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 2/9/2017
-- Description:	Get External FTP Config dataset based on [dbo].[prGetFTPConfigDataSet]
-- =============================================
CREATE PROCEDURE [dbo].[prGetFTPConfigExternalDataSet]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Get FTPConfig data
	Select 
		cfg.FTPConfigID, cfg.ClientName, 
		cfg.FTPPath, cfg.ArchivePath, cfg.IncomingPath, 
		cfg.EmailNotification, cfg.CreateDirectory, ACKFile, ClientID
		,ext.Hostname,ext.UserName,ext.Pword,ext.PORT,ext.ConnectType,ext.SubFolder
	from [dbo].[FTPConfig] cfg INNER JOIN dbo.FTPExternalParameters ext ON ext.FTPConfigID = cfg.FTPConfigID
	where IsActive=1
	AND cfg.AdvanceIntakeFile = 0
	AND cfg.IsExternal = 1





END

GO
