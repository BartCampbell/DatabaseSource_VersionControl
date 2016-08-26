SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- [um_getUserAreaHours] 22
CREATE PROCEDURE [dbo].[um_getUserAreaHours] 
	@id int
AS
BEGIN
	SELECT ZipCode FROM tblUserZipCode U INNER JOIN tblZipCode Z ON Z.ZipCode_PK = U.ZipCode_PK WHERE USER_PK = @id
	SELECT * FROM tblUserWorkingHour WHERE USER_PK = @id
	SELECT Page_PK FROM tblUserPage WHERE USER_PK = @id
	SELECT Project_PK FROM tblUserProject WHERE USER_PK = @id
END

GO
