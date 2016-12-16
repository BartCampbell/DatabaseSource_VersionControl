IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\sajid.ali')
CREATE LOGIN [INTERNAL\sajid.ali] FROM WINDOWS
GO
CREATE USER [INTERNAL\sajid.ali] FOR LOGIN [INTERNAL\sajid.ali]
GO
