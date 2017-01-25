IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'Insights_User')
CREATE LOGIN [Insights_User] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [Insights_User] FOR LOGIN [Insights_User]
GO
