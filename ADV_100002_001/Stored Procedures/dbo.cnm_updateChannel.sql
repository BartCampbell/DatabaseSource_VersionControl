SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cnm_updateChannel '0','0','0',1,'0',1,1
Create PROCEDURE [dbo].[cnm_updateChannel] 
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Status1 varchar(1000),
	@Status2 varchar(1000),
	@updateType varchar(1), 
	@IDs varchar(max),  
	@User int,
	@ChannelTo int,
	@IsAllCharts int
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

	CREATE TABLE #tmpSuspect (Suspect_PK BIGINT)
	CREATE INDEX idxSuspectPK ON #tmpSuspect (Suspect_PK)
	DECLARE @SQL varchar(max)
	IF (@updateType='o')
	BEGIN
		SET @SQL = '
		INSERT INTO #tmpSuspect SELECT DISTINCT S.Suspect_PK
		FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK	
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK			
		WHERE S.Channel_PK<>'+CAST(@ChannelTo AS varchar)
		IF (@IDs<>'0')
			SET @SQL = @SQL + ' AND P.ProviderOffice_PK IN ('+@IDs+')'
	END
	ELSE IF (@updateType='p')
	BEGIN
		SET @SQL = '
		INSERT INTO #tmpSuspect SELECT DISTINCT S.Suspect_PK
		FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK		
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK		
		WHERE P.Provider_PK IN ('+@IDs+') AND S.Channel_PK<>'+CAST(@ChannelTo AS varchar)
	END
	ELSE IF (@updateType='s')
	BEGIN
		SET @SQL = '
		INSERT INTO #tmpSuspect SELECT DISTINCT S.Suspect_PK
		FROM tblSuspect S 
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
		WHERE S.Suspect_PK IN ('+@IDs+') AND S.Channel_PK<>'+CAST(@ChannelTo AS varchar)
	END

	EXEC (@SQL);

	INSERT INTO tblContactNotesOffice(Project_PK, Office_PK, ContactNote_PK, ContactNoteText, LastUpdated_User_PK, LastUpdated_Date,contact_num)
	SELECT 0,P.ProviderOffice_PK, 1 ContactNote_PK, CAST(COUNT(DISTINCT CL.Suspect_PK) AS VARCHAR)+' Chases from '+C_From.Channel_Name+' to '+C_To.Channel_Name ContactNoteText, @User LastUpdated_User_PK, GetDate() LastUpdated_Date,0 contac_num 
	FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
			INNER JOIN #tmpSuspect CL WITH (NOLOCK) ON CL.Suspect_PK = S.Suspect_PK
			INNER JOIN tblChannel C_To WITH (NOLOCK) ON C_To.Channel_PK = @ChannelTo
			INNER JOIN tblChannel C_From WITH (NOLOCK) ON C_From.Channel_PK = S.Channel_PK
	WHERE (@IsAllCharts=1 OR S.IsScanned=0)
	GROUP BY P.ProviderOffice_PK,C_From.Channel_Name, C_To.Channel_Name

	INSERT INTO tblChannelLog(Suspect_PK,From_Channel_PK,To_Channel_PK,User_PK,dtUpdate)
	SELECT S.Suspect_PK,Channel_PK,@ChannelTo,@User,GetDate() FROM #tmpSuspect tS INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = tS.Suspect_PK WHERE @IsAllCharts=1 OR S.IsScanned=0

	Update S SET Channel_PK = @ChannelTo,FollowUp=GetDate(),ChaseStatus_PK = CASE WHEN IsScanned=1 OR IsCNA=1 THEN ChaseStatus_PK ELSE 81 END FROM #tmpSuspect tS INNER JOIN tblSuspect S ON S.Suspect_PK = tS.Suspect_PK WHERE @IsAllCharts=1 OR S.IsScanned=0
END
GO
