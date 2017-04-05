IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\IMI.Reference.Modify')
CREATE LOGIN [IMIHEALTH\IMI.Reference.Modify] FROM WINDOWS
GO
CREATE USER [IMIHEALTH\IMI.Reference.Modify] FOR LOGIN [IMIHEALTH\IMI.Reference.Modify]
GO
