CREATE ROLE [ReadOnlyRole]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'ReadOnlyRole', N'TestReadOnlyUserOne'
GO
EXEC sp_addrolemember N'ReadOnlyRole', N'TestReadOnlyUserThree'
GO
GRANT VIEW DEFINITION TO [ReadOnlyRole]
