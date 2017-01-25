CREATE ROLE [db_ViewProcedures]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_ViewProcedures', N'IMIHEALTH\IMI.SQL.Developers'
GO
EXEC sp_addrolemember N'db_ViewProcedures', N'IMIHEALTH\Ivette.Villalobos'
GO
EXEC sp_addrolemember N'db_ViewProcedures', N'IMIHEALTH\Janet.Ledbetter'
GO
EXEC sp_addrolemember N'db_ViewProcedures', N'Insights_User'
GO
EXEC sp_addrolemember N'db_ViewProcedures', N'INTERNAL\brandon.rodman'
GO
