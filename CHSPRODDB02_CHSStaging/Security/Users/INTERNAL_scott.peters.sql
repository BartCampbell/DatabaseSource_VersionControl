IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\scott.peters')
CREATE LOGIN [INTERNAL\scott.peters] FROM WINDOWS
GO
CREATE USER [INTERNAL\scott.peters] FOR LOGIN [INTERNAL\scott.peters]
GO
