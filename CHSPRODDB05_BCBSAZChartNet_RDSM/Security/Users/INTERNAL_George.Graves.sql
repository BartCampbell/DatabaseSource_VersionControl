IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\George.Graves')
CREATE LOGIN [INTERNAL\George.Graves] FROM WINDOWS
GO
CREATE USER [INTERNAL\George.Graves] FOR LOGIN [INTERNAL\George.Graves]
GO
GRANT VIEW DEFINITION TO [INTERNAL\George.Graves]