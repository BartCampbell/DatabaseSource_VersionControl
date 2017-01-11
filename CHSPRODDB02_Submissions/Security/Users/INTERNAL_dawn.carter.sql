IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\dawn.carter')
CREATE LOGIN [INTERNAL\dawn.carter] FROM WINDOWS
GO
CREATE USER [INTERNAL\dawn.carter] FOR LOGIN [INTERNAL\dawn.carter]
GO
