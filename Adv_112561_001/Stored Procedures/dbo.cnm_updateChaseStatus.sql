SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cnm_updateChaseStatus '0','0','0','0','0',1,1
Create PROCEDURE [dbo].[cnm_updateChaseStatus] 
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Status1 varchar(1000),
	@Status2 varchar(1000),
	@updateType varchar(1), 
	@IDs varchar(max),  
	@User int,
	@ChaseStatus int
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
		WHERE S.Channel_PK<>'+CAST(@ChaseStatus AS varchar)
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
		WHERE P.Provider_PK IN ('+@IDs+') AND S.Channel_PK<>'+CAST(@ChaseStatus AS varchar)
	END
	ELSE IF (@updateType='s')
	BEGIN
		SET @SQL = '
		INSERT INTO #tmpSuspect SELECT DISTINCT S.Suspect_PK
		FROM tblSuspect S 
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
		WHERE S.Suspect_PK IN ('+@IDs+') AND S.Channel_PK<>'+CAST(@ChaseStatus AS varchar)
	END

	EXEC (@SQL);

	DECLARE @IsNotContacted AS TinyInt
	DECLARE @IsSchedulingInProgress AS TinyInt
	DECLARE @IsScheduled AS TinyInt
	DECLARE @IsExtracted AS TinyInt
	DECLARE @IsCNA AS TinyInt
	DECLARE @IsCoded AS TinyInt
	DECLARE @IsOverwriteSchedule AS TinyInt 
	DECLARE @ChartResolutionCode AS VARCHAR(200)
	DECLARE @IsOverwriteCNA AS TinyInt = 0

	SELECT @IsOverwriteSchedule = CASE WHEN ProviderOfficeBucket_PK = 5 THEN 1 ELSE 0 END, @ChartResolutionCode = ChartResolutionCode, @IsNotContacted = IsNotContacted, @IsSchedulingInProgress = IsSchedulingInProgress, @IsScheduled = IsScheduled, @IsExtracted = IsExtracted, @IsCNA = IsCNA, @IsCoded = IsCoded FROM tblChaseStatus WHERE ChaseStatus_PK = @ChaseStatus
	IF (@ChartResolutionCode='Project Change')
		SET @IsOverwriteCNA = 1

	DELETE tS FROM #tmpSuspect tS 
		INNER JOIN tblSuspect S ON S.Suspect_PK = tS.Suspect_PK
		INNER JOIN tblChaseStatus CS ON CS.ChaseStatus_PK = S.ChaseStatus_PK
	WHERE NOT (		--To make sure only correct chase status can be set
			@IsCoded=1 OR	--Coder flag can overwrite any other status
			(@IsExtracted = 1 AND CS.IsCoded=0) OR	--Extracted flag can overwrite any other status except for Codeded
			(@IsCNA = 1 AND CS.IsCoded=0 AND CS.IsExtracted=0) OR --IsCNA flag can overwrite any other status except for Codeded and Extracted
			(@IsOverwriteCNA = 1 AND CS.IsCoded=0 AND CS.IsExtracted=0) OR --@IsOverwriteCNA flag can overwrite any other status except for Codeded and Extracted
			((@IsScheduled = 1 OR @IsOverwriteSchedule=1) AND CS.IsCNA = 0 AND CS.IsCoded=0 AND CS.IsExtracted=0) OR
			(@IsSchedulingInProgress = 1 AND CS.IsScheduled = 0 AND CS.IsCNA = 0 AND CS.IsCoded=0 AND CS.IsExtracted=0) OR
			(@IsNotContacted=1 AND CS.IsSchedulingInProgress = 0 AND CS.IsScheduled = 0 AND CS.IsCNA = 0 AND CS.IsCoded=0 AND CS.IsExtracted=0)
		)

	INSERT INTO tblContactNotesOffice(Project_PK, Office_PK, ContactNote_PK, ContactNoteText, LastUpdated_User_PK, LastUpdated_Date,contact_num)
	SELECT 0, P.ProviderOffice_PK, 1 ContactNote_PK, CAST(COUNT(DISTINCT CL.Suspect_PK) AS VARCHAR)+' Chases from '+C_From.ChaseStatus+' to '+C_To.ChaseStatus ContactNoteText, @User LastUpdated_User_PK, GetDate() LastUpdated_Date,0 contac_num 
	FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
			INNER JOIN #tmpSuspect CL WITH (NOLOCK) ON CL.Suspect_PK = S.Suspect_PK
			INNER JOIN tblChaseStatus C_To WITH (NOLOCK) ON C_To.ChaseStatus_PK = @ChaseStatus
			INNER JOIN tblChaseStatus C_From WITH (NOLOCK) ON C_From.ChaseStatus_PK = S.ChaseStatus_PK
	GROUP BY P.ProviderOffice_PK,C_From.ChaseStatus, C_To.ChaseStatus

	INSERT INTO tblChaseStatusLog(Suspect_PK,From_ChaseStatus_PK,To_ChaseStatus_PK,User_PK,dtUpdate)
	SELECT S.Suspect_PK,ChaseStatus_PK,@ChaseStatus,@User,GetDate() FROM #tmpSuspect tS INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = tS.Suspect_PK

	Update S SET ChaseStatus_PK = @ChaseStatus, 
			IsCoded = CASE WHEN @IsCoded=1 AND S.IsCoded=0 THEN 1 ELSE S.IsCoded END,
			Coded_Date = CASE WHEN @IsCoded=1 AND S.IsCoded=0 THEN GetDate() ELSE S.Coded_Date END,
			Coded_User_PK = CASE WHEN @IsCoded=1 AND S.IsCoded=0 THEN 1 ELSE S.Coded_User_PK END,
			IsScanned = CASE WHEN @IsExtracted=1 AND S.IsScanned=0 THEN 1 ELSE S.IsScanned END,
			Scanned_Date = CASE WHEN @IsExtracted=1 AND S.IsScanned=0 THEN GetDate() ELSE S.Scanned_Date END,
			Scanned_User_PK = CASE WHEN @IsExtracted=1 AND S.IsScanned=0 THEN 1 ELSE S.Scanned_User_PK END,
			IsCNA = CASE WHEN @IsOverwriteCNA=1 THEN 0 WHEN @IsCNA=1 AND S.IsCNA=0 THEN 1 ELSE S.IsCNA END,
			CNA_Date = CASE WHEN @IsOverwriteCNA=1 THEN NULL WHEN @IsCNA=1 AND S.IsCNA=0 THEN GetDate() ELSE S.CNA_Date END,
			CNA_User_PK = CASE WHEN @IsOverwriteCNA=1 THEN NULL WHEN @IsCNA=1 AND S.IsCNA=0 THEN 1 ELSE S.CNA_User_PK END
		FROM #tmpSuspect tS 
		INNER JOIN tblSuspect S ON S.Suspect_PK = tS.Suspect_PK
/*
	WHERE @IsCoded=1 OR
		(@IsExtracted = 1 AND CS.IsCoded=0) OR
		(@IsCNA = 1 AND CS.IsCoded=0 AND CS.IsExtracted=0) OR 
		(@IsScheduled = 1 AND CS.IsCNA = 0 AND CS.IsCoded=0 AND CS.IsExtracted=0) OR
		(@IsSchedulingInProgress = 1 AND CS.IsScheduled = 0 AND CS.IsCNA = 0 AND CS.IsCoded=0 AND CS.IsExtracted=0) OR
		(@IsNotContacted=1 AND CS.IsSchedulingInProgress = 0 AND CS.IsScheduled = 0 AND CS.IsCNA = 0 AND CS.IsCoded=0 AND CS.IsExtracted=0)
		*/
END
GO
