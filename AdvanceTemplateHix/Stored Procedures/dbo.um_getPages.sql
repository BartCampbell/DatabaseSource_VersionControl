SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- um_getPages 1,1
CREATE PROCEDURE [dbo].[um_getPages] 
	@User int,
	@IsAdmin bit
AS
BEGIN
	SELECT TOP 0 100000 Page_PK INTO #tmp 
	IF (@IsAdmin=1)
		INSERT INTO #tmp SELECT Page_PK FROM tblPage WHERE IsActive=1
	else 
		INSERT INTO #tmp SELECT Page_PK FROM tblUserPage UP WHERE User_PK = @User
	
	SELECT * FROM (
	SELECT P.* FROM tblPage P INNER JOIN #tmp UP ON UP.Page_PK=P.Page_PK WHERE P.IsActive=1
	UNION
	SELECT P.* FROM tblPage P0 INNER JOIN #tmp UP ON UP.Page_PK=P0.Page_PK INNER JOIN tblPage P ON P.page_PK=P0.Parent_PK WHERE P.IsActive=1
	) T ORDER BY Parent_PK,sortOrder
	
	IF (@IsAdmin=1)
		SELECT Project_PK FROM tblProject
	else 
		SELECT Project_PK FROM tblUserProject WHERE User_PK = @User

	--User Session Start
	INSERT INTO tblUserSession(User_PK,SessionStart) VALUES(@User,GETDATE());
	SELECT @@IDENTITY Session_PK;
END    

GO
