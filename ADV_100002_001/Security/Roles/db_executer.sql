CREATE ROLE [db_executer]
AUTHORIZATION [dbo]
EXEC sp_addrolemember N'db_executer', N'INTERNAL\Core.Platform.Team'

EXEC sp_addrolemember N'db_executer', N'INTERNAL\Quality.Team'

EXEC sp_addrolemember N'db_executer', N'INTERNAL\Reporting.Team'

EXEC sp_addrolemember N'db_executer', N'INTERNAL\Submission.Team'
GRANT EXECUTE TO [db_executer]

GO
EXEC sp_addrolemember N'db_executer', N'SSRS_REPORTING'
GO
