CREATE ROLE [FileImportReporting]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'FileImportReporting', N'scv_ssrs'
GO
