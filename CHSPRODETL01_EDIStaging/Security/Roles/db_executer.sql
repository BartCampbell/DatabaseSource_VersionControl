CREATE ROLE [db_executer]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\CHSSQLDevOps'
GO
GRANT EXECUTE TO [db_executer]
