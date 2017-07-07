IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\Matthew.Ellinger')
CREATE LOGIN [INTERNAL\Matthew.Ellinger] FROM WINDOWS
GO
