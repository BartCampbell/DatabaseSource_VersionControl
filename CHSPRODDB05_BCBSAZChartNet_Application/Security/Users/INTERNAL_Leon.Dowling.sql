IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\Leon.Dowling')
CREATE LOGIN [INTERNAL\Leon.Dowling] FROM WINDOWS
GO
CREATE USER [INTERNAL\Leon.Dowling] FOR LOGIN [INTERNAL\Leon.Dowling]
GO
