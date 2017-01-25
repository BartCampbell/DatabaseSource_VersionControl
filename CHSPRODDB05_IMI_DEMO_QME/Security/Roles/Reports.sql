CREATE ROLE [Reports]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'Reports', N'cca_ssrs'
GO
EXEC sp_addrolemember N'Reports', N'imihedisdemo_ssrs'
GO
