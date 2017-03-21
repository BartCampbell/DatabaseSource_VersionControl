IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'nlp.user')
CREATE LOGIN [nlp.user] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [nlp.user] FOR LOGIN [nlp.user]
GO
