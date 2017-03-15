SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 02/10/2017
-- Description:	Get Active External FTP Outbound configuration dataset - based on [dbo].[prGetFTPOutboundConfigDataSet]
-- =============================================
CREATE PROCEDURE [dbo].[prGetFTPOutboundExternalConfigDataSet]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
Select a.FTPOutboundID, a.ClientName, a.DropOffDirectory,ISNULL(a.FTPDirectory,''),  a.ArchiveDirectory, a.SuccessEmailTo  ,ISNULL(b.Hostname,''),ISNULL(b.UserName,''),ISNULL(b.Pword,''),ISNULL(b.ConnectType,''),ISNULL(b.PORT,''),ISNULL(b.SubFolder,''),ISNULL(a.IsExternal,0)
FROM [dbo].[FTPOutboundConfig]  a with(nolock)
LEFT OUTER JOIN dbo.FTPExternalOutboundParameters b
ON b.FTPOutboundID = a.FTPOutboundID
where a.IsActive = 1 

END

GO
