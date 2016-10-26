SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sch_searchSimilarOffices 7,1,0,0,0
CREATE PROCEDURE [dbo].[sch_searchSimilarOffices] 
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@OFFICE BIGINT,
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
		EXEC ('DELETE T FROM #tmpProject T INNER JOIN tblProject P ON P.Project_PK = T.Project_PK WHERE ProjectGroup_PK NOT IN ('+@ProjectGroup+')')
		
	IF (@Channel<>'0')
		EXEC ('DELETE T FROM #tmpChannel T WHERE Channel_PK NOT IN ('+@Channel+')')			 
	-- PROJECT/Channel SELECTION
	
	--Office can merge
	SELECT LEFT(PO.Address,5)+'%',0 Project_PK,cPO.ProviderOffice_PK,IsNull(PO.GroupName+' ','')+PO.Address [Address],PO.ZipCode_PK,PO.ContactPerson,PO.ContactNumber,PO.FaxNumber,PO.Email_Address,PO.EMR_Type
			,COUNT(DISTINCT P.Provider_PK) Providers
			,COUNT(DISTINCT CASE WHEN IsScanned=1 OR S.IsCNA=1 THEN NULL ELSE S.Suspect_PK END) Charts
			,CASE WHEN COUNT(DISTINCT CASE WHEN IsScanned=1 OR S.IsCNA=1 THEN NULL ELSE S.Suspect_PK END)=0 THEN 9999 ELSE MIN(DATEDIFF(day,GetDate(),follow_up)) END followup_days
--			,schedule_type,
			,POB.Bucket OfficeStatus
		FROM 
			cacheProviderOffice cPO WITH (NOLOCK)
			INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON cPO.ProviderOffice_PK=PO.ProviderOffice_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN tblProviderOfficeBucket POB WITH (NOLOCK) ON POB.ProviderOfficeBucket_PK = PO.ProviderOfficeBucket_PK
			INNER JOIN tblProviderOffice PO2 WITH (NOLOCK) ON 
				(RTRIM(PO.ContactNumber)<>'' AND (Replace(Replace(Replace(Replace(PO2.ContactNumber,' ',''),'-',''),')',''),'(','') LIKE Replace(Replace(Replace(Replace(PO.ContactNumber,' ',''),'-',''),')',''),'(',''))
				OR (RTRIM(PO2.Address)=RTRIM(PO.Address))
				OR (PO2.GroupName = PO.GroupName AND IsNull(PO2.GroupName,'') NOT LIKE ''))
				AND PO2.ProviderOffice_PK = @OFFICE AND PO.ProviderOffice_PK <> @OFFICE
	GROUP BY cPO.ProviderOffice_PK,IsNull(PO.GroupName+' ',''),PO.Address,PO.ZipCode_PK,PO.ContactPerson,PO.ContactNumber,PO.FaxNumber,PO.Email_Address,PO.EMR_Type,POB.Bucket

	--Linked Office
	SELECT COUNT(DISTINCT P.Provider_PK) Providers,COUNT(DISTINCT S.Suspect_PK) Charts, COUNT(DISTINCT CASE WHEN IsScanned=1 OR S.IsCNA=1 THEN NULL ELSE S.Suspect_PK END) Remaining,Min(dtLastContact) LastContact,MIN(follow_up) follow_up,POB.Bucket OfficeStatus,Pr.Project_Name,Pr.ProjectGroup
	FROM cacheProviderOffice tPO WITH (NOLOCK) 
			INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON tPO.ProviderOffice_PK=PO.ProviderOffice_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = tPO.ProviderOffice_PK
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderOfficeBucket POB WITH (NOLOCK) ON POB.ProviderOfficeBucket_PK = PO.ProviderOfficeBucket_PK
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN tblProject Pr ON Pr.Project_PK = S.Project_PK
	WHERE tPO.ProviderOffice_PK = @OFFICE
	GROUP BY Pr.Project_Name,Pr.ProjectGroup,POB.Bucket
END
GO
