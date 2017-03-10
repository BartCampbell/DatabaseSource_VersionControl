IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\brandon.rodman')
CREATE LOGIN [INTERNAL\brandon.rodman] FROM WINDOWS
GO
CREATE USER [INTERNAL\brandon.rodman] FOR LOGIN [INTERNAL\brandon.rodman]
GO
GRANT CREATE SYNONYM TO [INTERNAL\brandon.rodman]
