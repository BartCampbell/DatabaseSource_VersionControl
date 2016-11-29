IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'Web')
CREATE LOGIN [Web] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [web] FOR LOGIN [Web]
GO
