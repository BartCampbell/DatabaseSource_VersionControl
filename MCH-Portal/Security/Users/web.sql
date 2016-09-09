IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'web')
CREATE LOGIN [web] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [web] FOR LOGIN [web]
GO
