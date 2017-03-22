IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\Matthew.Ellinger')
CREATE LOGIN [INTERNAL\Matthew.Ellinger] FROM WINDOWS
GO
CREATE USER [INTERNAL\Matthew.Ellinger] FOR LOGIN [INTERNAL\Matthew.Ellinger]
GO
