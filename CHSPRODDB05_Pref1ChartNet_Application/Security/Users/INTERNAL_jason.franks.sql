IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\jason.franks')
CREATE LOGIN [INTERNAL\jason.franks] FROM WINDOWS
GO
CREATE USER [INTERNAL\jason.franks] FOR LOGIN [INTERNAL\jason.franks]
GO
