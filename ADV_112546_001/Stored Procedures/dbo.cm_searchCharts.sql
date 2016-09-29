SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cm_searchCharts @Member=0, @Provider=0, @Office=0, @MemberID='', @MemberName='', @MemberDOB=NULL, @ProviderID='', @ProviderName = ''
CREATE PROCEDURE [dbo].[cm_searchCharts] 
	@Member bigint,
	@Provider bigint,
	@Office bigint,
	@MemberID varchar(50),
	@MemberName varchar(50),
	@MemberDOB date,
	@ProviderID varchar(50),
	@ProviderName varchar(50)
AS
BEGIN
		SELECT TOP 500
			ROW_NUMBER() OVER(ORDER BY M.Lastname+IsNull(', '+M.Firstname,'') ASC,S.Suspect_PK ASC) AS RowNumber
			,S.Suspect_PK,S.Member_PK,S.Provider_PK,P.ProviderOffice_PK,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.DOB
			,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider			
			,PO.Address,ZC.City,ZC.State,ZC.ZipCode

			,S.ChartRec_Date
			,S.Scanned_Date
			,S.InvoiceRec_Date
			,S.InvoiceExt_Date

			,S.CNA_Date
			,S.ChartRec_InComp_Date

			,dbo.tmi_udf_GetSuspectDOSs(S.Suspect_PK) DOSs
			,IsNull(S.IsInComp_Replied,0) IsInComp_Replied
			,EQ.PDFname,EQAL.PageFrom,EQAL.PageTo,EQAL.dtInsert AttachDate,U.Lastname+IsNull(', '+U.Firstname,'') AttachedBy,EQAL.IsInvoice,EQAL.IsCNA
		FROM 
			tblSuspect S WITH (NOLOCK)
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = P.ProviderOffice_PK
			LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
			LEFT JOIN tblExtractionQueueAttachLog EQAL WITH (NOLOCK) ON EQAL.Suspect_PK = S.Suspect_PK 
			LEFT JOIN tblExtractionQueue EQ WITH (NOLOCK) ON EQ.ExtractionQueue_PK = EQAL.ExtractionQueue_PK
			LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK	= EQAL.User_PK
		WHERE (@Provider=0 OR P.Provider_PK=@Provider)
			AND (@Member=0 OR M.Member_PK = @Member)
			AND (@Office=0 OR P.ProviderOffice_PK = @Office)
			AND (@MemberID='' OR M.Member_ID LIKE '%'+@MemberID+'%')
			AND (@MemberName='' OR M.Lastname+IsNull(', '+M.Firstname,'') LIKE '%'+@MemberName+'%')
			AND (@MemberDOB IS NULL OR M.DOB = @MemberDOB)
			AND (@ProviderID='' OR PM.Provider_ID LIKE '%'+@ProviderID+'%')
			AND (@ProviderName='' OR PM.Lastname+IsNull(', '+PM.Firstname,'') LIKE '%'+@ProviderName+'%')
END
GO
