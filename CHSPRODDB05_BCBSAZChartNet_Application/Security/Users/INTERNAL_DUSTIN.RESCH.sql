IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\Dustin.Resch')
CREATE LOGIN [INTERNAL\Dustin.Resch] FROM WINDOWS
GO
CREATE USER [INTERNAL\DUSTIN.RESCH] FOR LOGIN [INTERNAL\Dustin.Resch]
GO
