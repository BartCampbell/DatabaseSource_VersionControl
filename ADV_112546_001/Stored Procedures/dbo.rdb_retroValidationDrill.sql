SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:	Sajid Ali
-- Create date: Oct-02-2015
-- Description:	
-- =============================================
/* Sample Executions
rdb_retroValidationDrill 1,1,0,1,0
*/
CREATE PROCEDURE [dbo].[rdb_retroValidationDrill]
	@Projects varchar(20),
	@User int,
	@ProjectGroup varchar(10),
	@DrillType int,
	@ID int,
	@Export int,
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

	;With tbl AS(
		SELECT 
			ROW_NUMBER() OVER(ORDER BY M.Lastname ASC) AS [#],
			S.ChaseID,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,
			PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,
			S.Scanned_Date Extracted,
			CD.Coded_Date Coded,
			CD.DOS_Thru DOS,
			CD.DiagnosisCode [Diag Code],
			NT.NoteType [Primary],
			NTx.NoteText [Secondary Disposition Comment],
			MC.V12HCC HCC,
			H.HCC_Desc [HCC Description]
		FROM tblSuspect S WITH (NOLOCK) 
			INNER JOIN #tmpProject tP ON tP.Project_PK = S.Project_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN tblCodedData CD WITH (NOLOCK) ON S.Suspect_PK = CD.Suspect_PK
			INNER JOIN tblNoteType NT WITH (NOLOCK) ON CD.CodedSource_PK = NT.NoteType_PK
			LEFT JOIN tblCodedDataNote CDN WITH (NOLOCK) ON CD.CodedData_PK = CDN.CodedData_PK
			LEFT JOIN tblNoteText NTx ON NTx.NoteText_PK = CDN.NoteText_PK
			LEFT JOIN tblModelCode MC ON MC.DiagnosisCode = CD.DiagnosisCode
			LEFT JOIN tblHCC H ON H.HCC = MC.V12HCC AND H.PaymentModel=12
			WHERE (@Channel=0 OR S.Channel_PK=@Channel)
			AND (
			(@DrillType=0 AND CD.CodedSource_PK=@ID)
				OR (@DrillType=1 AND CDN.NoteText_PK=@ID)
				)
	)
	SELECT * FROM tbl WHERE [#]<=25 OR @Export=1 ORDER BY [#]

	IF (SELECT COUNT(*) FROM #tmpProject)>1
		SELECT '';
	ELSE
		SELECT P.Project_Name+' - ' FROM tblProject P INNER JOIN #tmpProject tP ON tP.Project_PK=P.Project_PK

	IF @DrillType=0
		SELECT 'Primary Disposition Comment ('+NoteType+')' FROM tblNoteType WHERE NoteType_PK=@ID;
	ELSE
		SELECT 'Secondary Disposition Comment ('+NoteText+')' FROM tblNoteText WHERE NoteText_PK=@ID;
END
GO
