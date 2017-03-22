SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cnm_getChannelChases '0','0','0',1,107,1
Create PROCEDURE [dbo].[cnm_getChannelChases] 
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Status1 varchar(1000),
	@Status2 varchar(1000),
	@search_type int,
	@id bigint,
	@User int
AS
BEGIN
	-- PROJECT/Channel SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)

	CREATE TABLE #tmpChannel (Channel_PK INT)
	CREATE INDEX idxChannelPK ON #tmpChannel (Channel_PK)

	CREATE TABLE #tmpChaseStatus (ChaseStatus_PK INT, ChaseStatusGroup_PK INT)
	CREATE INDEX idxChaseStatusPK ON #tmpChaseStatus (ChaseStatus_PK)

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
	INSERT INTO #tmpChaseStatus(ChaseStatus_PK,ChaseStatusGroup_PK) SELECT DISTINCT ChaseStatus_PK,ChaseStatusGroup_PK FROM tblChaseStatus

	IF (@Projects<>'0')
		EXEC ('DELETE FROM #tmpProject WHERE Project_PK NOT IN ('+@Projects+')')
		
	IF (@ProjectGroup<>'0')
		EXEC ('DELETE T FROM #tmpProject T INNER JOIN tblProject P ON P.Project_PK = T.Project_PK WHERE ProjectGroup_PK NOT IN ('+@ProjectGroup+')')
		
	IF (@Channel<>'0')
		EXEC ('DELETE T FROM #tmpChannel T WHERE Channel_PK NOT IN ('+@Channel+')')	
		
	IF (@Status1<>'0')
		EXEC ('DELETE T FROM #tmpChaseStatus T WHERE ChaseStatusGroup_PK NOT IN ('+@Status1+')')	
		
	IF (@Status2<>'0')
		EXEC ('DELETE T FROM #tmpChaseStatus T WHERE ChaseStatus_PK NOT IN ('+@Status2+')')						 
	-- PROJECT/Channel SELECTION

	SELECT COUNT(DISTINCT S.Suspect_PK) Chases,IsNull(C.Channel_Name,'No Channel') Channel,S.Channel_PK
		FROM tblProviderOffice PO WITH (NOLOCK) 
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			INNER JOIN tblProject Pr ON Pr.Project_PK = S.Project_PK
			LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK		
			LEFT JOIN tblChannel C WITH (NOLOCK) ON C.Channel_PK = S.Channel_PK
	WHERE (@search_type=1 AND P.ProviderOffice_PK=@id)		--Office
		OR (@search_type=2 AND P.Provider_PK=@id)			--Provider
	GROUP BY C.Channel_Name, S.Channel_PK

	SELECT COUNT(DISTINCT S.Suspect_PK) Chases,IsNull(CS.ChaseStatus,'No Status') ChaseStatus,MIN(S.ChaseStatus_PK) ChaseStatus_PK
		FROM tblProviderOffice PO WITH (NOLOCK) 
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			INNER JOIN tblProject Pr ON Pr.Project_PK = S.Project_PK
			LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK		
			LEFT JOIN tblChaseStatus CS WITH (NOLOCK) ON CS.ChaseStatus_PK = S.ChaseStatus_PK
	WHERE (@search_type=1 AND P.ProviderOffice_PK=@id)		--Office
		OR (@search_type=2 AND P.Provider_PK=@id)			--Provider
	GROUP BY CS.ChaseStatus

	SELECT COUNT(DISTINCT S.Suspect_PK) Chases,IsNull(PM.ProviderGroup,'No Group') ProviderGroup
		FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
	WHERE (@search_type=1 AND P.ProviderOffice_PK=@id)		--Office
		OR (@search_type=2 AND P.Provider_PK=@id)			--Provider
	GROUP BY PM.ProviderGroup

	SELECT COUNT(DISTINCT S.Suspect_PK) Chases,IsNull(S.PlanLID,'No ID') PlanLocationID
		FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
	WHERE (@search_type=1 AND P.ProviderOffice_PK=@id)		--Office
		OR (@search_type=2 AND P.Provider_PK=@id)			--Provider
	GROUP BY S.PlanLID

	--Channel Log
	SELECT COUNT(DISTINCT CL.Suspect_PK) Chases,C_From.Channel_Name From_Channel, C_To.Channel_Name To_Channel, U.Lastname+IsNull(', '+U.Firstname,'') ByUser, CL.dtUpdate FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
			INNER JOIN tblChannelLog CL WITH (NOLOCK) ON CL.Suspect_PK = S.Suspect_PK
			INNER JOIN tblChannel C_To WITH (NOLOCK) ON C_To.Channel_PK = CL.To_Channel_PK
			INNER JOIN tblChannel C_From WITH (NOLOCK) ON C_From.Channel_PK = CL.From_Channel_PK
			INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = CL.User_PK
	WHERE (@search_type=1 AND P.ProviderOffice_PK=@id)		--Office
		OR (@search_type=2 AND P.Provider_PK=@id)			--Provider
	GROUP BY C_From.Channel_Name, C_To.Channel_Name, U.Lastname, U.Firstname,CL.dtUpdate
	ORDER BY CL.dtUpdate ASC

	--Chase Status Log
	SELECT COUNT(DISTINCT CL.Suspect_PK) Chases,C_From.ChaseStatus+' ('+C_From.ChartResolutionCode+')' From_Status, C_To.ChaseStatus+' ('+C_To.ChartResolutionCode+')' To_Status, U.Lastname+IsNull(', '+U.Firstname,'') ByUser, CL.dtUpdate FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
			INNER JOIN tblChaseStatusLog CL WITH (NOLOCK) ON CL.Suspect_PK = S.Suspect_PK
			INNER JOIN tblChaseStatus C_To WITH (NOLOCK) ON C_To.ChaseStatus_PK = CL.To_ChaseStatus_PK
			INNER JOIN tblChaseStatus C_From WITH (NOLOCK) ON C_From.ChaseStatus_PK = CL.From_ChaseStatus_PK
			INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = CL.User_PK
	WHERE (@search_type=1 AND P.ProviderOffice_PK=@id)		--Office
		OR (@search_type=2 AND P.Provider_PK=@id)			--Provider
	GROUP BY C_From.ChaseStatus,C_From.ChartResolutionCode, C_To.ChaseStatus, C_To.ChartResolutionCode, U.Lastname, U.Firstname,CL.dtUpdate
	ORDER BY CL.dtUpdate ASC
END
GO
