IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\michelle.miller')
CREATE LOGIN [INTERNAL\michelle.miller] FROM WINDOWS
GO
CREATE USER [INTERNAL\michelle.miller] FOR LOGIN [INTERNAL\michelle.miller]
GO
