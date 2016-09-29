SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	im_getOfficeCharts 1,1
CREATE PROCEDURE [dbo].[im_getOfficeCharts] 
	@Office int,
	@invoice int
AS
BEGIN
	CREATE Table #Suspect (Suspect_PK BigInt, IsInvoiced bit,PaidOnOtherInvoice INT)
	CREATE INDEX idxSuspectPK ON #Suspect (Suspect_PK)
	INSERT INTO #Suspect SELECT Suspect_PK,1,0 FROM tblProviderOfficeInvoiceSuspect WHERE ProviderOfficeInvoice_PK = @invoice

	INSERT INTO #Suspect 
	SELECT S.Suspect_PK,0,0
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			LEFT JOIN tblProviderOfficeInvoiceSuspect POIS ON POIS.ProviderOfficeInvoice_PK = @invoice AND POIS.Suspect_PK = S.Suspect_PK
		WHERE P.ProviderOffice_PK=@Office AND POIS.ProviderOfficeInvoice_PK IS NULL

	UPDATE S SET PaidOnOtherInvoice = POI.ProviderOfficeInvoice_PK
		FROM tblProviderOfficeInvoice POI WITH (NOLOCK) 
			INNER JOIN tblProviderOfficeInvoiceSuspect POIS WITH (NOLOCK) ON POIS.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK
			INNER JOIN #Suspect S ON S.Suspect_PK = POIS.Suspect_PK
		WHERE POI.ProviderOfficeInvoice_PK<>@invoice AND POI.ProviderOfficeInvoiceBucket_PK>2 --Excluding Pending and Rejected Invoices

	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			tS.IsInvoiced DESC,M.Lastname+IsNull(', '+M.Firstname,'')
		) AS RowNumber
			,S.Suspect_PK,S.ChaseID,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.DOB
			,S.IsScanned Scanned,Scanned_Date
			,S.IsCNA CNA,CNA_Date
			,S.IsCoded Coded,Coded_Date
			,S.Project_PK,P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider
			,tS.IsInvoiced,tS.PaidOnOtherInvoice
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN #Suspect tS ON tS.Suspect_PK = S.Suspect_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
		ORDER BY RowNumber
END
GO
