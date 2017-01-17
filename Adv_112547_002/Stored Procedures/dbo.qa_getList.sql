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
CREATE PROCEDURE [dbo].[qa_getList] 
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
	
	SELECT User_PK,Lastname+', '+Firstname Fullname,location_pk FROM tblUser WHERE IsNull(IsActive,0)=1 AND IsReviewer=1 ORDER BY Fullname

	SELECT NoteText_PK, NoteText,NoteType_PK FROM tblNoteText WITH (NOLOCK) WHERE IsDiagnosisNote=1
	
	SELECT NoteText_PK, NoteText FROM tblNoteText WITH (NOLOCK) WHERE IsChartNote=1

	SELECT * FROM tblHccCategory

	DECLARE @Location_PK AS INT
	DECLARE @IsAdmin AS INT
	DECLARE @IsManagementUser AS INT
	SELECT @Location_PK = Location_PK,@IsAdmin=IsAdmin,@IsManagementUser=IsManagementUser FROM tblUser WHERE User_PK = @User_PK;
	SELECT L.Location,L.Location_PK FROM tblLocation L WHERE L.Location_PK=@Location_PK OR @IsAdmin=1 OR @IsManagementUser=1 Order By L.Location
END
GO
