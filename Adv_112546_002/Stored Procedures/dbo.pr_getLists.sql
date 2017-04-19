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
/*
	DECLARE @Location_PK AS INT
	DECLARE @IsAdmin AS INT
	DECLARE @IsQAManager AS INT
	SELECT @Location_PK = Location_PK,@IsAdmin=IsAdmin,@IsQAManager=@IsQAManager FROM tblUser WHERE User_PK = @User;
	SELECT L.Location,L.Location_PK FROM tblLocation L WHERE L.Location_PK=@Location_PK OR @IsAdmin=1 OR @IsQAManager=1 Order By L.Location
*/
	SELECT L.Location,L.Location_PK FROM tblLocation L Order By L.Location
END 
GO
