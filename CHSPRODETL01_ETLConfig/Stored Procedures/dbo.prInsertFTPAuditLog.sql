SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 11/16/2015	
-- Description:	Insert FTP Audit Log Record
-- =============================================
CREATE PROCEDURE [dbo].[prInsertFTPAuditLog]
	-- Add the parameters for the stored procedure here
@FTPConfigID int, 
@FTPPath varchar(1000),
@ArchivePath varchar(1000),
@IncomingPath varchar(1000),
@Filename varchar(1000),
@ClientID VARCHAR(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here


INSERT INTO [dbo].[FTPInboundAuditLog]
           ([FTPConfigID]
           ,[FTPPath]
           ,[ArchivePath]
           ,[IncomingPath]
           ,[FileName]
		   ,[ClientID])
     VALUES
           (@FTPConfigID,
		   @FTPPath,
		   @ArchivePath, 
		   @IncomingPath, 
		   @FileName,
		   @ClientID)


END


GO
