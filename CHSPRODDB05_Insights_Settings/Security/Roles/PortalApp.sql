CREATE ROLE [PortalApp]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'PortalApp', N'ReportPortal_AppUser'
GO
