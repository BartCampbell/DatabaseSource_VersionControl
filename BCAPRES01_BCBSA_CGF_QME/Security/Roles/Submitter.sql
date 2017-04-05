CREATE ROLE [Submitter]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'Submitter', N'measureengine_submitter'
GO
