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
	-- PROJECT/Channel SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)

	CREATE TABLE #tmpChannel (Channel_PK INT)
	CREATE INDEX idxChannelPK ON #tmpChannel (Channel_PK)

	IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
	BEGIN
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblChannel 
	END
	ELSE
	BEGIN
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblUserProject WHERE User_PK=@User
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblUserChannel WHERE User_PK=@User
	END

	IF (@Projects<>'0')
		EXEC ('DELETE FROM #tmpProject WHERE Project_PK NOT IN ('+@Projects+')')
		
	IF (@ProjectGroup<>'0')
		DELETE T FROM #tmpProject T INNER JOIN tblProject P ON P.Project_PK = T.Project_PK WHERE ProjectGroup_PK<>@ProjectGroup	 
	-- PROJECT/Channel SELECTION
	
	SELECT TOP 15 IsNull(PO.[GroupName]+' ','')+IsNull('Fax:'+PO.[FaxNumber],'')+IsNull(' Phone:'+PO.[ContactNumber],'')+IsNull(' Contact Person:'+PO.[ContactPerson],'') AS [Numbers], Max(P.Provider_PK) Provider_PK
	FROM tblProvider P
		INNER JOIN tblProviderOffice PO ON PO.ProviderOffice_PK = P.ProviderOffice_PK
		INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK 
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
	WHERE PO.[FaxNumber] LIKE '%'+@num+'%'
		OR PO.[ContactNumber] LIKE '%'+@num+'%'
		OR PO.ContactPerson LIKE '%'+@num+'%'
		OR PO.GroupName LIKE '%'+@num+'%'
	GROUP BY PO.[FaxNumber],PO.[ContactNumber],PO.ContactPerson,PO.GroupName
END
GO
