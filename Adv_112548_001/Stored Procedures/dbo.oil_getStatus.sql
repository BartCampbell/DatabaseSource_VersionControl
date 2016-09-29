SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
--		1	Pending Feedback
--		2	Awaiting scheduler response
--		3	Scheduled
--		4	Removed from Chase list
-- =============================================
--	oil_getStatus 0,1,1,1
CREATE PROCEDURE [dbo].[oil_getStatus]
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@user int,
	@Channel int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
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
		
	SELECT POS.OfficeIssueStatus [status], COUNT(DISTINCT POS.ProviderOffice_PK) Cnt
			FROM tblProviderOffice PO WITH (NOLOCK) 
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
				INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
				Outer APPLY (SELECT TOP 1 * FROM tblProviderOfficeStatus WHERE ProviderOffice_PK = PO.ProviderOffice_PK) POS
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
	WHERE (@Channel=0 OR S.Channel_PK=@Channel)
	GROUP BY POS.OfficeIssueStatus
END
GO
