IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\Scott.Peters')
CREATE LOGIN [INTERNAL\Scott.Peters] FROM WINDOWS
GO
CREATE USER [INTERNAL\scott.peters] FOR LOGIN [INTERNAL\Scott.Peters]
GO
