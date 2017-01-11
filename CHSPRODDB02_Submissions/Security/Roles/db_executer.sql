CREATE ROLE [db_executer]
AUTHORIZATION [dbo]
EXEC sp_addrolemember N'db_executer', N'INTERNAL\dawn.carter'
GRANT EXECUTE TO [db_executer]

EXEC sp_addrolemember N'db_executer', N'Internal\Dustin.Resch'


GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\brandon.rodman'
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\dwight.staggs'
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\paul.johnson'
GO
EXEC sp_addrolemember N'db_executer', N'SSRS_REPORTING'
GO
