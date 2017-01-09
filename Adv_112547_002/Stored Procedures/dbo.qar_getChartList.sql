SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--qar_getChartList 0,0,'','',0,1,1,0
CREATE PROCEDURE [dbo].[qar_getChartList]
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@txt_from smalldatetime,
	@txt_to smalldatetime,
	@date_range int,
	@User int,
	@coder int,
	@type int
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
	
	SELECT ROW_NUMBER() OVER(ORDER BY M.Lastname) RowNumber,
		S.Suspect_PK, S.ChaseID, M.Member_ID, M.Lastname+IsNull(', '+M.Firstname,'') Member, M.DOB, PM.Provider_ID, PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,
		S.Coded_Date [Coded Date],S.QA_Date [QA Date],U.Lastname+IsNull(', '+U.Firstname,'') [QA By],
		COUNT(DISTINCT CD.CodedData_PK) [Total Dx Coded],
		COUNT(DISTINCT CASE WHEN CDQ.IsConfirmed=1 THEN CDQ.CodedData_PK ELSE NULL END) [Total Dx Confirmed],
		COUNT(DISTINCT CASE WHEN CDQ.IsChanged=1 THEN CDQ.CodedData_PK ELSE NULL END) [Total Dx Changed],
		COUNT(DISTINCT CASE WHEN CDQ.IsAdded=1 THEN CDQ.CodedData_PK ELSE NULL END) [Total Dx Added],
		COUNT(DISTINCT CASE WHEN CDQ.IsRemoved=1 THEN CDQ.CodedData_PK ELSE NULL END) [Total Dx Removed]
	FROM tblSuspect S WITH (NOLOCK) 
		INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
		INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
		INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = S.QA_User_PK
		LEFT JOIN tblCodedData CD WITH (NOLOCK) ON CD.Suspect_PK = S.Suspect_PK
		LEFT JOIN tblCodedDataQA CDQ WITH (NOLOCK) ON CD.CodedData_PK = CDQ.CodedData_PK
	WHERE S.IsCoded=1 AND S.Coded_User_PK=@coder
		AND (@type <> 1 OR S.IsQA=1)
		AND (@date_range<>1 OR (CAST(S.QA_Date AS DATE)>=@txt_FROM AND CAST(S.QA_Date AS DATE)<=@txt_to))
		AND (@date_range<>2 OR (CAST(S.Coded_Date AS DATE)>=@txt_FROM AND CAST(S.Coded_Date AS DATE)<=@txt_to))
	GROUP BY S.Suspect_PK, S.ChaseID, M.Member_ID, M.Lastname,M.Firstname, M.DOB, S.QA_Date,S.Coded_Date,PM.Provider_ID, PM.Lastname,PM.Firstname,U.Lastname,U.Firstname
	HAVING 1=1 
		AND (@type <> 101 OR COUNT(DISTINCT CASE WHEN CDQ.IsConfirmed=1 THEN CDQ.CodedData_PK ELSE NULL END)>0)
		AND (@type <> 102 OR COUNT(DISTINCT CASE WHEN CDQ.IsChanged=1 THEN CDQ.CodedData_PK ELSE NULL END)>0)
		AND (@type <> 103 OR COUNT(DISTINCT CASE WHEN CDQ.IsAdded=1 THEN CDQ.CodedData_PK ELSE NULL END)>0)
		AND (@type <> 104 OR COUNT(DISTINCT CASE WHEN CDQ.IsRemoved=1 THEN CDQ.CodedData_PK ELSE NULL END)>0)
END
GO
