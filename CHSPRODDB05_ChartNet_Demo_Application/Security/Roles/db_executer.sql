CREATE ROLE [db_executer]
AUTHORIZATION [dbo]
EXEC sp_addrolemember N'db_executer', N'INTERNAL\brandon.rodman'

EXEC sp_addrolemember N'db_executer', N'INTERNAL\Melody.Jones'
GRANT EXECUTE TO [db_executer]

GO
EXEC sp_addrolemember N'db_executer', N'SSRS_REPORTING'
GO
