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
fa_getMembers 	@Page=2,	@PageSize=25 ,	@Alpha='A' ,@Member = '',@Sort='Name' ,@Order = 'ASC', @AmountView = 0
*/
Create PROCEDURE [dbo].[rv_getMembers]
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Member Varchar(150),
	@Sort Varchar(150),
	@Order Varchar(4)
AS
BEGIN
	SET @SORT = CASE @SORT
		WHEN 'MID' THEN 'M.Member_ID'
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
		FROM tblMember M
			INNER JOIN cacheMember CM ON CM.Member_PK = M.Member_PK
		WHERE 1=1 '+@Member_Condition+' '+@Alpha_Condition+'
	)

	SELECT * FROM tbl WHERE RowNumber>'+CAST(@PageSize*(@Page-1) AS VARCHAR)+' AND RowNumber<='+CAST(@PageSize*@Page AS VARCHAR)+'
	
	SELECT UPPER(LEFT(M.Lastname,1)) alpha1, UPPER(RIGHT(LEFT(M.Lastname,2),1)) alpha2,Count(DISTINCT M.Member_PK) records
		FROM tblMember M
		GROUP BY LEFT(M.Lastname,1), RIGHT(LEFT(M.Lastname,2),1)			
		ORDER BY alpha1, alpha2
	';
	
	EXEC (@SQL)
END


GO
