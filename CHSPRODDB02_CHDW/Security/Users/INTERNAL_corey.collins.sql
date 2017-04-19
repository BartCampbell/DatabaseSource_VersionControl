IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\corey.collins')
CREATE LOGIN [INTERNAL\corey.collins] FROM WINDOWS
GO
CREATE USER [INTERNAL\corey.collins] FOR LOGIN [INTERNAL\corey.collins]
GO
