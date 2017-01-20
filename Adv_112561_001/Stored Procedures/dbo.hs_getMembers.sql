SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To get Finance Report List
-- =============================================
/* Sample Executions
[hs_getMembers] 	@Page=1,	@PageSize=25 ,	@Alpha='' ,@Member = '',@Sort='Name' ,@Order = 'ASC',@project=10,@User=1,@member_id=''
*/
CREATE PROCEDURE [dbo].[hs_getMembers]
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Member Varchar(150),
	@Sort Varchar(150),
	@Order Varchar(4),
	@project INT,
	@user INT,
	@member_id varchar(100)
AS
BEGIN
	SET @SORT = CASE @SORT
		WHEN 'MID' THEN 'M.Member_ID'
		WHEN 'PID' THEN 'M.Provider_ID'		
		WHEN 'PN' THEN 'P.Lastname+'', ''+P.Firstname'			
		WHEN 'Y1'  THEN 'CF1.RAF'
		WHEN 'Y2'  THEN 'CF2.RAF'
		WHEN 'Y3'  THEN 'CF3.RAF'
		WHEN 'Y4'  THEN 'CF4.RAF'
		WHEN 'Y5'  THEN 'CF5.RAF'
		WHEN 'DOB' THEN 'M.DOB'
		WHEN 'HS' THEN 'T.dt_Insert'
		WHEN 'SC' THEN 'S.IsScanned'
		ELSE 'M.Lastname+'', ''+M.Firstname'
	END;
	
	DECLARE @IsQA AS BIT
	SELECT @IsQA = CASE WHEN IsAdmin=0 THEN IsQA ELSE IsAdmin END FROM tblUser WHERE User_PK=@user
	
	DECLARE @Member_Condition AS VARCHAR(500) = CASE WHEN @Member<>'' THEN 'AND M.Lastname+IsNull('', ''+M.Firstname,'''') Like '''+@Member+'%''' ELSE '' END;
	DECLARE @Alpha_Condition AS VARCHAR(500) = CASE WHEN @Alpha<>'' THEN 'AND M.Lastname+IsNull('', ''+M.Firstname,'''') Like '''+@Alpha+'%''' ELSE '' END;
--OUTER APPLY (SELECT TOP 1 dt_Insert FROM tblHEDIS_feedback F WHERE F.Member_PK=M.Member_PK AND F.hedis_year='+ CAST(@HEDIS_Year AS VARCHAR) +' ORDER BY dt_Insert Desc) T	

	DECLARE @SearchFiler AS VARCHAR(500) = 'S.Project_PK = '+ CAST(@project AS VARCHAR)
	if @member_id<>'' 
		SET @SearchFiler = @SearchFiler + ' AND M.Member_ID LIKE '''+ @member_id +'%'''
	DECLARE @SQL AS VARCHAR(MAX) = '
		
	With tbl AS(
	SELECT ROW_NUMBER() OVER(ORDER BY '+@SORT+' '+@Order+') AS RowNumber
			, S.Suspect_PK, S.Member_PK, M.Member_ID,M.Lastname+IsNull('', ''+M.Firstname,'''') MemberName,M.DOB 
			, PM.Provider_ID,PM.Lastname+IsNull('', ''+PM.Firstname,'''') ProviderName
			, T.dt_insert HEDIS_Date, IsNull(TS.IsScanned,0) IsScanned
		FROM tblMember M
			INNER JOIN tblSuspect S ON S.Member_PK = M.Member_PK 
			INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK	
			INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK	
			'
	IF @IsQA=0
			SET @SQL = @SQL + ' INNER JOIN tblProviderAssignment PA ON PA.Project_PK = S.Project_PK AND PA.Provider_PK = S.Provider_PK AND PA.User_PK = ' + CAST(@user AS VARCHAR)
	SET @SQL = @SQL + '		OUTER APPLY (SELECT TOP 1 dt_insert FROM tblHEDIS_feedback WHERE Suspect_PK=S.Suspect_PK ORDER BY dt_insert) T'
	SET @SQL = @SQL + '		OUTER APPLY (SELECT TOP 1 X.IsScanned FROM tblSuspect X WHERE X.Member_PK=M.Member_PK AND X.Scanned_Date IS NOT NULL) TS

		WHERE '+ @SearchFiler +' '+@Member_Condition+' '+@Alpha_Condition+'
	)

	SELECT * FROM tbl WHERE RowNumber>'+CAST(@PageSize*(@Page-1) AS VARCHAR)+' AND RowNumber<='+CAST(@PageSize*@Page AS VARCHAR)+'
	
	SELECT UPPER(LEFT(M.Lastname,1)) alpha1, UPPER(RIGHT(LEFT(M.Lastname,2),1)) alpha2,Count(DISTINCT S.Suspect_PK) records
		FROM tblMember M
			INNER JOIN tblSuspect S ON S.Member_PK = M.Member_PK'
	IF @IsQA=0
			SET @SQL = @SQL + ' INNER JOIN tblProviderAssignment PA ON PA.Project_PK = S.Project_PK AND PA.Provider_PK = S.Provider_PK AND PA.User_PK = ' + CAST(@user AS VARCHAR)
	SET @SQL = @SQL + ' WHERE '+ @SearchFiler +'			
		GROUP BY LEFT(M.Lastname,1), RIGHT(LEFT(M.Lastname,2),1)			
		ORDER BY alpha1, alpha2

	SELECT COUNT(DISTINCT M.Member_PK) Members
		FROM tblMember M
			INNER JOIN tblSuspect S ON S.Member_PK = M.Member_PK '
	IF @IsQA=0
			SET @SQL = @SQL + ' INNER JOIN tblProviderAssignment PA ON PA.Project_PK = S.Project_PK AND PA.Provider_PK = S.Provider_PK AND PA.User_PK = ' + CAST(@user AS VARCHAR)
	SET @SQL = @SQL + '	WHERE '+ @SearchFiler +'
	';
	
	exec (@SQL)
END
GO
