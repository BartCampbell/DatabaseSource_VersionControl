CREATE ROLE [NService]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'NService', N'NProcessor'
GO
