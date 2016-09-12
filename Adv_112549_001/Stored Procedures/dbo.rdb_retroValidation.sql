SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_retroValidation 0,1,0
*/
Create PROCEDURE [dbo].[rdb_retroValidation]
	@Projects varchar(20),
	@User int,
	@ProjectGroup varchar(10),
	@Channel int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@User AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');

	--Validation Status
	SELECT NT.NoteType_PK,NT.NoteType,COUNT(CD.CodedData_PK) Diags FROM tblNoteType NT WITH (NOLOCK)
		INNER JOIN tblCodedData CD WITH (NOLOCK) ON CD.CodedSource_PK = NT.NoteType_PK
		INNER JOIN tblSuspect S WITH (NOLOCK) ON CD.Suspect_PK = S.Suspect_PK
		INNER JOIN #tmpProject AP ON AP.Project_PK = S.Project_PK
	WHERE (@Channel=0 OR S.Channel_PK=@Channel)
	GROUP BY NT.NoteType_PK,NT.NoteType ORDER BY NT.NoteType

	--Validation Status
	SELECT NT.NoteText_PK,NT.NoteText NoteText,COUNT(CD.CodedData_PK) Diags,NTy.NoteType FROM tblCodedDataNote CDN WITH (NOLOCK)
		INNER JOIN tblCodedData CD WITH (NOLOCK) ON CD.CodedData_PK = CDN.CodedData_PK
		INNER JOIN tblSuspect S WITH (NOLOCK) ON CD.Suspect_PK = S.Suspect_PK
		INNER JOIN tblNoteText NT WITH (NOLOCK) ON NT.NoteText_PK = CDN.NoteText_PK
		INNER JOIN tblNoteType NTy WITH (NOLOCK) ON NT.NoteType_PK = NTy.NoteType_PK
		INNER JOIN #tmpProject AP ON AP.Project_PK = S.Project_PK		
	WHERE (@Channel=0 OR S.Channel_PK=@Channel)
	GROUP BY NTy.NoteType,NT.NoteText_PK,NT.NoteText ORDER BY NTy.NoteType DESC,Diags DESC
END
GO
