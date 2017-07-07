IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\brent.doolittle')
CREATE LOGIN [INTERNAL\brent.doolittle] FROM WINDOWS
GO
