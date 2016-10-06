SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Amjad Ali
-- Create date: Mar-31-2015
-- =============================================
--	
--	sch_getOffice_map 1,0,0,4,0,1,0,0
CREATE PROCEDURE [dbo].[sch_getOffice_map] 
	@Channel int,
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@Provider BigInt,
	@bucket int,
	@followup_bucket int,
	@user int,
	@PoolPK int,
	@ZonePK int,
	@address varchar(100)
AS
BEGIN
	DECLARE @scheduler AS INT = 0

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
		
	IF (@Channel<>0)
		DELETE T FROM #tmpChannel T WHERE Channel_PK<>@Channel				 
	-- PROJECT/Channel SELECTION

	DECLARE @OFFICE AS BIGINT = 0
	IF (@Provider<>0)
		SELECT TOP 1 @OFFICE = ProviderOffice_PK FROM tblProvider WITH (NOLOCK) WHERE Provider_PK=@Provider;

	CREATE TABLE #tmpOffices (ProviderOffice_PK BIGINT,Providers INT, Charts Int, LastContact SmallDateTime, FollowUpDate SmallDateTime,Offices smallint) --,extracted smallint, coded smallint, cna smallint,schedule_type smallint
		CREATE INDEX idxProviderOffice_PK ON #tmpOffices (ProviderOffice_PK)

	INSERT INTO #tmpOffices(ProviderOffice_PK,Providers, Charts, LastContact, FollowUpDate,Offices) --,extracted, coded, cna,schedule_type
	SELECT PO.ProviderOffice_PK,Sum(DISTINCT S.Provider_PK) Providers, Sum(CASE WHEN IsScanned=0 AND IsCNA=0 THEN 1 ELSE 0 END) Charts,MAX(dtLastContact) LastContact,MAX(follow_up) FollowUpDate,Count(DISTINCT PO.ProviderOffice_PK) Offices
		--,SUM(cPO.extracted_count) extracted, SUM(cPO.coded_count) coded, SUM(cPO.cna_count) cna,MIN(schedule_type) schedule_type
		FROM tblProviderOffice PO WITH (NOLOCK)
		INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		LEFT JOIN tblZoneZipcode ZZC WITH (NOLOCK) ON ZZC.ZipCode_PK = PO.ZipCode_PK
		WHERE (@bucket=0 OR PO.ProviderOfficeBucket_PK=@bucket)
			AND (@PoolPK=0 OR PO.Pool_PK=@PoolPK)
			AND (@ZonePK=0 OR ZZC.Zone_PK=@ZonePK)
			AND (@scheduler=0 OR PO.AssignedUser_PK=@scheduler)
			AND (@followup_bucket=0 OR follow_up<=GetDate())
			AND (@OFFICE=0 OR PO.ProviderOffice_PK=@OFFICE)
			AND (@address='' OR PO.Address LIKE '%'+@address+'%')
		GROUP BY PO.ProviderOffice_PK

	SELECT 0 Project_PK,cPO.ProviderOffice_PK,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode,PO.ContactPerson,PO.ContactNumber,PO.FaxNumber,PO.Email_Address,Isnull(PO.EMR_Type_PK,0) EMR_Type_PK
		,cPO.Providers
		,cPO.Charts
		,DATEDIFF(day,GetDate(),FollowUpDate) followup_days
		--,schedule_type,extracted,coded,cna
		,POB.Bucket OfficeStatus,ZC.Latitude,ZC.Longitude
		,IsNull(POAU.Lastname+IsNull(','+POAU.Firstname,''),'') AssignedScheduler,PO.AssignedUser_PK
		FROM tblProviderOffice PO WITH (NOLOCK)
		INNER JOIN #tmpOffices cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN tblProviderOfficeBucket POB WITH (NOLOCK) ON POB.ProviderOfficeBucket_PK = PO.ProviderOfficeBucket_PK
		INNER JOIN tblZipCode ZC ON ZC.ZipCode_PK = PO.ZipCode_PK
		LEFT JOIN tblUser POAU WITH (NOLOCK) ON PO.AssignedUser_PK = POAU.User_PK
END
GO
