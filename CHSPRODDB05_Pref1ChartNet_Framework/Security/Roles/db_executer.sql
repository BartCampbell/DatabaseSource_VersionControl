CREATE ROLE [db_executer]
AUTHORIZATION [dbo]
EXEC sp_addrolemember N'db_executer', N'INTERNAL\brandon.rodman'
GRANT EXECUTE TO [db_executer]

GO
EXEC sp_addrolemember N'db_executer', N'SSRS_REPORTING'
GO
