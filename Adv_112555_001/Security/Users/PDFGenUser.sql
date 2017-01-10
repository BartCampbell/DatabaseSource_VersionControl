IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'PDFGenUser')
CREATE LOGIN [PDFGenUser] WITH PASSWORD = 'p@ssw0rd'
GO
