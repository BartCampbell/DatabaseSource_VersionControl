SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Amjad Ali
-- Create date: Jul-03-2015
-- Description:	To get Charts List in QA Report
-- =============================================
/* Sample Executions2
[qa_getChartDetails] 	@Page=1,	@PageSize=25 ,	@Alpha='' ,@usr='1' ,@dr_type=0,@pro_id=0,@Sort='' ,@Order = '',@txt_from='01/01/2015',@txt_to='12/12/2015',@date_range='2'
*/
CREATE PROCEDURE [dbo].[qa_getChartDetails]
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Usr int,
	@dr_type int,
	@Sort varchar(150),
	@Order varchar(150),
	@txt_from smalldatetime,
	@txt_to smalldatetime,
	@date_range int,
	@LoginUser int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)
	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@LoginUser)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@LoginUser AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');
	-- PROJECT SELECTION

	SET @SORT = CASE @SORT
		WHEN 'm_id' THEN 'mem.Member_ID'
		WHEN 'm_n'  THEN 'max(mem.Lastname)+'' ''+max(mem.Firstname)'
		WHEN 'dob'  THEN 'max(mem.DOB)'
		WHEN 'p_id'  THEN 'max(ProM.Provider_ID)'
		WHEN 'p_n'  THEN 'max(ProM.Lastname)+'' ''+max(ProM.Firstname)'
		WHEN 'c_d'  THEN 'max(s.Coded_Date)'
		WHEN 'q_b'  THEN 'max(ISNULL(Usr.Username,''''))'
		WHEN 'q_d'  THEN 'max(ISNULL(s.QA_Date,''''))'
		WHEN 'pro' THEN 'max(project.Project_Name)'
		ELSE 'max(mem.Lastname)+'' ''+max(mem.Firstname)'
	END;

	DECLARE @date_query AS char(100);	
	IF @date_range=0
		SET @date_query='';
	
	IF @date_range=1
		SET @date_query=' and   convert(varchar,s.QA_Date ,112)>='+ convert(varchar,@txt_from ,112)+' and convert(varchar,s.QA_Date ,112)<='+ convert(varchar,@txt_to ,112)  ;
	
	IF @date_range=2
		SET @date_query=' and  convert(varchar,s.Coded_Date ,112)>='+ convert(varchar,@txt_from ,112)+' and convert(varchar,s.Coded_Date ,112)<='+ convert(varchar,@txt_to ,112)  ;

	DECLARE @Alpha_Condition AS VARCHAR(500) = CASE WHEN @Alpha<>'' THEN 'AND mem.Lastname+'', ''+mem.Firstname Like '''+@Alpha+'%''' ELSE '' END;

	DECLARE @Type_Condition AS VARCHAR(500) = CASE @dr_type
	WHEN '1' THEN '  and ISNULL(s.QA_Date,0)!=0 ' 
	WHEN '3' THEN '  and qa.IsConfirmed=1  '
    WHEN '4' THEN '  and qa.IsChanged=1  '
    WHEN '5' THEN '  and qa.IsAdded=1  '
    WHEN '6' THEN '  and qa.IsRemoved=1 '
    WHEN '7' THEN '  and ISNULL(s.QA_Date,0)=0 '
   	ELSE '' END;
	
	
	DECLARE @SQL AS VARCHAR(MAX) = '
	
	SELECT ROW_NUMBER() OVER(ORDER BY '+@SORT+' '+@Order+') AS RowNumber, 
		max(mem.Member_ID) Member_ID, 
        max(mem.Lastname)   [Lastname], 
		max(mem.Firstname)   [Firstname],
	    max(mem.DOB) DOB, 
		max(ProM.Provider_ID) Provider_ID, 
        max(ProM.Lastname)+'' ''+max(ProM.Firstname)  [ProviderName] ,
        max(s.Coded_Date) [CodedDate] ,
		max(ISNULL(Usr.Username,'''')) as qa_user, 
        max(ISNULL(s.QA_Date,'''')) as qa_date, 
		max(project.Project_Name) as project_name, 
		max(s.Suspect_PK) Suspect_PK 
	 INTO #tbl
     FROM   tblSuspect S 
		INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
        left join tblMember Mem on s.Member_PK=Mem.Member_PK  
        left join tblProvider Pro on s.Provider_PK=Pro.Provider_PK 
		left join tblUser Usr on Usr.User_PK=s.QA_User_PK 
        left join tblProviderMaster ProM on ProM.ProviderMaster_PK=Pro.ProviderMaster_PK 
		inner join tblProject project on project.Project_PK=s.Project_PK 
	WHERE s.Coded_User_PK=' + CAST(@usr as varchar) +' ' + @Type_Condition +' '+ @date_query +' 
    GROUP BY mem.Member_ID+ProM.Provider_ID;
	
	SELECT * FROM #tbl WHERE RowNumber>'+CAST(@PageSize*(@Page-1) AS VARCHAR)+' AND RowNumber<='+CAST(@PageSize*@Page AS VARCHAR)+' ORDER BY RowNumber;
	
	SELECT UPPER(LEFT(lastname,1)) alpha1, UPPER(RIGHT(LEFT(lastname,2),1)) alpha2,Count(DISTINCT Member_ID) records
		FROM #tbl 
		GROUP BY LEFT(lastname,1), RIGHT(LEFT(lastname,2),1)			
		ORDER BY alpha1, alpha2;
	';
	EXEC (@SQL)
END
GO
