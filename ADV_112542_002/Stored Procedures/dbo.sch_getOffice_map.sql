SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Amjad Ali
-- Create date: Mar-31-2015
-- =============================================
--	
--	sch_getOffice_map 0,0,0,0,2,2,1,0,0,''
CREATE PROCEDURE [dbo].[sch_getOffice_map] 
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Provider BigInt,
	@bucket int,
	@sub_bucket int,
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
		EXEC ('DELETE T FROM #tmpProject T INNER JOIN tblProject P ON P.Project_PK = T.Project_PK WHERE ProjectGroup_PK NOT IN ('+@ProjectGroup+')')
		
	IF (@Channel<>'0')
		EXEC ('DELETE T FROM #tmpChannel T WHERE Channel_PK NOT IN ('+@Channel+')')			 
	-- PROJECT/Channel SELECTION

	DECLARE @OFFICE AS BIGINT = 0
	IF (@Provider<>0)
		SELECT TOP 1 @OFFICE = ProviderOffice_PK FROM tblProvider WITH (NOLOCK) WHERE Provider_PK=@Provider;

	CREATE TABLE #tmpOffices (ProviderOffice_PK BIGINT,Providers INT, Charts Int, LastContact SmallDateTime, FollowUpDate SmallDateTime,Offices smallint,ProviderOfficeBucket_PK TinyInt)
	CREATE INDEX idxProviderOffice_PK ON #tmpOffices (ProviderOffice_PK)
	;
	WITH 
		OfficeStatus1 AS 
		(
			SELECT P.ProviderOffice_PK
				,COUNT(DISTINCT S.Provider_PK) Providers, COUNT(DISTINCT CASE WHEN S.IsScanned=0 AND S.IsCNA=0 THEN S.Suspect_PK ELSE NULL END) Charts
				,CASE WHEN SUM(CASE WHEN S.IsScanned=0 AND S.IsCNA=0 THEN 1 ELSE 0 END)=0 THEN 6 ELSE MAX(CS.ProviderOfficeBucket_PK) END ProviderOfficeBucket_PK
				,MAX(S.LastContacted) LastContact, MIN(S.FollowUp) FollowUpDate,Count(DISTINCT S.Project_PK) Offices
				FROM tblProviderOffice PO WITH (NOLOCK)
					INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
					INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
					INNER JOIN tblChaseStatus CS WITH (NOLOCK) ON CS.ChaseStatus_PK = S.ChaseStatus_PK
					INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
					INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
					LEFT JOIN tblZoneZipcode ZZC WITH (NOLOCK) ON ZZC.ZipCode_PK = PO.ZipCode_PK
				WHERE (@PoolPK=0 OR PO.Pool_PK=@PoolPK)
					AND (@ZonePK=0 OR ZZC.Zone_PK=@ZonePK)
					AND (@scheduler=0 OR PO.AssignedUser_PK=@scheduler)
					AND (@sub_bucket<>0 OR FollowUp<=GetDate())
					AND (@OFFICE=0 OR PO.ProviderOffice_PK=@OFFICE)
					AND (@sub_bucket<=0 OR PO.ProviderOfficeSubBucket_PK=@sub_bucket OR @bucket=101)
			GROUP BY P.ProviderOffice_PK	
		),
		OfficeStatus AS 
		(
			SELECT OS.ProviderOffice_PK,OS.Providers, OS.Charts,OS.LastContact,OS.FollowUpDate,OS.Offices,OS.ProviderOfficeBucket_PK 
			FROM OfficeStatus1 OS
				INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = OS.ProviderOffice_PK
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
				INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK			
			WHERE	( 
						@bucket<99
					OR
						(@bucket=99 AND PO.hasPriorityNote=1)
					OR
						(@bucket=101 AND S.FollowUp<=GetDate() AND (@sub_bucket=-1 OR OS.ProviderOfficeBucket_PK=@sub_bucket))
					)
					/*
				AND
				(
					@search_type=0   OR
					(@search_type=101 AND PO.Address Like '%'+@search_value+'%') OR
					(@search_type=102 AND PO.LocationID Like '%'+@search_value+'%') OR
					(@search_type=103 AND PO.ContactNumber Like '%'+@search_value+'%') OR
					(@search_type=104 AND PO.FaxNumber Like '%'+@search_value+'%') OR
					(@search_type=105 AND S.PlanLID Like '%'+@search_value+'%') OR
					(@search_type=201 AND PM.ProviderGroup Like '%'+@search_value+'%') OR
					(@search_type=202 AND PM.Provider_ID Like '%'+@search_value+'%') OR
					(@search_type=203 AND PM.NPI Like '%'+@search_value+'%') OR
					(@search_type=204 AND PM.Lastname+IsNull(', '+PM.Firstname,'') Like '%'+@search_value+'%') OR
					(@search_type=205 AND PM.PIN Like '%'+@search_value+'%') OR
					(@search_type=301 AND M.Member_ID Like '%'+@search_value+'%') OR
					(@search_type=302 AND M.Lastname+IsNull(', '+M.Firstname,'') Like '%'+@search_value+'%') OR
					(@search_type=303 AND M.HICNumber Like '%'+@search_value+'%') OR
					(@search_type=304 AND S.ChaseID Like '%'+@search_value+'%')
				)
				*/
				GROUP BY OS.ProviderOffice_PK,OS.Providers, OS.Charts,OS.LastContact,OS.FollowUpDate,OS.Offices,OS.ProviderOfficeBucket_PK 	
		)

	INSERT INTO #tmpOffices(ProviderOffice_PK,Providers, Charts, LastContact, FollowUpDate,Offices,ProviderOfficeBucket_PK)
	SELECT OS.ProviderOffice_PK,OS.Providers, OS.Charts,OS.LastContact,OS.FollowUpDate,OS.Offices,ProviderOfficeBucket_PK 
		FROM OfficeStatus OS WITH (NOLOCK)
	WHERE @bucket IN (0,101,99) OR OS.ProviderOfficeBucket_PK=@bucket

	SELECT 0 Project_PK,cPO.ProviderOffice_PK,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode,PO.ContactPerson,PO.ContactNumber,PO.FaxNumber,PO.Email_Address,Isnull(PO.EMR_Type_PK,0) EMR_Type_PK
		,cPO.Providers
		,cPO.Charts
		,DATEDIFF(day,GetDate(),FollowUpDate) followup_days
		,POB.Bucket OfficeStatus,ZC.Latitude,ZC.Longitude
		,IsNull(POAU.Lastname+IsNull(','+POAU.Firstname,''),'') AssignedScheduler,PO.AssignedUser_PK
		FROM tblProviderOffice PO WITH (NOLOCK)
		INNER JOIN #tmpOffices cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN tblProviderOfficeBucket POB WITH (NOLOCK) ON POB.ProviderOfficeBucket_PK = cPO.ProviderOfficeBucket_PK
		INNER JOIN tblZipCode ZC ON ZC.ZipCode_PK = PO.ZipCode_PK
		LEFT JOIN tblUser POAU WITH (NOLOCK) ON PO.AssignedUser_PK = POAU.User_PK
END
GO
