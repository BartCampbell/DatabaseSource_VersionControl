CREATE ROLE [ModifyTable]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'ModifyTable', N'INTERNAL\Paul.Johnson'
GO
GRANT CREATE TABLE TO [ModifyTable]
