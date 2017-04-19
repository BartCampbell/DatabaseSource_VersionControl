CREATE ROLE [db_executer]
AUTHORIZATION [dbo]
EXEC sp_addrolemember N'db_executer', N'SSRS_REPORTING'
GRANT EXECUTE TO [db_executer]

GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\brandon.rodman'
GO
