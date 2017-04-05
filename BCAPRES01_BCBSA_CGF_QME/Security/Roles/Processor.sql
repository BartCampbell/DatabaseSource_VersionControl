CREATE ROLE [Processor]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'Processor', N'measureengine_processor'
GO
