IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\Ivette.Villalobos')
CREATE LOGIN [IMIHEALTH\Ivette.Villalobos] FROM WINDOWS
GO
CREATE USER [IMIHEALTH\Ivette.Villalobos] FOR LOGIN [IMIHEALTH\Ivette.Villalobos]
GO
