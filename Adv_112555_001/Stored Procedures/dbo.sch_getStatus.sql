SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--  sch_getStatus '0',0,0,1,0,0,1
CREATE PROCEDURE [dbo].[sch_getStatus]
	@channel int,
	@Projects varchar(500),
	@ProjectGroup varchar(10),
	@scheduler int,
	@user int,
	@PoolPK int,
	@ZonePK int,
	@isMap int
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
		
	IF (@Channel<>0)
		DELETE T FROM #tmpChannel T WHERE Channel_PK<>@Channel				 
	-- PROJECT/Channel SELECTION


	DECLARE @IsScheduler AS BIT = 0
	DECLARE @IsSupervisor AS BIT = 0
	DECLARE @IsManager AS BIT = 0
	IF @scheduler<>0
	BEGIN
		SET @IsScheduler = 1
	END
	ELSE IF (@isMap=1)
		SET @IsManager = 1
	ELSE
	BEGIN
		SELECT @IsScheduler=IsScheduler,@IsSupervisor=IsSchedulerSV,@IsManager=CASE WHEN IsSchedulerManager=1 OR IsAdmin=1 THEN 1 ELSE 0 END FROM tblUser WHERE User_PK = @user
		IF (@IsManager=1)	-- If User is Manager then we need to skip assignment for him
		BEGIN
			SET @IsScheduler = 0
			SET @IsSupervisor = 0			
		END
		ELSE IF (@PoolPK=0) -- If not a Manager and pool is not request then only showing assignements
		BEGIN
			SET @IsScheduler = 1
			SET @scheduler = @user
		END
	END

	SELECT PO.ProviderOfficeBucket_PK, COUNT(DISTINCT PO.ProviderOffice_PK) Offices INTO #Buckets
		FROM tblProviderOffice PO WITH (NOLOCK)
			INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = PO.ProviderOffice_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			LEFT JOIN tblZoneZipcode ZZC WITH (NOLOCK) ON ZZC.ZipCode_PK = PO.ZipCode_PK
		WHERE (@PoolPK=0 OR PO.Pool_PK=@PoolPK)
			AND (@ZonePK=0 OR ZZC.Zone_PK=@ZonePK)
			AND (@scheduler=0 OR PO.AssignedUser_PK=@scheduler)
	GROUP BY PO.ProviderOfficeBucket_PK
	CREATE INDEX idxProviderOfficeBucket_PK ON #Buckets (ProviderOfficeBucket_PK)

	--Main Buckets
	SELECT POB.ProviderOfficeBucket_PK, POB.Bucket, Offices ,POB.sortOrder
		FROM tblProviderOfficeBucket POB WITH (NOLOCK)
			LEFT JOIN #Buckets PO ON POB.ProviderOfficeBucket_PK = PO.ProviderOfficeBucket_PK
	WHERE POB.IsVisible=1
	ORDER BY POB.sortOrder

	--Follow-up Sub Buckets
	SELECT POB.ProviderOfficeBucket_PK, POB.Bucket, COUNT(DISTINCT PO.ProviderOffice_PK) Offices, POB.sortOrder
		FROM tblProviderOfficeBucket POB WITH (NOLOCK)
		INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON POB.ProviderOfficeBucket_PK = PO.ProviderOfficeBucket_PK
		INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		LEFT JOIN tblZoneZipcode ZZC WITH (NOLOCK) ON ZZC.ZipCode_PK = PO.ZipCode_PK
	WHERE POB.ProviderOfficeBucket_PK>0 AND follow_up<=GETDATE()
		AND (@PoolPK=0 OR PO.Pool_PK=@PoolPK)
		AND (@ZonePK=0 OR ZZC.Zone_PK=@ZonePK)
		AND (@scheduler=0 OR PO.AssignedUser_PK=@scheduler)
	GROUP BY POB.ProviderOfficeBucket_PK, POB.Bucket,POB.sortOrder
	ORDER BY POB.sortOrder	
END
GO
