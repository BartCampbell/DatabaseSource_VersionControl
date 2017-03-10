CREATE ROLE [ProcExecuter]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'ProcExecuter', N'ChartNet_AppUser'
GO
EXEC sp_addrolemember N'ProcExecuter', N'ChartNet_AppUser_Custom'
GO
