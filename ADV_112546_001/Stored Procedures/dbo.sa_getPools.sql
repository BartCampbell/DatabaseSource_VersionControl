SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sa_getPools 0
CREATE PROCEDURE [dbo].[sa_getPools] 
	@type int
AS
BEGIN
	SELECT Pool_PK,Pool_Name
			  ,IsBucketRule,ProviderOfficeBucket_PK
			  ,IsFollowupRule
			  ,IsRemainingRule,RemainingCharts,RemainingChartsMoreOrEqual
			  ,IsLastScheduledRule,DaysSinceLastScheduled
			  ,IsScheduledTypeRule,ScheduledType
			  ,IsZoneRule,Zone_PK
			  ,IsProjectRule,Projects,ProjectGroups
			  ,SchedulerTeam_PK,Pool_Priority,IsAutoRefreshPool,PriorityWithinPool
			  ,Offices
		  FROM dbo.tblPool P with (nolock)
			Outer Apply (SELECT count(1) Offices FROM tblProviderOffice PO with (nolock) WHERE PO.Pool_PK = P.Pool_PK AND ProviderOfficeBucket_PK<>0) X

	SELECT count(1) Offices FROM tblProviderOffice PO with (nolock) WHERE PO.Pool_PK IS NULL AND ProviderOfficeBucket_PK<>0

		IF (@type=1)
			return ;

		SELECT ProviderOfficeBucket_PK,Bucket FROM tblProviderOfficeBucket WHERE ProviderOfficeBucket_PK>0 ORDER BY ProviderOfficeBucket_PK

		SELECT 'On Site' Sch_Type, 0 PK UNION SELECT 'Fax In',1 UNION SELECT 'Email',2 UNION SELECT 'Post',3 UNION SELECT 'Invoice',4 UNION SELECT 'EMR',5 ORDER BY PK

		SELECT Zone_PK,Zone_Name FROM tblZone ORDER BY Zone_Name

		SELECT Project_PK, Project_Name, ProjectGroup_PK FROM tblProject WITH (NOLOCK) WHERE IsRetrospective=1 ORDER BY PROJECT_NAME
		
		SELECT DISTINCT ProjectGroup,ProjectGroup_PK FROM tblProject WITH (NOLOCK) WHERE IsRetrospective=1 ORDER BY ProjectGroup

		SELECT SchedulerTeam_PK,Team_Name FROM tblSchedulerTeam ORDER BY Team_Name

		
END
GO
