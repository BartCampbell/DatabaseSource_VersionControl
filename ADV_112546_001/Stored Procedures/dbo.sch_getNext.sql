SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--UPDAtE tblProviderOffice SET AssignedUser_PK=NULL, AssignedDate=NULL wHERE AssignedUser_PK IS NOT NULL
--SELECT * FROM tblProviderOffice wHERE AssignedUser_PK IS NOT NULL ORDER BY AssignedDate DESC
--SELECT * FRom cacheProviderOffice WHERE ProviderOffice_PK IN (1,107)
--sELEcT * from tblPool
--SELECT * FROM cacheProviderOffice cPO WHERE cPO.charts-cPO.extracted_count-cPO.cna_count>0
--	sch_getNext 1
CREATE PROCEDURE [dbo].[sch_getNext] 
	@user smallint
AS
BEGIN
	--Getting List of Assigned Pools
	SELECT DISTINCT P.Pool_PK,P.Pool_Priority,0 UnassignedOffices,P.PriorityWithinPool INTO #tmpPool
		FROM tblPool P WITH (NOLOCK) 
			INNER JOIN tblSchedulerTeam ST WITH (NOLOCK) ON P.SchedulerTeam_PK = ST.SchedulerTeam_PK	
			INNER JOIN tblSchedulerTeamDetail STD WITH (NOLOCK) ON STD.SchedulerTeam_PK = ST.SchedulerTeam_PK
		WHERE STD.Scheduler_User_PK = @user
		Order By Pool_Priority ASC

	CREATE INDEX idxPoolPK ON #tmpPool (Pool_PK)

	--Setting Remaining Offices for Each Pool
	Update P SET UnassignedOffices = Offices
		FROM #tmpPool P
			Outer Apply (SELECT COUNT(1) Offices FROM tblProviderOffice PO WITH (NOLOCK) WHERE PO.Pool_PK=P.Pool_PK AND AssignedUser_PK IS NULL) X

	DELETE FROM #tmpPool WHERE UnassignedOffices=0

	IF NOT EXISTS (SELECT * FROM #tmpPool)
	BEGIN
		SELECT top 0 * FROM #tmpPool
		Return ;
	END

	DELETE FROM #tmpPool WHERE Pool_Priority<>(SELECT TOP 1 Pool_Priority FROM #tmpPool ORDER BY Pool_Priority ASC)

	DECLARE @ProviderOffice_PK AS BIGINT
	IF (SELECT TOP 1 PriorityWithinPool FROM #tmpPool)=0
	BEGIN	--WHEN Priority Within Pool is Older Follow up date
		SELECT TOP 1 @ProviderOffice_PK=PO.ProviderOffice_PK
			FROM #tmpPool P
				INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.Pool_PK=P.Pool_PK
				INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON PO.ProviderOffice_PK=cPO.ProviderOffice_PK
			WHERE PO.AssignedUser_PK IS NULL AND cPO.charts-cPO.extracted_count-cPO.cna_count>0 AND PO.ProviderOfficeBucket_PK NOT IN (0,7,8,10)
			GROUP BY PO.ProviderOffice_PK
			ORDER BY Min(IsNull(follow_up,'2014-1-1')) ASC
	END
	ELSE ----WHEN Priority Within Pool is higher number of remaining charts
	BEGIN
		SELECT TOP 1 @ProviderOffice_PK=PO.ProviderOffice_PK
			FROM #tmpPool P
				INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.Pool_PK=P.Pool_PK
				INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON PO.ProviderOffice_PK=cPO.ProviderOffice_PK		
			WHERE PO.AssignedUser_PK IS NULL AND cPO.charts-cPO.extracted_count-cPO.cna_count>0 AND PO.ProviderOfficeBucket_PK NOT IN (0,7,8,10)
			GROUP BY PO.ProviderOffice_PK
			HAVing Min(IsNull(follow_up,'2014-1-1'))<=GetDate() 
			ORDER BY SUM(cPO.charts-cPO.extracted_count-cPO.cna_count) DESC					
	END

	IF (@ProviderOffice_PK IS NULL)
	BEGIN
		SELECT TOP 0 * FROM #tmpPool
		Return ;		
	END

	UPDATE tblProviderOffice SET AssignedUser_PK=@user,AssignedDate=GetDate() WHERE ProviderOffice_PK=@ProviderOffice_PK

	EXEC sch_getOffice @channel=0, @Projects='0', @ProjectGroup='0', @Page=1, @PageSize=1, @Alpha='', @Sort='', @Order='', @Provider=0, @bucket=-1, @followup_bucket=0, @user=@user, @scheduler=0, @PoolPK=0, @ZonePK=0, @OFFICE=@ProviderOffice_PK,@address=''
END
GO
