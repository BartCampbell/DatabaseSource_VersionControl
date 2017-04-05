CREATE ROLE [Analyst]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'Analyst', N'Reporting.Analysts'
GO
EXEC sp_addrolemember N'Analyst', N'Reporting.Analysts.Readonly'
GO
