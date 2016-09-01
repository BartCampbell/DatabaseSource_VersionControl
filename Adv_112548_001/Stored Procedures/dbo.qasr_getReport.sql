SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--qasr_getReport 0,1,NULL,NULL,2
CREATE PROCEDURE [dbo].[qasr_getReport] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@User int,
	@from date,
	@to date,
	@date_range smallint
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)
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
	-- PROJECT SELECTION	

	SELECT ROW_NUMBER() OVER(ORDER BY U.Lastname+IsNull(', '+U.Firstname,'')) AS RowNumber
		,U.User_PK,U.Lastname+IsNull(', '+U.Firstname,'') ScanTech
		,COUNT(Distinct S.Suspect_PK) [Extracted Charts]
		,COUNT(Distinct QA.Suspect_PK) [QA Charts]
		,SUM(CASE WHEN QA.ScanningQANote_PK=1 THEN 1 ELSE 0 END) [Validated]
		,SUM(CASE WHEN QA.ScanningQANote_PK=2 THEN 1 ELSE 0 END) [Removed Pages]
		,SUM(CASE WHEN QA.ScanningQANote_PK=3 THEN 1 ELSE 0 END) [Moved Pages]
	FROM tblSuspect S WITH (NOLOCK) 
		INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
		INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = S.Scanned_User_PK
		LEFT JOIN tblScanningQANote_Suspect QA WITH (NOLOCK) ON QA.Suspect_PK = S.Suspect_PK
	WHERE S.IsScanned=1	
		AND (@date_range<>1 OR ((@from IS NULL OR QA.dtQA>=@from) AND (@to IS NULL OR QA.dtQA<=@to)))
		AND (@date_range<>2 OR ((@from IS NULL OR S.Scanned_Date>=@from) AND (@to IS NULL OR S.Scanned_Date<=@to)))
	GROUP BY U.User_PK,U.Lastname+IsNull(', '+U.Firstname,'')
END
GO
