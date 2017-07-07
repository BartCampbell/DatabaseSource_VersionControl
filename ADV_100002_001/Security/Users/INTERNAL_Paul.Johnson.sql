IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\Paul.Johnson')
CREATE LOGIN [INTERNAL\Paul.Johnson] FROM WINDOWS
GO
