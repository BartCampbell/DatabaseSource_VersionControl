SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Alter date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- Modify by Amjad Ali on 26-feb-2015
-- q_getList @from='', @to='', @FIN='', @filter='O', @view='Q',@coder='null',@department='null',@provider='null',@UserPK=1,@h_id=0
CREATE PROCEDURE [dbo].[q_getList] 
	@from varchar(10),
	@to varchar(10),
	@FIN varchar(15),
	@filter VARCHAR(1),
	@view VARCHAR(1),
	@coder varchar(10),
	@department varchar(10),
	@provider varchar(10),
	@UserPK INT,
	@h_id INT
AS
BEGIN
	DECLARE @SQL AS VARCHAR(MAX)
	
	SET @SQL = '
	SELECT TOP 100 E.encounter_pk
      ,department
      ,provider_name
      ,[FIN]
      ,M.member_id
      ,M.member_name
      ,[DOS]
      ,Inserted_date
      ,Q.query_text
      ,Q.task_text
      ,Q.denial_text
      ,CASE WHEN Q.IsCodedPosted=0 THEN ''Pending'' ELSE ''Coded/Posted'' END QueryResponse
      ,U.Lastname+'', ''+U.Firstname Coder
  FROM tblEncounter E WITH (NOLOCK)
	INNER JOIN tblDepartment D WITH (NOLOCK) ON D.department_pk = E.department_pk
	INNER JOIN tblProvider P WITH (NOLOCK) ON P.provider_pk = E.provider_pk
	INNER JOIN tblMember M WITH (NOLOCK) ON M.member_pk = E.member_pk
	INNER JOIN tblQuery Q WITH (NOLOCK) ON Q.Encounter_PK = E.encounter_pk
	INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = E.inserted_user_pk
  WHERE Q.query_text <> '''' AND E.h_id=' + +CAST(@h_id AS VARCHAR) ;
  IF @FIN<>''
  BEGIN 
	SET @SQL = @SQL + ' AND FIN='''+ @FIN +'''';
  END
  ELSE IF (@from='' AND @to='')
  BEGIN 
	SET @SQL = @SQL + ' AND E.inserted_user_pk='+CAST(@UserPK AS VARCHAR)+'
		AND Q.updated_date < DATEADD(hour,-72,GetDate())
		AND Q.IsCodedPosted=0'
  END  
  ELSE
  BEGIN
	SET @SQL = @SQL + ' AND inserted_date>='''+ @from +'''
		AND inserted_date<'''+ @to +'''	';

	IF @department<>'0'
		SET @SQL = @SQL + ' AND E.department_pk = '+@department;	
		
	IF @provider<>'0'
		SET @SQL = @SQL + ' AND E.provider_pk = '+@provider;			
		
	IF @coder<>'0'
		SET @SQL = @SQL + ' AND inserted_user_pk = '+@coder;	
		
	IF @filter='O'
		SET @SQL = @SQL + ' AND IsNull(Q.IsCodedPosted,0)=0';
/*		
	IF @view='Q'
		SET @SQL = @SQL + ' AND Q.query_text<>''''';		
	else IF @view='T'
		SET @SQL = @SQL + ' AND Q.task_text<>''''';		
	else IF @view='D'
		SET @SQL = @SQL + ' AND IsNull(Q.denial_text,'''')<>''''';				
		*/
	SET @SQL = @SQL + ' ORDER BY E.encounter_pk DESC';
  END
  
  EXEC (@SQL)
END
GO
