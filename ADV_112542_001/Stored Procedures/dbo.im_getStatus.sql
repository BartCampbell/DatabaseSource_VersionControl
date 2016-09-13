SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Oct-19-2014
-- Description:	Status Report will use this sp to pull list of status with count
-- =============================================
--  im_getStatus 0,1
CREATE PROCEDURE [dbo].[im_getStatus]
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@user int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)
	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@User AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');
	-- PROJECT SELECTION
		
	SELECT COUNT(DISTINCT SII.Suspect_PK) [COUNT], CASE WHEN SII.IsApproved=1 THEN 2 WHEN SII.IsApproved=0 THEN 1 ELSE 0 END [Status]
		FROM tblSuspectInvoiceInfo SII INNER JOIN tblSuspect S ON S.Suspect_PK = SII.Suspect_PK
			INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
	GROUP BY CASE WHEN SII.IsApproved=1 THEN 2 WHEN SII.IsApproved=0 THEN 1 ELSE 0 END
	UNION
	SELECT COUNT(DISTINCT SII.Suspect_PK) [COUNT], CASE WHEN SII.IsPaid=1 THEN 5 ELSE 4 END [Status]
		FROM tblSuspectInvoiceInfo SII INNER JOIN tblSuspect S ON S.Suspect_PK = SII.Suspect_PK
			INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
	WHERE IsApproved=1
	GROUP BY CASE WHEN SII.IsPaid=1 THEN 5 ELSE 4 END
	ORDER BY [Status]
END
GO
