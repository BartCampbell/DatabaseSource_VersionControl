CREATE ROLE [FaxAutomation]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'FaxAutomation', N'fax_automation'
GO
