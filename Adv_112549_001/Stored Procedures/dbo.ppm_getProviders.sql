SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--ppm_getProviders 1,25,'','',''
CREATE PROCEDURE [dbo].[ppm_getProviders] 
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4),
	@Type tinyint
AS
BEGIN
	With tbl AS(
	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'PID' THEN U.linked_provider_id WHEN 'PN' THEN U.Lastname+', '+U.Firstname WHEN 'EM' THEN U.Email_Address WHEN 'SCH' THEN ISNULL(S.Lastname+', '+S.Firstname,'') ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'PID' THEN U.linked_provider_id WHEN 'PN' THEN U.Lastname+', '+U.Firstname WHEN 'EM' THEN U.Email_Address WHEN 'SCH' THEN ISNULL(S.Lastname+', '+S.Firstname,'') ELSE NULL END END DESC
		) AS RowNumber
			,U.User_PK,U.linked_provider_id,U.Lastname+', '+U.Firstname Provider,U.Email_Address 
			,U.only_work_selected_hours, U.only_work_selected_zipcodes
			,IsNull(U.linked_provider_pk,0) linked_provider_pk
			,ISNULL(S.Lastname+', '+S.Firstname,'') Scheduler,IsNull(U.linked_scheduler_user_pk,0) linked_scheduler_user_pk,U.is_male
			,U.address,u.zipcode_pk,u.willing2travell
		FROM tblUser U LEFT JOIN tblUser S ON S.User_PK = U.linked_scheduler_user_pk
		WHERE ((@Type=1 AND U.IsHRA=1) OR (@Type=2 AND U.IsQCC=1)) AND U.Lastname Like @Alpha+'%'
	)
	
	SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber
	
	SELECT UPPER(LEFT(Lastname,1)) alpha1, UPPER(RIGHT(LEFT(Lastname,2),1)) alpha2,Count(DISTINCT User_PK) records
		FROM tblUser WHERE ((@Type=1 AND IsHRA=1) OR (@Type=2 AND IsQCC=1))
		GROUP BY LEFT(Lastname,1), RIGHT(LEFT(Lastname,2),1)	
		ORDER BY alpha1, alpha2
END
GO
