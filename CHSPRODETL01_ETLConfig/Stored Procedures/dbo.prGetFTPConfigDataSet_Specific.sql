SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 11/6/2015
-- Description:	Get FTP Config dataset
-- =============================================
CREATE PROCEDURE [dbo].[prGetFTPConfigDataSet_Specific]
	-- Add the parameters for the stored procedure here
	@FTPConfigID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select 
		cfg.FTPConfigID, cfg.ClientName, 
		cfg.FTPPath, cfg.ArchivePath, cfg.IncomingPath, 
		cfg.EmailNotification, cfg.CreateDirectory, ACKFile, AdvanceIntakeDumpDir, ClientID
	from [dbo].[FTPConfig] cfg
	WHERE-- IsActive=1 and
	 cfg.FTPConfigID=@FTPConfigID


END
GO
