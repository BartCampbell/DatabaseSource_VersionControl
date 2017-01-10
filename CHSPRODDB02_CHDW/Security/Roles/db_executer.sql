CREATE ROLE [db_executer]
AUTHORIZATION [dbo]
EXEC sp_addrolemember N'db_executer', N'Internal\Dustin.Resch'
GRANT EXECUTE TO [db_executer]

EXEC sp_addrolemember N'db_executer', N'INTERNAL\brent.doolittle'


GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\brandon.rodman'
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\dwight.staggs'
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\paul.johnson'
GO
