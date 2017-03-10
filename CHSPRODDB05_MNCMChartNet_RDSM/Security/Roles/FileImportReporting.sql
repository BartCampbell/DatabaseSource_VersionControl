CREATE ROLE [FileImportReporting]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'FileImportReporting', N'hsag_ssrs'
GO
EXEC sp_addrolemember N'FileImportReporting', N'pref1_ssrs'
GO
EXEC sp_addrolemember N'FileImportReporting', N'scv_ssrs'
GO
