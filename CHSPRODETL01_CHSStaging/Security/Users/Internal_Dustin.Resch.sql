IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'Internal\Dustin.Resch')
CREATE LOGIN [Internal\Dustin.Resch] FROM WINDOWS
GO
CREATE USER [Internal\Dustin.Resch] FOR LOGIN [Internal\Dustin.Resch]
GO
