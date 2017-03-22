SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--  sch_getStatus '0','0','0',0,1,0,0,0
CREATE PROCEDURE [dbo].[sch_getStatus]
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
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
		EXEC ('DELETE T FROM #tmpProject T INNER JOIN tblProject P ON P.Project_PK = T.Project_PK WHERE ProjectGroup_PK NOT IN ('+@ProjectGroup+')')
		
	IF (@Channel<>'0')
		EXEC ('DELETE T FROM #tmpChannel T WHERE Channel_PK NOT IN ('+@Channel+')')			 
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
	;
	
	WITH 
		OfficeStatus AS 
		(
			SELECT P.ProviderOffice_PK,PO.ProviderOfficeSubBucket_PK, CASE WHEN SUM(CASE WHEN S.IsScanned=0 AND S.IsCNA=0 THEN 1 ELSE 0 END)=0 THEN 6 ELSE MAX(CS.ProviderOfficeBucket_PK) END ProviderOfficeBucket_PK, MIN(S.FollowUp) FollowUp, PO.hasPriorityNote
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
			GROUP BY P.ProviderOffice_PK,PO.ProviderOfficeSubBucket_PK,PO.hasPriorityNote		
		),
		Buckets AS 
		(
			SELECT POB.ProviderOfficeBucket_PK, POB.Bucket, COUNT(ProviderOffice_PK) Offices ,POB.sortOrder
				FROM tblProviderOfficeBucket POB WITH (NOLOCK)
					LEFT JOIN OfficeStatus OS ON POB.ProviderOfficeBucket_PK = OS.ProviderOfficeBucket_PK
			WHERE POB.IsVisible=1
			GROUP BY POB.ProviderOfficeBucket_PK, POB.Bucket, POB.sortOrder
		),
		FollowBucketsExPriority AS 
		(
			SELECT POB.ProviderOfficeBucket_PK, POB.Bucket, COUNT(1) Offices ,POB.sortOrder
				FROM tblProviderOfficeBucket POB WITH (NOLOCK)
					INNER JOIN OfficeStatus OS ON POB.ProviderOfficeBucket_PK = OS.ProviderOfficeBucket_PK
			WHERE POB.ProviderOfficeBucket_PK>0 AND FollowUp<=GETDATE() AND (OS.hasPriorityNote IS NULL OR OS.hasPriorityNote=0)
			GROUP BY POB.ProviderOfficeBucket_PK, POB.Bucket, POB.sortOrder

			
		),
		FollowBucketsInPriority AS 
		(
			SELECT 99 ProviderOfficeBucket_PK, 'Priority Note' Bucket, COUNT(1) Offices ,0 sortOrder
				FROM OfficeStatus OS 
			WHERE OS.hasPriorityNote=1
		),
		SubBuckets AS 
		(
			SELECT OS.ProviderOfficeBucket_PK, POSB.SubBucket Bucket, COUNT(1) Offices ,POSB.sortOrder, POSB.ProviderOfficeSubBucket_PK
				FROM tblProviderOfficeSubBucket POSB WITH (NOLOCK)
					INNER JOIN OfficeStatus OS ON POSB.ProviderOfficeSubBucket_PK = OS.ProviderOfficeSubBucket_PK
			GROUP BY OS.ProviderOfficeBucket_PK, POSB.SubBucket ,POSB.sortOrder, POSB.ProviderOfficeSubBucket_PK
		)

		/*SELECT * FROM SubBuckets
		*/
		SELECT ProviderOfficeBucket_PK, Bucket, Offices,-1 BucketType,sortOrder FROM Buckets
		UNION
		SELECT 101 ProviderOfficeBucket_PK, 'Follow-up Required' Bucket, sum(Offices) Offices,-1 BucketType,4 sortOrder FROM FollowBucketsExPriority
		UNION
		SELECT 99 ProviderOfficeBucket_PK, Bucket, Offices,-1 BucketType,sortOrder FROM FollowBucketsInPriority WHERE Offices>0
		UNION
		SELECT ProviderOfficeBucket_PK, Bucket, Offices,101 BucketType,sortOrder FROM FollowBucketsExPriority
		UNION
		SELECT ProviderOfficeSubBucket_PK, Bucket, Offices,ProviderOfficeBucket_PK BucketType,1001 sortOrder FROM SubBuckets ORDER BY BucketType,sortOrder
		
END
GO
