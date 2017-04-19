SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cm_searchCharts @Member=0, @Provider=0, @Office=0, @MemberID='', @ChaseID='', @MemberName='', @MemberDOB=NULL, @ProviderID='', @ProviderName = ''
CREATE PROCEDURE [dbo].[cm_searchCharts] 
	@Member bigint,
	@Provider bigint,
	@Office bigint,
	@ChaseID varchar(50),
	@MemberID varchar(50),
	@MemberName varchar(50),
	@MemberDOB date,
	@ProviderID varchar(50),
	@ProviderName varchar(50),
	@user int
AS
BEGIN
	-- PROJECT/Channel SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)

	CREATE TABLE #tmpChannel (Channel_PK INT)
	CREATE INDEX idxChannelPK ON #tmpChannel (Channel_PK)

	IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
	BEGIN
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblChannel 
	END
	ELSE
	BEGIN
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblUserProject WHERE User_PK=@User
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblUserChannel WHERE User_PK=@User
	END		 
	-- PROJECT/Channel SELECTION

	SELECT TOP 500
		ROW_NUMBER() OVER(ORDER BY M.Lastname+IsNull(', '+M.Firstname,'') ASC,S.Suspect_PK ASC) AS RowNumber
		,S.Suspect_PK,S.Member_PK,S.Provider_PK,P.ProviderOffice_PK,S.ChaseID,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.DOB
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
		,EQ.PDFname,EQAL.PageFrom,EQAL.PageTo,EQAL.dtInsert AttachDate,U.Lastname+IsNull(', '+U.Firstname,'') AttachedBy,EQAL.IsInvoice,EQAL.IsCNA,S.LinkedSuspect_PK
	FROM 
		tblSuspect S WITH (NOLOCK)
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
		INNER JOIN tblProvider P WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
		INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = P.ProviderOffice_PK
		LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
		LEFT JOIN tblExtractionQueueAttachLog EQAL WITH (NOLOCK) ON EQAL.Suspect_PK = S.Suspect_PK OR EQAL.Suspect_PK = S.LinkedSuspect_PK
		LEFT JOIN tblExtractionQueue EQ WITH (NOLOCK) ON EQ.ExtractionQueue_PK = EQAL.ExtractionQueue_PK
		LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK	= EQAL.User_PK
	WHERE (@Provider=0 OR P.Provider_PK=@Provider)
		AND (@Member=0 OR M.Member_PK = @Member)
		AND (@Office=0 OR P.ProviderOffice_PK = @Office)
		AND (@ChaseID='' OR S.ChaseID LIKE '%'+@ChaseID+'%')
		AND (@MemberID='' OR M.Member_ID LIKE '%'+@MemberID+'%')
		AND (@MemberName='' OR M.Lastname+IsNull(', '+M.Firstname,'') LIKE '%'+@MemberName+'%')
		AND (@MemberDOB IS NULL OR M.DOB = @MemberDOB)
		AND (@ProviderID='' OR PM.Provider_ID LIKE '%'+@ProviderID+'%')
		AND (@ProviderName='' OR PM.Lastname+IsNull(', '+PM.Firstname,'') LIKE '%'+@ProviderName+'%')
END
GO
