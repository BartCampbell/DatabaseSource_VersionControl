SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sa_savePool @PK=1, @pool_name='test', @IsBucketRule=0, @ProviderOfficeBucket_PK=0, @IsFollowupRule=0, @IsRemainingRule=0, @RemainingCharts=0, @RemainingChartsMoreOrEqual=1, @isLastScheduledRule=0, @DaysSinceLastScheduled=0, @IsScheduledTypeRule=0, @ScheduledType=0, @IsZoneRule=0, @Zone_PK=0, @IsProjectRule=0, @Project_PK='0,11,1', @ProjectGroup_PK='1', @SchedulerTeam_PK=3, @Pool_Priority=1, @IsAutoRefreshPool=1
CREATE PROCEDURE [dbo].[sa_savePool] 
	@PK int,
	@Pool_name varchar(50),
	@IsBucketRule int, 
	@ProviderOfficeBucket_PK varchar(100), 
	@IsFollowupRule int, 
	@IsRemainingRule int, 
	@RemainingCharts int, 
	@RemainingChartsMoreOrEqual int, 
	@IsLastScheduledRule int, 
	@DaysSinceLastScheduled int, 
	@IsScheduledTypeRule int, 
	@ScheduledType int, 
	@IsZoneRule int, 
	@Zone_PK int, 
	@IsProjectRule int, 
	@Project_PK Varchar(500), 
	@ProjectGroup_PK Varchar(500), 
	@SchedulerTeam_PK int, 
	@Pool_Priority int, 
	@IsAutoRefreshPool int,
	@PriorityWithinPool int,
	@IsForcedAllocationAllowed int
AS
BEGIN
	if @PK=0
	BEGIN
		INSERT INTO tblPool(Pool_Name, IsBucketRule, IsFollowupRule, IsRemainingRule, RemainingCharts, RemainingChartsMoreOrEqual, IsLastScheduledRule, DaysSinceLastScheduled, IsScheduledTypeRule, ScheduledType, IsZoneRule, Zone_PK, IsProjectRule, Projects, ProjectGroups, SchedulerTeam_PK, Pool_Priority, IsAutoRefreshPool,PriorityWithinPool,IsForcedAllocationAllowed) 
		VALUES (@Pool_name, @IsBucketRule, @IsFollowupRule, @IsRemainingRule, @RemainingCharts, @RemainingChartsMoreOrEqual, @IsLastScheduledRule, @DaysSinceLastScheduled, @IsScheduledTypeRule, @ScheduledType, @IsZoneRule, @Zone_PK, @IsProjectRule, @Project_PK, @ProjectGroup_PK, @SchedulerTeam_PK, @Pool_Priority, @IsAutoRefreshPool,@PriorityWithinPool,@IsForcedAllocationAllowed)
		SELECT @PK=@@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE tblPool SET Pool_name=@Pool_name, IsBucketRule=@IsBucketRule, IsFollowupRule=@IsFollowupRule, IsRemainingRule=@IsRemainingRule, RemainingCharts=@RemainingCharts, RemainingChartsMoreOrEqual=@RemainingChartsMoreOrEqual, IsLastScheduledRule=@IsLastScheduledRule, DaysSinceLastScheduled=@DaysSinceLastScheduled, IsScheduledTypeRule=@IsScheduledTypeRule, ScheduledType=@ScheduledType, IsZoneRule=@IsZoneRule, Zone_PK=@Zone_PK, IsProjectRule=@IsProjectRule, Projects=@Project_PK, ProjectGroups=@ProjectGroup_PK, SchedulerTeam_PK=@SchedulerTeam_PK, Pool_Priority=@Pool_Priority, IsAutoRefreshPool=@IsAutoRefreshPool, PriorityWithinPool=@PriorityWithinPool, IsForcedAllocationAllowed=@IsForcedAllocationAllowed
		WHERE Pool_PK = @PK
	END	

	DELETE FROM tblPoolBucket WHERE Pool_PK=@PK
	IF (@IsBucketRule=1)
	BEGIN
		DECLARE @SQL AS VARCHAR(MAX)
		SET @SQL = 'INSERT INTO tblPoolBucket(Pool_PK,ProviderOfficeBucket_PK) SELECT '+CAST(@PK AS VARCHAR)+',ProviderOfficeBucket_PK FROM tblProviderOfficeBucket WHERE ProviderOfficeBucket_PK IN ('+@ProviderOfficeBucket_PK+')'
		EXEC (@SQL); 
	END

	exec sa_execPool @PK
	exec sa_getPools 1
END
GO
