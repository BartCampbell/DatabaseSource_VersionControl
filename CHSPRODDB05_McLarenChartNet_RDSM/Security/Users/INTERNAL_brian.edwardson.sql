IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\brian.edwardson')
CREATE LOGIN [INTERNAL\brian.edwardson] FROM WINDOWS
GO
CREATE USER [INTERNAL\brian.edwardson] FOR LOGIN [INTERNAL\brian.edwardson]
GO
