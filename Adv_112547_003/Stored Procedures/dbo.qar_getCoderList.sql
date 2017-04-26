SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--qar_getCoderList 0,0,1,'','',0
CREATE PROCEDURE [dbo].[qar_getCoderList] 
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@User int,
	@txt_FROM smalldatetime,
	@txt_to smalldatetime,
	@date_range int,
	@location int
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

	SELECT ROW_NUMBER() OVER(ORDER BY U.Lastname) RowNumber,
		S.Coded_User_PK User_PK,
		U.Lastname+', '+U.Firstname+' ('+ U.username+')' Coder,
		COUNT(DISTINCT S.Suspect_PK) [Coded Charts],
		COUNT(DISTINCT CASE WHEN S.IsQA=1 THEN S.Suspect_PK ELSE NULL END) [QA Charts],
		CAST(Round(CAST(COUNT(DISTINCT CASE WHEN S.IsQA=1 THEN S.Suspect_PK ELSE NULL END) AS Float)/CAST(COUNT(DISTINCT S.Suspect_PK) AS Float)*100,2) AS varchar) + ' %' [% QA Charts],
		COUNT(DISTINCT CD.CodedData_PK) [Total Dx Coded],
		COUNT(DISTINCT CASE WHEN CDQ.IsConfirmed=1 THEN CDQ.CodedData_PK ELSE NULL END) [Total Dx Confirmed],
		COUNT(DISTINCT CASE WHEN CDQ.IsChanged=1 THEN CDQ.CodedData_PK ELSE NULL END) [Total Dx Changed],
		COUNT(DISTINCT CASE WHEN CDQ.IsAdded=1 THEN CDQ.CodedData_PK ELSE NULL END) [Total Dx Added],
		COUNT(DISTINCT CASE WHEN CDQ.IsRemoved=1 THEN CDQ.CodedData_PK ELSE NULL END) [Total Dx Removed],

		CASE WHEN COUNT(DISTINCT CASE WHEN CDQ.IsConfirmed=1 THEN CDQ.CodedData_PK ELSE NULL END)=0 THEN '' ELSE
		--	CAST(ROUND(CAST(COUNT(DISTINCT CASE WHEN CDQ.IsConfirmed=1 THEN CDQ.CodedData_PK ELSE NULL END) AS Float)/CAST(COUNT(DISTINCT CD.CodedData_PK)+COUNT(DISTINCT CASE WHEN CDQ.IsRemoved=1 THEN CDQ.CodedData_PK ELSE NULL END) AS Float)*100,2) AS varchar) 
		CAST(ROUND(CAST(COUNT(DISTINCT CASE WHEN CDQ.IsConfirmed=1 THEN CDQ.CodedData_PK ELSE NULL END) AS Float)/CAST(COUNT(DISTINCT CASE WHEN CDQ.IsConfirmed=1 THEN CDQ.CodedData_PK ELSE NULL END) + COUNT(DISTINCT CASE WHEN CDQ.IsAdded=1 THEN CDQ.CodedData_PK ELSE NULL END) AS float)*100,2) AS VARCHAR)
		+ ' %' END [QA Accuracy Rate]
	FROM tblSuspect S WITH (NOLOCK) 
		INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
		INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = S.Coded_User_PK
		LEFT JOIN tblCodedData CD WITH (NOLOCK) ON CD.Suspect_PK = S.Suspect_PK
		LEFT JOIN tblCodedDataQA CDQ WITH (NOLOCK) ON CD.CodedData_PK = CDQ.CodedData_PK
	WHERE S.IsCoded=1 AND IsNull(CD.Is_Deleted,0)=0
		AND (@date_range<>1 OR (CAST(S.QA_Date AS DATE)>=@txt_FROM AND CAST(S.QA_Date AS DATE)<=@txt_to))
		AND (@date_range<>2 OR (CAST(S.Coded_Date AS DATE)>=@txt_FROM AND CAST(S.Coded_Date AS DATE)<=@txt_to))
		AND (@location=0 OR U.Location_PK=@location)
	GROUP BY S.Coded_User_PK,U.Lastname,U.Firstname,U.Username
END
GO
