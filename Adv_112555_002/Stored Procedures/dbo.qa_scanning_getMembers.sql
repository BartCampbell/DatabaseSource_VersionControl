SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of members in a project
-- =============================================
--	qa_scanning_getMembers 0,0,1,100,1,'','',1,1,1
CREATE PROCEDURE [dbo].[qa_scanning_getMembers] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@scantech int, 
	@scantech_percentage int, 
	@all_dates int, 
	@date_from varchar(15),
	@date_to varchar(15),
	@only_does_not_belong int,
	@only_image_issue int,
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
	SELECT TOP '+CAST(@scantech_percentage AS VARCHAR)+' PERCENT 
			S.Suspect_PK,M.Member_PK,M.Member_ID,M.Lastname+ISNULL('', ''+M.Firstname,'''') Member_Name, M.DOB
			,CASE WHEN Coded_User_PK IS NULL THEN 0 ELSE 1 END Coded
			,Scanned_Date, U.Lastname+'', ''+U.Firstname Scanned_User
			,SN.dtQA QA_Date, QA.Lastname+'', ''+QA.Firstname QA_User
			,PM.Provider_ID,PM.Lastname+ISNULL('', ''+PM.Firstname,'''') Provider_Name			
			,P.Project_PK,P.Project_Name
		FROM tblMember M WITH (NOLOCK) 
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Member_PK = M.Member_PK 
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblProject P WITH (NOLOCK) ON S.Project_PK = P.Project_PK
			INNER JOIN tblProvider PP WITH (NOLOCK) ON PP.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PP.ProviderMaster_PK = PM.ProviderMaster_PK'
	IF (@only_does_not_belong=1 OR @only_image_issue=1)
	BEGIN
		SET @SQL = @SQL + ' CROSS APPLY (SELECT TOP 1 SD.ScannedData_PK FROM tblScannedData SD WITH (NOLOCK) INNER JOIN tblScannedDataPageStatus SDPS WITH (NOLOCK) ON SD.ScannedData_PK = SDPS.ScannedData_PK WHERE SD.Suspect_PK=S.Suspect_PK AND PageStatus_PK IN (10'
		IF (@only_does_not_belong=1)
			SET @SQL = @SQL + ',2'
		IF (@only_image_issue=1)
			SET @SQL = @SQL + ',3'
		SET @SQL = @SQL + ' )) X'
	END
	SET @SQL = @SQL + ' 		
			LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = S.Scanned_User_PK
			LEFT JOIN tblScanningQANote_Suspect SN WITH (NOLOCK) ON SN.Suspect_PK = S.Suspect_PK
			LEFT JOIN tblUser QA WITH (NOLOCK) ON QA.User_PK = SN.QA_User_PK
		WHERE S.LinkedSuspect_PK IS NULL AND S.IsScanned=1'
	SET @SQL = Replace(@SQL,'TOP 100 PERCENT','TOP 1000') 

	IF (@scantech<>0)
		SET @SQL = @SQL + ' AND S.Scanned_User_PK=' + CAST(@scantech AS VARCHAR)

	IF (@all_dates=0)
		SET @SQL = @SQL + ' AND S.Scanned_Date>=''' + @date_from + ''' AND S.Scanned_Date<=''' + @date_to + ''''
		
	SET @SQL = @SQL + ' ORDER BY NEWID()'
	
	--PRINT @SQL;
	EXEC (@SQL);
END
GO
