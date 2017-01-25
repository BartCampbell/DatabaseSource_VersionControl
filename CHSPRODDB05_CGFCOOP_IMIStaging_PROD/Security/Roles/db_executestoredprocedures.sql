CREATE ROLE [db_executestoredprocedures]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_executestoredprocedures', N'DHMP_BI_Reader'
GO
GRANT EXECUTE TO [db_executestoredprocedures]
