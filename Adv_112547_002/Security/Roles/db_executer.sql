CREATE ROLE [db_executer]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\brandon.rodman'
GO
GRANT EXECUTE TO [db_executer]
