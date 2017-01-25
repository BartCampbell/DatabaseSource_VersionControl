IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\Lindsay.Dermer')
CREATE LOGIN [IMIHEALTH\Lindsay.Dermer] FROM WINDOWS
GO
CREATE USER [IMIHEALTH\Lindsay.Dermer] FOR LOGIN [IMIHEALTH\Lindsay.Dermer]
GO
