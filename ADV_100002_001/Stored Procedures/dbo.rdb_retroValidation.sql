SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_retroValidation 0,1,0
*/
Create PROCEDURE [dbo].[rdb_retroValidation]
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Status1 varchar(1000),
	@Status2 varchar(1000),
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

	--Validation Status
	SELECT NT.NoteType_PK,NT.NoteType,COUNT(CD.CodedData_PK) Diags FROM tblNoteType NT WITH (NOLOCK)
		INNER JOIN tblCodedData CD WITH (NOLOCK) ON CD.CodedSource_PK = NT.NoteType_PK
		INNER JOIN tblSuspect S WITH (NOLOCK) ON CD.Suspect_PK = S.Suspect_PK
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
	WHERE (CD.Is_Deleted IS NULL OR CD.Is_Deleted=0) AND S.IsCoded=1
	GROUP BY NT.NoteType_PK,NT.NoteType ORDER BY NT.NoteType

	--Validation Status
	SELECT NT.NoteText_PK,NT.NoteText NoteText,COUNT(CD.CodedData_PK) Diags,NTy.NoteType FROM tblCodedDataNote CDN WITH (NOLOCK)
		INNER JOIN tblCodedData CD WITH (NOLOCK) ON CD.CodedData_PK = CDN.CodedData_PK
		INNER JOIN tblSuspect S WITH (NOLOCK) ON CD.Suspect_PK = S.Suspect_PK
		INNER JOIN tblNoteText NT WITH (NOLOCK) ON NT.NoteText_PK = CDN.NoteText_PK
		INNER JOIN tblNoteType NTy WITH (NOLOCK) ON NT.NoteType_PK = NTy.NoteType_PK
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK	
		INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
	WHERE (CD.Is_Deleted IS NULL OR CD.Is_Deleted=0) AND S.IsCoded=1
	GROUP BY NTy.NoteType,NT.NoteText_PK,NT.NoteText ORDER BY NTy.NoteType DESC,Diags DESC
END
GO
