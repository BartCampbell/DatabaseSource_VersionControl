IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\IMI.SQL.Developers')
CREATE LOGIN [IMIHEALTH\IMI.SQL.Developers] FROM WINDOWS
GO
CREATE USER [IMIHEALTH\IMI.SQL.Developers] FOR LOGIN [IMIHEALTH\IMI.SQL.Developers]
GO
GRANT EXECUTE TO [IMIHEALTH\IMI.SQL.Developers]
