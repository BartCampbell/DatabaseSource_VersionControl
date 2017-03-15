SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 11/16/2015
--Update 02/13/2017 Adding IsExternal to WHERE clause PJ
-- Description:	Get Active FTP Outbound configuration dataset
-- =============================================
CREATE PROCEDURE [dbo].[prGetFTPOutboundConfigDataSet]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
Select FTPOutboundID, ClientName, DropOffDirectory, FTPDirectory, ArchiveDirectory, SuccessEmailTo  from [dbo].[FTPOutboundConfig] with(nolock)
where IsActive = 1 AND IsExternal=0
END
GO
