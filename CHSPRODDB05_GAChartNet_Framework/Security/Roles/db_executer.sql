CREATE ROLE [db_executer]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_executer', N'SSRS_REPORTING'
GO
GRANT EXECUTE TO [db_executer]
