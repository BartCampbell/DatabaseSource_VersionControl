IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\IMI.Certification.RO')
CREATE LOGIN [IMIHEALTH\IMI.Certification.RO] FROM WINDOWS
GO
CREATE USER [IMIHEALTH\IMI.Certification.RO] FOR LOGIN [IMIHEALTH\IMI.Certification.RO]
GO
