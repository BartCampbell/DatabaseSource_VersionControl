IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\Phil.Cooper')
CREATE LOGIN [INTERNAL\Phil.Cooper] FROM WINDOWS
GO
CREATE USER [INTERNAL\phil.cooper] FOR LOGIN [INTERNAL\Phil.Cooper]
GO
