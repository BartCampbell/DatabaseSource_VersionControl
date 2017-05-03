IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\joe.vesneski')
CREATE LOGIN [INTERNAL\joe.vesneski] FROM WINDOWS
GO
CREATE USER [INTERNAL\joe.vesneski] FOR LOGIN [INTERNAL\joe.vesneski]
GO
