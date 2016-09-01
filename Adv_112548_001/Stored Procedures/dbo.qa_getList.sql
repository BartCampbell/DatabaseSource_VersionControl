SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	qa_getList 1,'1,7,8,9,0'
Create PROCEDURE [dbo].[qa_getList] 
	@User_PK smallint,
	@allowed_projects varchar(1000)
AS
BEGIN

	DECLARE @SQL AS VARCHAR(MAX)
	SET @SQL = '
	SELECT P.Project_PK,P.Project_Name,P.ProjectGroup
		FROM tblProject P WITH (NOLOCK) ';
		SET @SQL = @SQL + ' WHERE (IsRetrospective=1 OR IsProspective=1) AND P.Project_PK IN ('+ @allowed_projects +')';
	EXEC (@SQL)
	
	SET @SQL = '
	SELECT DISTINCT U.User_PK,U.Lastname+ISNULL('', ''+U.Firstname,'''') fullname 
		FROM tblUser U WITH (NOLOCK) INNER JOIN tblSuspect S ON U.User_PK = S.Coded_User_PK';
		SET @SQL = @SQL + ' WHERE S.Project_PK IN ('+ @allowed_projects +')';
	EXEC (@SQL)	


	SELECT NoteText_PK, NoteText,NoteType_PK FROM tblNoteText WITH (NOLOCK) WHERE IsDiagnosisNote=1
	
	SELECT NoteText_PK, NoteText FROM tblNoteText WITH (NOLOCK) WHERE IsChartNote=1

	SELECT * FROM tblHccCategory
END
GO
