SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
pr_getLists 28
*/
CREATE PROCEDURE [dbo].[pr_getLists]
	@User int
AS
BEGIN
	DECLARE @Location_PK AS INT
	DECLARE @IsAdmin AS INT
	DECLARE @IsManagementUser AS INT
	SELECT @Location_PK = Location_PK,@IsAdmin=IsAdmin,@IsManagementUser=IsManagementUser FROM tblUser WHERE User_PK = @User;
	SELECT L.Location,L.Location_PK FROM tblLocation L WHERE L.Location_PK=@Location_PK OR @IsAdmin=1 OR @IsManagementUser=1 Order By L.Location
END 
GO
