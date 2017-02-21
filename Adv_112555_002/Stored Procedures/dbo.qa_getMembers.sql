SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of members in a project
-- =============================================
--	qa_getMembers 0,0,100,1,'','','0,1,7,10','6',''
--	qa_getMembers 0,0,100,1,'','','1,2,3,4,5,6,7,8,9,10','3','''25000'''
CREATE PROCEDURE [dbo].[qa_getMembers] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@coder int, 
	@coded_percentage int, 
	@all_dates int, 
	@date_from varchar(15),
	@date_to varchar(15),
	@disease varchar(3),
	@diags varchar(1000),
	@user int
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
		
	DECLARE @SQL VARCHAR(MAX)	
	SET @SQL = '
	SELECT TOP '+CAST(@coded_percentage AS VARCHAR)+' PERCENT 
			S.Suspect_PK,M.Member_PK,M.Member_ID,M.Lastname+ISNULL('', ''+M.Firstname,'''') Member_Name, M.DOB
			,CASE WHEN Scanned_User_PK IS NULL THEN 0 ELSE 1 END Scanned
			,Coded_Date, U.Lastname+'', ''+U.Firstname Coded_User
			,QA_Date, QA.Lastname+'', ''+QA.Firstname QA_User
			,PM.Provider_ID,PM.Lastname+ISNULL('', ''+PM.Firstname,'''') Provider_Name			
			,P.Project_PK,P.Project_Name
		FROM tblMember M WITH (NOLOCK) 
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Member_PK = M.Member_PK 
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblProject P WITH (NOLOCK) ON S.Project_PK = P.Project_PK
			INNER JOIN tblProvider PP WITH (NOLOCK) ON PP.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PP.ProviderMaster_PK = PM.ProviderMaster_PK
			';
	SET @SQL = Replace(@SQL,'TOP 100 PERCENT','TOP 1000') 
	IF @disease<>'0'
	BEGIN
		SET @SQL = @SQL + ' 
			INNER JOIN (SELECT DISTINCT Suspect_PK FROM tblCodedData tCD 
				INNER JOIN tblModelCode MC ON MC.DiagnosisCode = tCD.DiagnosisCode
				INNER JOIN tblHCC H ON ((H.HCC = MC.V12HCC AND H.PaymentModel=12) OR (H.HCC = MC.V22HCC AND H.PaymentModel=22) OR (H.HCC = MC.V21HCC AND H.PaymentModel=21)) AND H.HccCategory_Pk='+@disease+'
			) CD1 ON CD1.Suspect_PK = S.Suspect_PK
		';
	END
	IF @diags<>''
	BEGIN
		SET @SQL = @SQL + ' INNER JOIN (SELECT DISTINCT Suspect_PK FROM tblCodedData tCD WHERE tCD.DiagnosisCode IN ('+ @diags +')) CD2 ON CD2.Suspect_PK = S.Suspect_PK';
	END
	SET @SQL = @SQL + ' 
			LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = S.Coded_User_PK
			LEFT JOIN tblUser QA WITH (NOLOCK) ON QA.User_PK = S.QA_User_PK
		WHERE S.IsCoded=1'
	
	IF (@coder<>0)
		SET @SQL = @SQL + ' AND S.Coded_User_PK=' + CAST(@coder AS VARCHAR)

	IF (@all_dates=0)
		SET @SQL = @SQL + ' AND S.Coded_Date>=''' + @date_from + ''' AND S.Coded_Date<=''' + @date_to + ''''
		
	SET @SQL = @SQL + ' ORDER BY NEWID()'
	
	--PRINT @SQL;
	EXEC (@SQL);
END
GO
