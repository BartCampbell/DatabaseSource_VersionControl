IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\Michelle.Piccininni')
CREATE LOGIN [IMIHEALTH\Michelle.Piccininni] FROM WINDOWS
GO
CREATE USER [IMIHEALTH\Michelle.Piccininni] FOR LOGIN [IMIHEALTH\Michelle.Piccininni]
GO
