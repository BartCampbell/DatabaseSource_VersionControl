SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	ir_getCharts 0,1,225,'','AD','DESC',0,0,5,1,0,''
Create PROCEDURE [dbo].[ir_getCharts] 
	@Project int,
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4),
	@Office int,
	@Provider int,
	@filter_type int,
	@user int,
	@mid bigint,
	@inv_number as varchar(20)
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	IF @Project=0
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@user)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT Project_PK FROM tblProject P WHERE P.IsRetrospective=1
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@user
	END
	ELSE
		INSERT INTO #tmpProject(Project_PK) VALUES(@Project)		
	-- PROJECT SELECTION
;
	With tbl AS(
	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'M' THEN M.Lastname+IsNull(', '+M.Firstname,'') WHEN 'MID' THEN M.Member_ID WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'PID' THEN PM.Provider_ID WHEN 'INU' THEN SII.InvoiceNumber WHEN 'IAN' THEN SII.AccountNumber WHEN 'IAM' THEN SII.InvoiceAmount WHEN 'IV' THEN IsNull(IV.InvoiceVendor,'OTHERS') ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'M' THEN M.Lastname+IsNull(', '+M.Firstname,'') WHEN 'MID' THEN M.Member_ID WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'PID' THEN PM.Provider_ID WHEN 'INU' THEN SII.InvoiceNumber WHEN 'IAN' THEN SII.AccountNumber WHEN 'IAM' THEN SII.InvoiceAmount WHEN 'IV' THEN IsNull(IV.InvoiceVendor,'OTHERS') ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'IA' THEN (CASE WHEN SII.IsApproved=1 THEN 1 ELSE 0 END) WHEN 'IR' THEN (CASE WHEN SII.IsApproved=0 THEN 1 ELSE 0 END) WHEN 'IP' THEN (CASE WHEN SII.IsApproved IS NULL THEN 1 ELSE 0 END) ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'IA' THEN (CASE WHEN SII.IsApproved=1 THEN 1 ELSE 0 END) WHEN 'IR' THEN (CASE WHEN SII.IsApproved=0 THEN 1 ELSE 0 END) WHEN 'IP' THEN (CASE WHEN SII.IsApproved IS NULL THEN 1 ELSE 0 END) ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'DOB' THEN M.DOB ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'DOB' THEN M.DOB ELSE NULL END END DESC
		) AS RowNumber
			,S.Suspect_PK,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.DOB
			,(CASE WHEN SII.IsApproved=1 THEN 1 ELSE 0 END) Approved
			,(CASE WHEN SII.IsApproved=0 THEN 1 ELSE 0 END) Rejected
			,(CASE WHEN SII.IsApproved IS NULL THEN 1 ELSE 0 END) Pending
			,SII.InvoiceNumber,SII.AccountNumber,SII.InvoiceAmount,IsNull(IV.InvoiceVendor,'OTHERS') InvoiceVendor
			,S.Project_PK,P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider			
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
			INNER JOIN tblSuspectInvoiceInfo SII WITH (NOLOCK) ON SII.Suspect_PK = S.Suspect_PK			
			LEFT JOIN tblInvoiceVendor IV WITH (NOLOCK) ON IV.InvoiceVendor_PK = SII.InvoiceVendor_PK
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND (@Provider=0 OR P.Provider_PK=@Provider)
			AND (@mid=0 OR S.Member_PK=@mid)
			AND IsNull(M.Lastname+IsNull(', '+M.Firstname,''),0) Like @Alpha+'%'
			AND (@filter_type=4 OR IsNull(CAST(SII.IsApproved AS INT),2) = @filter_type)
			AND (@inv_number='' OR SII.InvoiceNumber Like @inv_number+'%')
	)
				
	SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber;

	SELECT UPPER(LEFT(M.Lastname+IsNull(', '+M.Firstname,''),1)) alpha1, UPPER(RIGHT(LEFT(M.Lastname+IsNull(', '+M.Firstname,''),2),1)) alpha2,Count(DISTINCT S.Suspect_PK) records
		FROM tblProvider P WITH (NOLOCK) 
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK 
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
			INNER JOIN tblSuspectInvoiceInfo SII WITH (NOLOCK) ON SII.Suspect_PK = S.Suspect_PK
						
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
		AND (@Provider=0 OR P.Provider_PK=@Provider)
		AND (@mid=0 OR S.Member_PK=@mid)
		AND (@filter_type=4 OR IsNull(CAST(SII.IsApproved AS INT),2) = @filter_type)
		AND (@inv_number='' OR SII.InvoiceNumber Like @inv_number+'%')
		GROUP BY LEFT(M.Lastname+IsNull(', '+M.Firstname,''),1), RIGHT(LEFT(M.Lastname+IsNull(', '+M.Firstname,''),2),1)			
		ORDER BY alpha1, alpha2;
			
	--Total
	SELECT 
			SUM(CASE WHEN SII.IsApproved=1 THEN 1 ELSE 0 END) Approved
			,SUM(CASE WHEN SII.IsApproved=0 THEN 1 ELSE 0 END) Rejected
			,SUM(CASE WHEN SII.IsApproved IS NULL THEN 1 ELSE 0 END) Pending
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK	
			INNER JOIN tblSuspectInvoiceInfo SII WITH (NOLOCK) ON SII.Suspect_PK = S.Suspect_PK
						
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND (@Provider=0 OR P.Provider_PK=@Provider)
			AND (@mid=0 OR S.Member_PK=@mid)
			AND (@filter_type=4 OR IsNull(CAST(SII.IsApproved AS INT),2) = @filter_type)
			AND (@inv_number='' OR SII.InvoiceNumber Like @inv_number+'%')
END
GO
