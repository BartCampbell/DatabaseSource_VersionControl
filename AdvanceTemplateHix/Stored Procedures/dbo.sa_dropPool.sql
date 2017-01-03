SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sa_dropPool @PK=1, @pool_name='test', @IsBucketRule=0, @ProviderOfficeBucket_PK=0, @IsFollowupRule=0, @IsRemainingRule=0, @RemainingCharts=0, @RemainingChartsMoreOrEqual=1, @isLastScheduledRule=0, @DaysSinceLastScheduled=0, @IsScheduledTypeRule=0, @ScheduledType=0, @IsZoneRule=0, @Zone_PK=0, @IsProjectRule=0, @Project_PK='0,11,1', @ProjectGroup_PK='1', @SchedulerTeam_PK=3, @Pool_Priority=1, @IsAutoRefreshPool=1
CREATE PROCEDURE [dbo].[sa_dropPool] 
	@PK int,
	@recreate int
AS
BEGIN
	Update tblProviderOffice SET Pool_PK=NULL WHERE Pool_PK=@PK --,AssignedDate=NULL,AssignedUser_PK=NULL
	IF @recreate=0
		DELETE tblPool WHERE Pool_PK=@PK
	ELSE
		exec sa_execPool @PK

	exec sa_getPools 1
END
GO
