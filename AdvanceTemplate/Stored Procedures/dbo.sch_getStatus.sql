SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--  sch_getStatus '0',0,0,1,0,0,1
CREATE PROCEDURE [dbo].[sch_getStatus]
	@Projects varchar(500),
	@ProjectGroup varchar(10),
	@scheduler int,
	@user int,
	@PoolPK int,
	@ZonePK int,
	@isMap int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)
	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT Project_PK FROM tblProject P WITH (NOLOCK) WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT P.Project_PK FROM tblProject P WITH (NOLOCK) LEFT JOIN tblUserProject UP WITH (NOLOCK) ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@User AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WITH (NOLOCK) WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');	
	-- PROJECT SELECTION


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
			INNER JOIN #tmpProject P ON P.Project_PK = cPO.Project_PK
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
		INNER JOIN #tmpProject P ON P.Project_PK = cPO.Project_PK
		LEFT JOIN tblZoneZipcode ZZC WITH (NOLOCK) ON ZZC.ZipCode_PK = PO.ZipCode_PK
	WHERE POB.ProviderOfficeBucket_PK>0 AND follow_up<=GETDATE()
		AND (@PoolPK=0 OR PO.Pool_PK=@PoolPK)
		AND (@ZonePK=0 OR ZZC.Zone_PK=@ZonePK)
		AND (@scheduler=0 OR PO.AssignedUser_PK=@scheduler)
	GROUP BY POB.ProviderOfficeBucket_PK, POB.Bucket,POB.sortOrder
	ORDER BY POB.sortOrder	
END
GO
