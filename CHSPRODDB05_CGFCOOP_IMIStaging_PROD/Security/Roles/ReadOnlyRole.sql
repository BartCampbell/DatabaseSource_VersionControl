CREATE ROLE [ReadOnlyRole]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'ReadOnlyRole', N'cgf_ssrs'
GO
EXEC sp_addrolemember N'ReadOnlyRole', N'IMIHEALTH\Janet.Ledbetter'
GO
GRANT VIEW DEFINITION TO [ReadOnlyRole]
