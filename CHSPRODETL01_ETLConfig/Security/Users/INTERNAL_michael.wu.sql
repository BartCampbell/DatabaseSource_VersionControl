IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\Michael.Wu')
CREATE LOGIN [INTERNAL\Michael.Wu] FROM WINDOWS
GO
CREATE USER [INTERNAL\michael.wu] FOR LOGIN [INTERNAL\Michael.Wu]
GO
