SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To get Suspect Analysis Report
-- =============================================
--Potential
--Projected
/* Sample Executions
sa_getMembers 	@Page=1,	@PageSize=25 ,	@Alpha='' ,@Member = '',@Sort='Name' ,@Order = 'ASC', @SuspectYear = 2014
*/
CREATE PROCEDURE [dbo].[sa_getMembers]
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Member Varchar(150),
	@Sort Varchar(150),
	@Order Varchar(4),
	@SuspectYear smallint
AS
BEGIN
	SET @SORT = CASE @SORT
		WHEN 'MID' THEN 'M.Member_ID'
		WHEN 'PH'  THEN 'PreHCCs'
		WHEN 'PR'  THEN 'PreRAF'
		WHEN 'PV'  THEN 'PreRAF'
		WHEN 'RH'  THEN 'PostHCCs'
		WHEN 'RR'  THEN 'PostRAF'
		WHEN 'RV'  THEN 'PostRAF'
		WHEN 'DOB' THEN 'M.DOB'
		WHEN 'CES' THEN 'CM.CE_Start '+@Order+',CM.CE_End '
		ELSE 'M.Lastname+'', ''+M.Firstname'
	END;
	
	DECLARE @Member_Condition AS VARCHAR(500) = CASE WHEN @Member<>'' THEN 'AND M.Lastname+'', ''+M.Firstname Like '''+@Member+'%''' ELSE '' END;
	DECLARE @Alpha_Condition AS VARCHAR(500) = CASE WHEN @Alpha<>'' THEN 'AND M.Lastname+'', ''+M.Firstname Like '''+@Alpha+'%''' ELSE '' END;
	
	DECLARE @SQL AS VARCHAR(MAX) = '

	With tbl AS(
	SELECT ROW_NUMBER() OVER(ORDER BY '+@SORT+' '+@Order+') AS RowNumber
			, M.Member_PK, M.Member_ID,M.Lastname+'', ''+M.Firstname MemberName,M.DOB, CM.CE_Start, CM.CE_End
			, PreHCCs,PreRAF,S.PreRAF*S.BidRate PreAmount
			, PostHCCs,PostRAF,S.PostRAF*S.BidRate PostAmount
		FROM tblMember M
			INNER JOIN cacheMember CM ON CM.Member_PK = M.Member_PK
			INNER JOIN cacheSuspect S ON S.Member_PK = M.Member_PK AND S.SuspectYear = '+CAST(@SuspectYear AS VARCHAR)+'
		WHERE PreHCCs>PostHCCs '+@Member_Condition+' '+@Alpha_Condition+'
	)

	SELECT * FROM tbl WHERE RowNumber>'+CAST(@PageSize*(@Page-1) AS VARCHAR)+' AND RowNumber<='+CAST(@PageSize*@Page AS VARCHAR)+'
	
	SELECT UPPER(LEFT(M.Lastname,1)) alpha1, UPPER(RIGHT(LEFT(M.Lastname,2),1)) alpha2,Count(DISTINCT M.Member_PK) records
		FROM tblMember M
			INNER JOIN cacheMember CM ON CM.Member_PK = M.Member_PK
			INNER JOIN cacheSuspect S ON S.Member_PK = M.Member_PK AND S.SuspectYear = '+CAST(@SuspectYear AS VARCHAR)+'	
		WHERE PreHCCs>PostHCCs	
		GROUP BY LEFT(M.Lastname,1), RIGHT(LEFT(M.Lastname,2),1)			
		ORDER BY alpha1, alpha2

	SELECT COUNT(DISTINCT M.Member_PK) Members 
			, SUM(S.PreHCCs) PreHCCs,SUM(S.PreRAF)/COUNT(DISTINCT M.Member_PK) PreRAF,SUM(S.PreRAF*S.BidRate) PreAmount
			, SUM(S.PostHCCs) PostHCCs,SUM(S.PostRAF)/COUNT(DISTINCT M.Member_PK) PostRAF,SUM(S.PostRAF*S.BidRate) PostAmount
		FROM tblMember M
			INNER JOIN cacheMember CM ON CM.Member_PK = M.Member_PK
			INNER JOIN cacheSuspect S ON S.Member_PK = M.Member_PK AND S.SuspectYear = '+CAST(@SuspectYear AS VARCHAR)+'
		WHERE PreHCCs>PostHCCs
	';
	
	EXEC (@SQL)
END


GO
