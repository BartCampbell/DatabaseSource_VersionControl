SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Alter date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- um_getUsers 1,25,'','UN','DESC'
CREATE PROCEDURE [dbo].[um_getUsers] 
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
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'UN' THEN Username WHEN 'NAME' THEN Lastname+', '+Firstname WHEN 'EMAIL' THEN Email_Address ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'UN' THEN Username WHEN 'NAME' THEN Lastname+', '+Firstname WHEN 'EMAIL' THEN Email_Address ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'AC' THEN IsActive WHEN 'C' THEN IsCoder WHEN 'A' THEN IsAdmin WHEN 'CS' THEN isCoderSupervisor WHEN 'CM' THEN IsClient WHEN 'MG' THEN IsManager ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'AC' THEN IsActive WHEN 'C' THEN IsCoder WHEN 'A' THEN IsAdmin WHEN 'CS' THEN isCoderSupervisor WHEN 'CM' THEN IsClient WHEN 'MG' THEN IsManager ELSE NULL END END DESC
		) AS RowNumber
			,User_PK,IsActive,Username,Lastname+', '+Firstname Fullname,Email_Address,IsAdmin,IsCoder,isCoderSupervisor,IsClient,IsManager
		FROM tblUser WITH (NOLOCK)
		WHERE Lastname+', '+Firstname Like @Alpha+'%' AND Username<>''
	)
	
	SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber
	
	SELECT UPPER(LEFT(Lastname,1)) alpha1, UPPER(RIGHT(LEFT(Lastname,2),1)) alpha2,Count(DISTINCT User_PK) records
		FROM tblUser WITH (NOLOCK)
		GROUP BY LEFT(Lastname,1), RIGHT(LEFT(Lastname,2),1)			
		ORDER BY alpha1, alpha2
END



GO
