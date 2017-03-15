IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\dwight.staggs')
CREATE LOGIN [INTERNAL\dwight.staggs] FROM WINDOWS
GO
CREATE USER [INTERNAL\dwight.staggs] FOR LOGIN [INTERNAL\dwight.staggs]
GO
