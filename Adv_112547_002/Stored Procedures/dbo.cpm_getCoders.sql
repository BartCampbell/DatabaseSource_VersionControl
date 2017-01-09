SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--cpm_getCoders 1,25,'','',''
CREATE PROCEDURE [dbo].[cpm_getCoders] 
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4)
AS
BEGIN
	With tbl AS(
	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'UID' THEN U.Username WHEN 'FN' THEN U.Lastname+', '+U.Firstname WHEN 'CL' THEN CAST(U.CoderLevel AS Varchar) ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'UID' THEN U.Username WHEN 'FN' THEN U.Lastname+', '+U.Firstname WHEN 'CL' THEN CAST(U.CoderLevel AS Varchar) ELSE NULL END END DESC
		) AS RowNumber
			,U.User_PK,U.Username,U.Lastname+', '+U.Firstname Fullname,U.CoderLevel 
		FROM tblUser U
		WHERE U.IsReviewer = 1 And (@Alpha='' OR U.Username LIKE @Alpha+'%')
	)
	
	SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber
	
	SELECT UPPER(LEFT(Username,1)) alpha1, UPPER(RIGHT(LEFT(Username,2),1)) alpha2,Count(DISTINCT User_PK) records
		FROM tblUser WHERE IsReviewer = 1 
		GROUP BY LEFT(Username,1), RIGHT(LEFT(Username,2),1)	
		ORDER BY alpha1, alpha2
END
GO
