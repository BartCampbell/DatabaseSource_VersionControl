SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Jul-03-2015
-- Description:	
-- =============================================
/* Sample Executions
ua_getList 2,'',''
*/
CREATE PROCEDURE [dbo].[ua_getList]
	@DateType int,
	@startDate varchar(12),
	@endDate varchar(12)
AS
BEGIN
	DECLARE @SQL VARCHAR(MAX)
	SET @SQL = '
		SELECT ROW_NUMBER() OVER(ORDER BY US.Session_PK) AS RowNumber,US.Session_PK,U.Lastname+'', ''+U.Firstname UserFullname,Username,US.SessionStart,US.SessionEnd
		FROM tblUserSession US INNER JOIN tblUser U ON U.User_PK = US.User_PK 
		WHERE 1=1 ';

	IF @DateType = 1
		SET @SQL = @SQL + ' AND DATEPART(wk, US.SessionStart) = DATEPART(wk, GETDATE()-7) AND DATEPART(yy, US.SessionStart) = DATEPART(yy, GETDATE()-7)'
	ELSE IF @DateType = 2
		SET @SQL = @SQL + ' AND DATEPART(wk, US.SessionStart) = DATEPART(wk, GETDATE()) AND DATEPART(yy, US.SessionStart) = DATEPART(yy, GETDATE())'
	ELSE IF @DateType = 3
		SET @SQL = @SQL + ' AND Month(US.SessionStart) = Month(GETDATE()) AND Year(US.SessionStart) = Year(GETDATE())'
	ELSE IF @DateType = 4
		SET @SQL = @SQL + ' AND Month(US.SessionStart) = Month(DateAdd(month,-1,getdate())) AND Year(US.SessionStart) = Year(DateAdd(month,-1,getdate()))'
	ELSE IF @DateType = 5
		SET @SQL = @SQL + ' AND US.SessionStart>= '''+ @startDate +''' AND US.SessionStart<= '''+ @endDate +''''


	EXEC (@SQL);
END


GO
