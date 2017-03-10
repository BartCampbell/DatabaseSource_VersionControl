CREATE ROLE [FileImportReporting]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'FileImportReporting', N'pref1_ssrs'
GO
