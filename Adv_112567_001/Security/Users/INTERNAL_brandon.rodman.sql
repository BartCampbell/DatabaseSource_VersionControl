IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\brandon.rodman')
CREATE LOGIN [INTERNAL\brandon.rodman] FROM WINDOWS
GO
