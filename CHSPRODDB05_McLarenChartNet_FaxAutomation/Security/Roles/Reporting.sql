CREATE ROLE [Reporting]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'Reporting', N'coaccess_ssrs'
GO
EXEC sp_addrolemember N'Reporting', N'hsag_ssrs'
GO
EXEC sp_addrolemember N'Reporting', N'imihedisdemo_ssrs'
GO
EXEC sp_addrolemember N'Reporting', N'pref1_ssrs'
GO
EXEC sp_addrolemember N'Reporting', N'scv_ssrs'
GO
