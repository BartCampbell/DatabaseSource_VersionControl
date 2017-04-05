IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\IMI.SQL.Reporting.Analysts')
CREATE LOGIN [IMIHEALTH\IMI.SQL.Reporting.Analysts] FROM WINDOWS
GO
CREATE USER [Reporting.Analysts] FOR LOGIN [IMIHEALTH\IMI.SQL.Reporting.Analysts]
GO
