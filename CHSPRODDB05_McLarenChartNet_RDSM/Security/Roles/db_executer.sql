CREATE ROLE [db_executer]
AUTHORIZATION [dbo]
EXEC sp_addrolemember N'db_executer', N'INTERNAL\brandon.rodman'
GRANT EXECUTE TO [db_executer]

GO
EXEC sp_addrolemember N'db_executer', N'IMIHEALTH\George.Graves'
GO
EXEC sp_addrolemember N'db_executer', N'IMIHEALTH\IMI.SQL.Developers'
GO
EXEC sp_addrolemember N'db_executer', N'IMIHEALTH\Latisha.Fernandez'
GO
EXEC sp_addrolemember N'db_executer', N'INTERNAL\Latisha.Fernandez'
GO
