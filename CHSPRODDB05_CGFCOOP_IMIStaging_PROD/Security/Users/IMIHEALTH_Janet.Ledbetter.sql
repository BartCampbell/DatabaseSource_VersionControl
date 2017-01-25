IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\Janet.Ledbetter')
CREATE LOGIN [IMIHEALTH\Janet.Ledbetter] FROM WINDOWS
GO
CREATE USER [IMIHEALTH\Janet.Ledbetter] FOR LOGIN [IMIHEALTH\Janet.Ledbetter]
GO
