CREATE ROLE [db_executer]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_executer', N'Insights_User'
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\brandon.rodman'
GO
EXEC sp_addrolemember N'db_executer', N'SSRS_REPORTING'
GO
GRANT EXECUTE TO [db_executer]
