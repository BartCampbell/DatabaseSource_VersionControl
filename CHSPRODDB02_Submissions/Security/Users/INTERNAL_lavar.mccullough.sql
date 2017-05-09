IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'INTERNAL\lavar.mccullough')
CREATE LOGIN [INTERNAL\lavar.mccullough] FROM WINDOWS
GO
CREATE USER [INTERNAL\lavar.mccullough] FOR LOGIN [INTERNAL\lavar.mccullough]
GO
