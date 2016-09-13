SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Oct-19-2014
-- Description:	Status Report will use this sp to pull list of status with count
-- =============================================
--  ir_getStatus 0,1
CREATE PROCEDURE [dbo].[ir_getStatus]
	@Project int,
	@user int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	IF @Project=0
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@user)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@user
	END
	ELSE
		INSERT INTO #tmpProject(Project_PK) VALUES(@Project)		
	-- PROJECT SELECTION
		
	SELECT COUNT(DISTINCT SII.Suspect_PK) [COUNT], IsNull(CAST(SII.IsApproved AS INT),2) [Status]
		FROM tblSuspectInvoiceInfo SII INNER JOIN tblSuspect S ON S.Suspect_PK = SII.Suspect_PK
			INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
	GROUP BY CAST(SII.IsApproved AS INT)
	ORDER BY CAST(SII.IsApproved AS INT)
END
GO
