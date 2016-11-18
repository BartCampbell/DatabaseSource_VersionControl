IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'jira')
CREATE LOGIN [jira] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [jira] FOR LOGIN [jira]
GO
