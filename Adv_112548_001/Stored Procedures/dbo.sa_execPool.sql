SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sa_execPool 1
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
	DECLARE @Projects Varchar(500)
	DECLARE @ProjectGroups Varchar(500)
	DECLARE @SchedulerTeam_PK int
	DECLARE @Pool_Priority int
	DECLARE @IsAutoRefreshPool int
	DECLARE @PriorityWithinPool int

	SELECT @IsBucketRule=IsBucketRule--,@ProviderOfficeBucket_PK=ProviderOfficeBucket_PK
			,@IsFollowupRule=IsFollowupRule
			,@IsRemainingRule=IsRemainingRule,@RemainingCharts=RemainingCharts,@RemainingChartsMoreOrEqual=RemainingChartsMoreOrEqual
			,@IsLastScheduledRule=IsLastScheduledRule,@DaysSinceLastScheduled=DaysSinceLastScheduled
			,@IsScheduledTypeRule=IsScheduledTypeRule,@ScheduledType=ScheduledType
			,@IsZoneRule=IsZoneRule,@Zone_PK=Zone_PK
			,@IsProjectRule=IsProjectRule,@Projects=Projects,@ProjectGroups=ProjectGroups
			,@SchedulerTeam_PK=SchedulerTeam_PK,@Pool_Priority=Pool_Priority,@IsAutoRefreshPool=IsAutoRefreshPool,@PriorityWithinPool=PriorityWithinPool
	FROM dbo.tblPool WHERE Pool_PK = @PoolPK

	CREATE TABLE #tmpSchedule(ProviderOffice_PK BIGINT,ScheduleDate DATE,ScheduleType tinyint)
	CREATE INDEX idxProviderOffice_PK ON #tmpSchedule (ProviderOffice_PK)
	CREATE INDEX idxScheduleType ON #tmpSchedule (ScheduleType)

	CREATE TABLE #tmpZone(ProviderOffice_PK BIGINT)
	CREATE INDEX idxZProviderOffice_PK ON #tmpZone (ProviderOffice_PK)

	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)
	IF @Projects='0'
	BEGIN
		INSERT INTO #tmpProject(Project_PK)
		SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroups=0 OR ProjectGroup_PK=@ProjectGroups)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroups+'=0 OR ProjectGroup_PK='+@ProjectGroups+')');

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

	UPDATE PO SET Pool_PK = @PoolPK
	FROM tblProviderOffice PO WITH (NOLOCK)		
		CROSS APPLY (
			SELECT SUM(cPOX.charts-cPOX.extracted_count-cPOX.cna_count) RemainingCharts, MIN(follow_up) FollowUpDate
			FROM cacheProviderOffice cPOX WITH (NOLOCK) 
				INNER JOIN #tmpProject cP WITH (NOLOCK) ON cP.Project_PK = cPOX.Project_PK
			WHERE cPOX.ProviderOffice_PK = PO.ProviderOffice_PK			
			) cPO
		LEFT JOIN #tmpSchedule tS ON tS.ProviderOffice_PK = PO.ProviderOffice_PK
		LEFT JOIN #tmpZone Z ON tS.ProviderOffice_PK = PO.ProviderOffice_PK
		LEFT JOIN tblPoolBucket PB ON PO.ProviderOfficeBucket_PK = PB.ProviderOfficeBucket_PK AND PB.Pool_PK = @PoolPK
		WHERE PO.Pool_PK IS NULL
			AND (@IsBucketRule=0 OR PB.Pool_PK IS NOT NULL)
			AND (@IsFollowupRule=0 OR cPO.FollowUpDate<=GetDate())
			AND (@IsLastScheduledRule=0 OR DATEDIFF(day,ScheduleDate,GetDate())>=@DaysSinceLastScheduled)
			AND (@IsScheduledTypeRule=0 OR @ScheduledType=0 OR ScheduleType=@ScheduledType)
			AND (@IsZoneRule=0 OR @Zone_PK=0 OR Z.ProviderOffice_PK IS NOT NULL)
			AND (
					@IsRemainingRule=0
					OR (@RemainingChartsMoreOrEqual=1 AND RemainingCharts>=@RemainingCharts)
					OR (@RemainingChartsMoreOrEqual=0 AND RemainingCharts<=@RemainingCharts)
				)
--
--SELECT * FROM tblProviderOffice WHERE Pool_PK IS NOT NULL
END
GO
