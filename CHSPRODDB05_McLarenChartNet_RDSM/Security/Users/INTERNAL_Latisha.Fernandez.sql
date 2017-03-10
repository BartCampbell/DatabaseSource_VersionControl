IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\Latisha.Fernandez')
CREATE LOGIN [INTERNAL\Latisha.Fernandez] FROM WINDOWS
GO
CREATE USER [INTERNAL\Latisha.Fernandez] FOR LOGIN [INTERNAL\Latisha.Fernandez]
GO
