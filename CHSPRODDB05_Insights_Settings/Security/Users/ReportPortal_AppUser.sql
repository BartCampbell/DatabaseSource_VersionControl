IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'reportportal_appuser')
CREATE LOGIN [reportportal_appuser] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [ReportPortal_AppUser] FOR LOGIN [reportportal_appuser]
GO
