CREATE ROLE [Reporting]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'Reporting', N'imihedisdemo_ssrs'
GO
