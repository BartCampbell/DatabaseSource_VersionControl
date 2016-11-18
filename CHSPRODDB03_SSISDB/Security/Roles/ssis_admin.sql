CREATE ROLE [ssis_admin]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'ssis_admin', N'AllSchemaOwner'
GO
