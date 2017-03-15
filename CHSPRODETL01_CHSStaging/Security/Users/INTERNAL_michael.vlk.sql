IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\michael.vlk')
CREATE LOGIN [INTERNAL\michael.vlk] FROM WINDOWS
GO
CREATE USER [INTERNAL\michael.vlk] FOR LOGIN [INTERNAL\michael.vlk]
GO
GRANT CREATE SCHEMA TO [INTERNAL\michael.vlk]
