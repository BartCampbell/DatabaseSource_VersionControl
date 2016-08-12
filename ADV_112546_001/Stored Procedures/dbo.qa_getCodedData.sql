SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Amjad Ali
-- Create date: June-23-2015
-- Description:	QA Report will use this
-- =============================================
CREATE PROCEDURE [dbo].[qa_getCodedData] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@User int,
	@txt_FROM smalldatetime,
	@txt_to smalldatetime,
	@date_range int
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

	DECLARE @date_query AS char(100);	
	IF @date_range=0
		SET @date_query='';
	
	
	IF @date_range=1
		SET @date_query=' and   convert(varchar,s.QA_Date ,112)>='+ convert(varchar,@txt_FROM ,112)+' and convert(varchar,s.QA_Date ,112)<='+ convert(varchar,@txt_to ,112)  ;
	
	IF @date_range=2
		SET @date_query=' and  convert(varchar,s.Coded_Date ,112)>='+ convert(varchar,@txt_FROM ,112)+' and convert(varchar,s.Coded_Date ,112)<='+ convert(varchar,@txt_to ,112)  ;	
		
	EXEC ('SELECT  ROW_NUMBER() OVER(ORDER BY max(s.Coded_User_PK)) as RowNumber 
				,max(s.Coded_User_PK) as [User_PK]
				,max(CUsr.Lastname+'', ''+CUsr.Firstname+'' (''+ CUsr.username+'')'') as [User_Name]
				,count(s.Coded_User_PK) as [Total Coded Charts]
				,COUNT(CASE WHEN s.IsQA = 1 THEN 1 END) AS [QA Sample]
				,max(Coded_data.Coded) as [Total Coded]
				,max(ISNULL(QA_data.QA,0)) as [Total QA]
				,max(ISNULL(QA_data.Added,0)) as Added
				,max(ISNULL(QA_data.Changed,0)) as Changed
				,max(ISNULL(QA_data.Confirmed,0)) as Confirmed
				,max(ISNULL(QA_data.Removed,0)) as Removed
		FROM [dbo].[tblSuspect] S
		INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
		INNER JOIN tblUser CUsr on CUsr.User_PK=s.Coded_User_PK
		LEFT JOIN (
				SELECT	max(cd.Coded_User_PK) as Coded_User_PK
					,COUNT(CD.CodedData_PK) [QA]
					,SUM(CAST(IsConfirmed AS TinyInt)) Confirmed 
					,SUM(CAST(IsChanged AS TinyInt)) Changed 
					,SUM(CAST(IsAdded AS TinyInt)) Added 
					,SUM(CAST(IsRemoved AS TinyInt)) Removed  
				FROM tblSuspect s
				INNER JOIN tblCodedData CD on CD.Suspect_PK=s.Suspect_PK
				LEFT JOIN tblCodedDataQA QA on QA.CodedData_PK=cd.CodedData_PK 
				WHERE s.IsQA=1 '+ @date_query +'
				group by s.Coded_User_PK 
				) QA_data on QA_data.Coded_User_PK=s.Coded_User_PK
		INNER JOIN (
				SELECT	max(cd.Coded_User_PK) as Coded_User_PK,COUNT(CD.CodedData_PK) [Coded]
				FROM tblSuspect s
				INNER JOIN tblCodedData CD on CD.Suspect_PK=s.Suspect_PK
				WHERE s.IsCoded=1 '+ @date_query +'
				group by cd.Coded_User_PK
				) Coded_data on Coded_data.Coded_User_PK=s.Coded_User_PK
		WHERE s.IsCoded=1 '+ @date_query +'  group by s.Coded_User_PK')
END
GO
