IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\Melody.Jones')
CREATE LOGIN [INTERNAL\Melody.Jones] FROM WINDOWS
GO
