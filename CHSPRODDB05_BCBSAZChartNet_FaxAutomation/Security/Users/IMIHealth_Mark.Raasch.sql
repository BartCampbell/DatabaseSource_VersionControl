IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'IMIHEALTH\Mark.Raasch')
CREATE LOGIN [IMIHEALTH\Mark.Raasch] FROM WINDOWS
GO
CREATE USER [IMIHealth\Mark.Raasch] FOR LOGIN [IMIHEALTH\Mark.Raasch]
GO
