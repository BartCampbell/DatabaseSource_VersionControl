SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:	Sajid Ali
-- Create date: Oct-02-2015
-- Description:	
-- =============================================
/* Sample Executions
rc_getCalMonth 0,0,1,0,2016,1
*/
CREATE PROCEDURE [dbo].[rc_getCalMonth]
	@Projects varchar(20),
	@ProjectGroup varchar(10),
	@User int,
	@ScanTech int,
	@Year int,
	@Month int
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

	SELECT POS.Project_PK,POS.ProviderOffice_PK,Day(Sch_Start) SchDay,[Sch_Start],[Sch_End],U.Lastname+', '+U.Firstname ScanTech 
	,PO.Address ALine1, City+' '+County+', '+ZipCode+' '+State ALine2,ContactPerson, ContactNumber
	,Count(DISTINCT S.Suspect_PK) Charts
	,Count(DISTINCT S.Scanned_User_PK) Scanned
	,Count(DISTINCT S.CNA_User_PK) CNA
	,CASE WHEN Sch_Start<GetDate() THEN 1 ELSE 0 END Passed
	FROM tblProviderOfficeSchedule POS WITH (NOLOCK)
	INNER JOIN tblUser U WITH (NOLOCK) ON POS.Sch_User_PK = U.User_PK 
	INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = POS.ProviderOffice_PK
	INNER JOIN #tmpProject Pr ON Pr.Project_PK = POS.Project_PK
	LEFT  JOIN tblProvider P WITH (NOLOCK) ON PO.ProviderOffice_PK = P.ProviderOffice_PK
	LEFT  JOIN tblSuspect S WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK AND S.Project_PK = POS.Project_PK
	LEFT  JOIN tblZipCode ZC WITH (NOLOCK) ON PO.ZipCode_PK = ZC.ZipCode_PK
	WHERE Year(Sch_Start)=@Year AND Month(Sch_Start)=@Month
		AND (@ScanTech=0 OR U.User_PK=@ScanTech)
	GROUP BY POS.Project_PK,POS.ProviderOffice_PK,Day(Sch_Start),[Sch_Start],[Sch_End],U.Lastname+', '+U.Firstname,PO.Address, City+' '+County+', '+ZipCode+' '+State,ContactPerson, ContactNumber
END
GO
