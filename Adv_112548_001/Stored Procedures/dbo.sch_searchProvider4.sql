SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	
-- =============================================
-- sch_searchProvider4 1,'305',1
CREATE PROCEDURE [dbo].[sch_searchProvider4] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@num varchar(200),
	@user int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@User AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');	
	-- PROJECT SELECTION
	
	SELECT TOP 15 IsNull(PO.[GroupName]+' ','')+IsNull('Fax:'+PO.[FaxNumber],'')+IsNull(' Phone:'+PO.[ContactNumber],'')+IsNull(' Contact Person:'+PO.[ContactPerson],'') AS [Numbers], Max(P.Provider_PK) Provider_PK
	FROM tblProvider P
		INNER JOIN tblProviderOffice PO ON PO.ProviderOffice_PK = P.ProviderOffice_PK
		INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK 
		INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
	WHERE PO.[FaxNumber] LIKE '%'+@num+'%'
		OR PO.[ContactNumber] LIKE '%'+@num+'%'
		OR PO.ContactPerson LIKE '%'+@num+'%'
		OR PO.GroupName LIKE '%'+@num+'%'
	GROUP BY PO.[FaxNumber],PO.[ContactNumber],PO.ContactPerson,PO.GroupName
END
GO
