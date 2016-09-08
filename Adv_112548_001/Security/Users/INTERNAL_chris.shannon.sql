IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\chris.shannon')
CREATE LOGIN [INTERNAL\chris.shannon] FROM WINDOWS
GO
