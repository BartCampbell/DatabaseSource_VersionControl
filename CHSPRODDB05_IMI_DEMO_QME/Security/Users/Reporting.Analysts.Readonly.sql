IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\IMI.SQL.Reporting.Analysts.ReadOnly')
CREATE LOGIN [IMIHEALTH\IMI.SQL.Reporting.Analysts.ReadOnly] FROM WINDOWS
GO
CREATE USER [Reporting.Analysts.Readonly] FOR LOGIN [IMIHEALTH\IMI.SQL.Reporting.Analysts.ReadOnly]
GO
