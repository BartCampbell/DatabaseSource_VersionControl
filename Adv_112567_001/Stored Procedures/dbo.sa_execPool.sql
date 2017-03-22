SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sa_execPool 3
CREATE PROCEDURE [dbo].[sa_execPool] 
	@PoolPK int
AS
BEGIN
	DECLARE @IsBucketRule int
	DECLARE @ProviderOfficeBucket_PK int
	DECLARE @IsFollowupRule int
	DECLARE @IsRemainingRule int
	DECLARE @RemainingCharts int 
	DECLARE @RemainingChartsMoreOrEqual int
	DECLARE @IsLastScheduledRule int
	DECLARE @DaysSinceLastScheduled int
	DECLARE @IsScheduledTypeRule int
	DECLARE @ScheduledType int
	DECLARE @IsZoneRule int
	DECLARE @Zone_PK int
	DECLARE @IsProjectRule int
	DECLARE @Channel int
	DECLARE @Projects Varchar(500)
	DECLARE @ProjectGroup Varchar(500)
	DECLARE @SchedulerTeam_PK int
	DECLARE @Pool_Priority int
	DECLARE @IsAutoRefreshPool int
	DECLARE @PriorityWithinPool int
	DECLARE @IsForcedAllocationAllowed int = 1
	DECLARE @User INT

	SELECT @IsBucketRule=IsBucketRule--,@ProviderOfficeBucket_PK=ProviderOfficeBucket_PK
			,@IsFollowupRule=IsFollowupRule
			,@IsRemainingRule=IsRemainingRule,@RemainingCharts=RemainingCharts,@RemainingChartsMoreOrEqual=RemainingChartsMoreOrEqual
			,@IsLastScheduledRule=IsLastScheduledRule,@DaysSinceLastScheduled=DaysSinceLastScheduled
			,@IsScheduledTypeRule=IsScheduledTypeRule,@ScheduledType=ScheduledType
			,@IsZoneRule=IsZoneRule,@Zone_PK=Zone_PK
			,@IsProjectRule=IsProjectRule,@Channel=Channel_PK,@Projects=Projects,@ProjectGroup=ProjectGroups
			,@SchedulerTeam_PK=SchedulerTeam_PK,@Pool_Priority=Pool_Priority,@IsAutoRefreshPool=IsAutoRefreshPool,@PriorityWithinPool=PriorityWithinPool
			,@IsForcedAllocationAllowed = IsForcedAllocationAllowed
			,@User = User_PK
	FROM dbo.tblPool WHERE Pool_PK = @PoolPK

	CREATE TABLE #tmpSchedule(ProviderOffice_PK BIGINT,ScheduleDate DATE,ScheduleType tinyint)
	CREATE INDEX idxProviderOffice_PK ON #tmpSchedule (ProviderOffice_PK)
	CREATE INDEX idxScheduleType ON #tmpSchedule (ScheduleType)

	CREATE TABLE #tmpZone(ProviderOffice_PK BIGINT)
	CREATE INDEX idxZProviderOffice_PK ON #tmpZone (ProviderOffice_PK)

	IF (@IsProjectRule=0)
	BEGIN
		 SET @Channel = 0
		 SET @Projects = '0'
		 SET @ProjectGroup = '0'
	END

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

	IF (@IsZoneRule=1 AND @Zone_PK<>0)
	BEGIN
		INSERT INTO #tmpZone(ProviderOffice_PK)
		SELECT PO.ProviderOffice_PK FROM tblZoneZipcode ZZC WITH (NOLOCK) INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ZipCode_PK = ZZC.ZipCode_PK WHERE ZZC.Zone_PK = @Zone_PK
	END

	IF (@IsLastScheduledRule=1 OR @IsScheduledTypeRule=1)
	BEGIN
		INSERT INTO #tmpSchedule(ProviderOffice_PK, ScheduleDate, ScheduleType)
		SELECT PO.ProviderOffice_PK,Sch_Start,sch_type FROM tblProviderOffice PO WITH (NOLOCK) 
			CROSS APPLY (SELECT TOP 1 *  FROM tblProviderOfficeSchedule POS WITH (NOLOCK) WHERE POS.ProviderOffice_PK = PO.ProviderOffice_PK ORDER BY LastUpdated_Date DESC) X
	END

	SELECT P.ProviderOffice_PK
		,CASE WHEN SUM(CASE WHEN S.IsScanned=0 AND S.IsCNA=0 THEN 1 ELSE 0 END)=0 THEN 6 ELSE MAX(CS.ProviderOfficeBucket_PK) END ProviderOfficeBucket_PK
		,MIN(S.FollowUp) FollowUpDate, SUM(CASE WHEN S.IsScanned=0 AND S.IsCNA=0 THEN 1 ELSE 0 END) RemainingCharts
	INTO #EligibleOffices
	FROM tblProviderOffice PO WITH (NOLOCK)
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
		INNER JOIN tblChaseStatus CS WITH (NOLOCK) ON CS.ChaseStatus_PK = S.ChaseStatus_PK
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
	GROUP BY P.ProviderOffice_PK		
	CREATE INDEX idxElgProviderOffice_PK ON #EligibleOffices (ProviderOffice_PK)

	UPDATE PO SET Pool_PK = @PoolPK
	FROM #EligibleOffices E WITH (ROWLOCK)
		INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = E.ProviderOffice_PK
		LEFT JOIN #tmpSchedule tS ON tS.ProviderOffice_PK = E.ProviderOffice_PK
		LEFT JOIN #tmpZone Z ON tS.ProviderOffice_PK = E.ProviderOffice_PK
		LEFT JOIN tblPoolBucket PB ON E.ProviderOfficeBucket_PK = PB.ProviderOfficeBucket_PK AND PB.Pool_PK = @PoolPK
		WHERE IsNull(E.RemainingCharts,0)>0
			AND (PO.Pool_PK IS NULL OR @IsForcedAllocationAllowed=1)
			AND (@IsBucketRule=0 OR PB.Pool_PK IS NOT NULL)
			AND (@IsFollowupRule=0 OR E.FollowUpDate<=GetDate())
			AND (@IsLastScheduledRule=0 OR DATEDIFF(day,ScheduleDate,GetDate())>=@DaysSinceLastScheduled)
			AND (@IsScheduledTypeRule=0 OR @ScheduledType=0 OR ScheduleType=@ScheduledType)
			AND (@IsZoneRule=0 OR @Zone_PK=0 OR Z.ProviderOffice_PK IS NOT NULL)
			AND (
					@IsRemainingRule=0
					OR (@RemainingChartsMoreOrEqual=1 AND RemainingCharts>=@RemainingCharts)
					OR (@RemainingChartsMoreOrEqual=0 AND RemainingCharts<=@RemainingCharts)
				)
END
GO
