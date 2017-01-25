CREATE ROLE [NController]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'NController', N'NProcessor'
GO
