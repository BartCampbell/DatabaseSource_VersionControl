IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\Karla.Shoeboot')
CREATE LOGIN [IMIHEALTH\Karla.Shoeboot] FROM WINDOWS
GO
CREATE USER [IMIHEALTH\Karla.Shoeboot] FOR LOGIN [IMIHEALTH\Karla.Shoeboot]
GO
