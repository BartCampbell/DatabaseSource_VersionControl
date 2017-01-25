IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\htms.sql.dev')
CREATE LOGIN [IMIHEALTH\htms.sql.dev] FROM WINDOWS
GO
CREATE USER [IMIHEALTH\htms.sql.dev] FOR LOGIN [IMIHEALTH\htms.sql.dev]
GO
