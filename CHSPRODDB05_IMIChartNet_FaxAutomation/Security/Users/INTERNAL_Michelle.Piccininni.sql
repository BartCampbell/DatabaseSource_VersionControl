IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\Michelle.Piccininni')
CREATE LOGIN [INTERNAL\Michelle.Piccininni] FROM WINDOWS
GO
CREATE USER [INTERNAL\Michelle.Piccininni] FOR LOGIN [INTERNAL\Michelle.Piccininni]
GO
