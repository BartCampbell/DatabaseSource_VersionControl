CREATE ROLE [db_executer]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\brandon.rodman'
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\brent.doolittle'
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\CHS_ReportingUsers'
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\CHSSQLDevOps'
GO
EXEC sp_addrolemember N'db_executer', N'Internal\Dustin.Resch'
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\dwight.staggs'
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\michael.vlk'
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\paul.johnson'
GO
EXEC sp_addrolemember N'db_executer', N'SSRS_REPORTING'
GO
GRANT EXECUTE TO [db_executer]
