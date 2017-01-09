IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\travis.parker')
CREATE LOGIN [INTERNAL\travis.parker] FROM WINDOWS
GO
