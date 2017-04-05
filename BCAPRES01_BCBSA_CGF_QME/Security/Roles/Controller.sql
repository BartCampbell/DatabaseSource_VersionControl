CREATE ROLE [Controller]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'Controller', N'measureengine_controller'
GO
