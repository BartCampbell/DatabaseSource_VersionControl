IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\michael.vlk')
CREATE LOGIN [INTERNAL\michael.vlk] FROM WINDOWS
GO
