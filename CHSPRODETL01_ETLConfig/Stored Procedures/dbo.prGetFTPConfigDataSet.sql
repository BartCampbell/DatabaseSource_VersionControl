SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 11/6/2015
--Update 01/18/2017 Adding IsExternal filter  Paul Johnson
--Update 02/16/2017 Adding UseSubfolder Paul Johnson
--Update 03/17/2017 Adding MaxSSl,SSL for task factory new version Paul Johnson
--Update 04/19/2017 Adding AppendName PDJ
-- Description:	Get FTP Config dataset
-- =============================================
CREATE PROCEDURE [dbo].[prGetFTPConfigDataSet]
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
		,ISNULL(ext.Hostname,''),ISNULL(ext.UserName,''),ISNULL(ext.Pword,'')
		,ISNULL(ext.PORT,21),ISNULL(ext.ConnectType,0),ISNULL(ext.SubFolder,'')
		,cfg.UseSubFolder,cfg.IsExternal
		,ISNULL(ext.MAXSSL,2),ISNULL(ext.SSL,2),ISNULL(cfg.AppendName,0)
	from [dbo].[FTPConfig] cfg LEFT OUTER JOIN dbo.FTPExternalParameters ext ON ext.FTPConfigID = cfg.FTPConfigID
	where IsActive=1
	AND cfg.AdvanceIntakeFile = 0
	





END
GO
