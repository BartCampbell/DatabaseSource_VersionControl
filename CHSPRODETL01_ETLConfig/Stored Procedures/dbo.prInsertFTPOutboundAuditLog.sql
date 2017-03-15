SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prInsertFTPOutboundAuditLog]
	-- Add the parameters for the stored procedure here
	@FTPOutboundConfigID int,
	@SourceDirectory varchar(1000),
	@ArchiveDirectory varchar(1000), 
	@FTPDirectory varchar(1000), 
	@Filename varchar(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

INSERT INTO [dbo].[FTPOutboundAuditLog]
           ([FTPOutboundConfigID]
           ,[SourceDirectory]
           ,[ArchiveDirectory]
           ,[FTPDirectory]
           ,[FileName])
     VALUES
           (@FTPOutboundConfigID, 
		   @SourceDirectory, 
		   @ArchiveDirectory, 
		   @FTPDirectory, 
		   @FileName)

END
GO
