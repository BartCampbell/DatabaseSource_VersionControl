SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- um_getUsers 1,25,'','UN','DESC'
CREATE PROCEDURE [dbo].[um_getUsers] 
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4),
	@filter int
AS
BEGIN
	With tbl AS(
	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'UN' THEN Username WHEN 'NAME' THEN Lastname+', '+Firstname WHEN 'EMAIL' THEN Email_Address ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'UN' THEN Username WHEN 'NAME' THEN Lastname+', '+Firstname WHEN 'EMAIL' THEN Email_Address ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'AC' THEN IsActive WHEN 'C' THEN IsClient WHEN 'A' THEN IsAdmin WHEN 'ST' THEN IsScanTech WHEN 'S' THEN IsScheduler WHEN 'R' THEN IsCoderOffsite WHEN 'QA' THEN IsQACoder WHEN 'HRA' THEN IsHRA ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'AC' THEN IsActive WHEN 'C' THEN IsClient WHEN 'A' THEN IsAdmin WHEN 'ST' THEN IsScanTech WHEN 'S' THEN IsScheduler WHEN 'R' THEN IsCoderOffsite WHEN 'QA' THEN IsQACoder WHEN 'HRA' THEN IsHRA ELSE NULL END END DESC
		) AS RowNumber
			,User_PK,IsActive,Username,Lastname+', '+Firstname Fullname,Email_Address,IsClient,IsAdmin,IsScanTech,IsScheduler,IsCoderOffsite,IsQACoder,IsHRA 
			,only_work_selected_hours, only_work_selected_zipcodes
			,linked_provider_id,IsNull(linked_provider_pk,0) linked_provider_pk
			,sch_name,sch_tel,sch_fax
			,isScanTechSV, isSchedulerSV,IsChangePasswordOnFirstLogin,IsNull(Location_PK,0) Location_PK, isQCC, isAllowDownload, IsSchedulerManager
			,IsInvoiceAccountant, IsBillingAccountant, IsQAManager, IsCoderOnsite,IsCodingManager
		FROM tblUser
		WHERE Username Like @Alpha+'%'
		AND (
			(@filter=0 AND IsActive=0)
			OR
			(@filter=1 AND IsActive=1)
			OR
			(@filter=2)
			)
	)
	
	SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber
	
	SELECT UPPER(LEFT(Username,1)) alpha1, UPPER(RIGHT(LEFT(Username,2),1)) alpha2,Count(DISTINCT User_PK) records
		FROM tblUser
		WHERE (
			(@filter=0 AND IsActive=0)
			OR
			(@filter=1 AND IsActive=1)
			OR
			(@filter=2)
			)
		GROUP BY LEFT(Username,1), RIGHT(LEFT(Username,2),1)			
		ORDER BY alpha1, alpha2
END    
GO
