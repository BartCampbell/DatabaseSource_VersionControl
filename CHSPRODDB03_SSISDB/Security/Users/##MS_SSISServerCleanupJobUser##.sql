IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'##MS_SSISServerCleanupJobLogin##')
CREATE LOGIN [##MS_SSISServerCleanupJobLogin##] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [##MS_SSISServerCleanupJobUser##] FOR LOGIN [##MS_SSISServerCleanupJobLogin##]
GO
