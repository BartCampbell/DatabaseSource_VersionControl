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
			  ,IsBucketRule
			  ,IsFollowupRule
			  ,IsRemainingRule,RemainingCharts,RemainingChartsMoreOrEqual
			  ,IsLastScheduledRule,DaysSinceLastScheduled
			  ,IsScheduledTypeRule,ScheduledType
			  ,IsZoneRule,Zone_PK
			  ,IsProjectRule,Projects,ProjectGroups
			  ,SchedulerTeam_PK,Pool_Priority,IsAutoRefreshPool,PriorityWithinPool
			  ,IsForcedAllocationAllowed
			  ,X.Offices,P.Channel_PK
		  FROM dbo.tblPool P with (nolock)
			Outer Apply (
					SELECT COUNT(DISTINCT PP.ProviderOffice_PK) Offices 
					FROM tblProviderOffice PO WITH (NOLOCK)
						INNER JOIN tblProvider PP WITH (NOLOCK) ON PP.ProviderOffice_PK = PO.ProviderOffice_PK
						INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = PP.Provider_PK
						--INNER JOIN tblChaseStatus CS WITH (NOLOCK) ON CS.ChaseStatus_PK = S.ChaseStatus_PK
					WHERE S.IsScanned=0 AND S.IsCNA=0 AND S.IsCoded=0 AND PO.Pool_PK = P.Pool_PK --CS.ProviderOfficeBucket_PK<>5 AND 
			) X			
			--SELECT count(1) Offices FROM tblProviderOffice PO with (nolock) WHERE PO.Pool_PK = P.Pool_PK AND ProviderOfficeBucket_PK<>0
		ORDER BY P.Pool_Priority

	SELECT count(DISTINCT PO.ProviderOffice_PK) Offices 
		FROM tblProviderOffice PO with (nolock) 
			INNER JOIN tblProvider P with (nolock) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
			INNER JOIN tblSuspect S with (nolock) ON P.Provider_PK = S.Provider_PK
			--INNER JOIN tblChaseStatus CS WITH (NOLOCK) ON CS.ChaseStatus_PK = S.ChaseStatus_PK
		WHERE PO.Pool_PK IS NULL --AND CS.ProviderOfficeBucket_PK<>5
		AND S.IsCNA=0 AND S.IsScanned=0 AND S.IsCoded=0

		IF (@type=1)
			return ;

		SELECT ProviderOfficeBucket_PK,Bucket FROM tblProviderOfficeBucket WHERE ProviderOfficeBucket_PK>0 ORDER BY ProviderOfficeBucket_PK

		SELECT 'On Site' Sch_Type, 0 PK UNION SELECT 'Fax In',1 UNION SELECT 'Email',2 UNION SELECT 'Post',3 UNION SELECT 'Invoice',4 UNION SELECT 'EMR',5 ORDER BY PK

		SELECT Zone_PK,Zone_Name FROM tblZone ORDER BY Zone_Name

		SELECT SchedulerTeam_PK,Team_Name FROM tblSchedulerTeam ORDER BY Team_Name	
END
GO
