SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	oil_getOffice '0','0','0',1,25,'','FU','DESC',0,0,1,301,'458194431'
CREATE PROCEDURE [dbo].[oil_getOffice]
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Page int,
	@PageSize int,
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4),
	@filter_type int,
	@filter_type_sub int,
	@user int,
	@search_type int,
	@search_value varchar(1000)
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

	IF (@Projects<>'0')
		EXEC ('DELETE FROM #tmpProject WHERE Project_PK NOT IN ('+@Projects+')')
		
	IF (@ProjectGroup<>'0')
		EXEC ('DELETE T FROM #tmpProject T INNER JOIN tblProject P ON P.Project_PK = T.Project_PK WHERE ProjectGroup_PK NOT IN ('+@ProjectGroup+')')
		
	IF (@Channel<>'0')
		EXEC ('DELETE T FROM #tmpChannel T WHERE Channel_PK NOT IN ('+@Channel+')')			 
	-- PROJECT/Channel SELECTION
		
	DECLARE @OFFICE AS BIGINT
	DECLARE @Provider AS INT = 0
	if (@Provider=0)
		SET @OFFICE = 0;
	else
		SELECT @OFFICE = ProviderOffice_PK FROM tblProvider WITH (NOLOCK) WHERE Provider_PK=@Provider;

	IF (@Page<>0)
	BEGIN
		--With tbl AS(
		SELECT ROW_NUMBER() OVER(
			ORDER BY 
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'AD' THEN PO.Address WHEN 'CT' THEN ZC.City WHEN 'CN' THEN ZC.County WHEN 'ST' THEN ZC.State WHEN 'ZC' THEN ZC.Zipcode WHEN 'CP' THEN PO.ContactPerson WHEN 'CNU' THEN PO.ContactNumber WHEN 'FN' THEN PO.FaxNumber ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'AD' THEN PO.Address WHEN 'CT' THEN ZC.City WHEN 'CN' THEN ZC.County WHEN 'ST' THEN ZC.State WHEN 'ZC' THEN ZC.Zipcode WHEN 'CP' THEN PO.ContactPerson WHEN 'CNU' THEN PO.ContactNumber WHEN 'FN' THEN PO.FaxNumber ELSE NULL END END DESC,
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'CH' THEN COUNT(DISTINCT CASE WHEN S.IsCNA=0 AND S.IsScanned=0 THEN S.Suspect_PK ELSE NULL END) WHEN 'IS' THEN MIN(POS.OfficeIssueStatus) WHEN 'PRV' THEN COUNT(DISTINCT S.Provider_PK) END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'CH' THEN COUNT(DISTINCT CASE WHEN S.IsCNA=0 AND S.IsScanned=0 THEN S.Suspect_PK ELSE NULL END) WHEN 'IS' THEN MIN(POS.OfficeIssueStatus) WHEN 'PRV' THEN COUNT(DISTINCT S.Provider_PK) END END DESC
			) AS RowNumber
				,MAX(S.Project_PK) Project_PK,PO.ProviderOffice_PK,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode,PO.ContactPerson,PO.ContactNumber,PO.FaxNumber,PO.Email_Address,Isnull(PO.EMR_Type_PK,0) EMR_Type_PK
				,COUNT(DISTINCT S.Provider_PK) Providers
				,COUNT(DISTINCT CASE WHEN S.IsCNA=0 AND S.IsScanned=0 THEN S.Suspect_PK ELSE NULL END) Charts
				,MIN(PO.ProviderOfficeBucket_PK) OfficeStatus
				,MIN(POS.OfficeIssueStatus) OfficeIssueStatus
			INTO #tbl
			FROM tblProviderOffice PO WITH (NOLOCK) 
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
				INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
				INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
				INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
				LEFT JOIN tblProviderOfficeStatus POS ON POS.ProviderOffice_PK = PO.ProviderOffice_PK
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
			WHERE IsNull(PO.Address,0) Like @Alpha+'%'
				AND (@filter_type=0 OR POS.OfficeIssueStatus=@filter_type)
				AND (@search_type>0 OR POS.ProviderOffice_PK IS NOT NULL)
				AND (@search_type=0 OR
					(@search_type=101 AND PO.Address Like '%'+@search_value+'%') OR
					(@search_type=102 AND PO.LocationID Like '%'+@search_value+'%') OR
					(@search_type=103 AND PO.ContactNumber Like '%'+@search_value+'%') OR
					(@search_type=104 AND PO.FaxNumber Like '%'+@search_value+'%') OR
					(@search_type=201 AND PM.ProviderGroup Like '%'+@search_value+'%') OR
					(@search_type=202 AND PM.Provider_ID Like '%'+@search_value+'%') OR
					(@search_type=203 AND PM.NPI Like '%'+@search_value+'%') OR
					(@search_type=204 AND PM.Lastname+IsNull(' '+PM.Firstname,'') Like '%'+@search_value+'%') OR
					(@search_type=205 AND PM.PIN Like '%'+@search_value+'%') OR
					(@search_type=301 AND M.Member_ID Like '%'+@search_value+'%') OR
					(@search_type=302 AND M.Lastname+IsNull(' '+M.Firstname,'') Like '%'+@search_value+'%') OR
					(@search_type=303 AND M.HICNumber Like '%'+@search_value+'%') OR
					(@search_type=304 AND S.ChaseID Like '%'+@search_value+'%')
				)
			GROUP BY PO.ProviderOffice_PK,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode,PO.ContactPerson,PO.ContactNumber,PO.FaxNumber,PO.Email_Address,Isnull(PO.EMR_Type_PK,0)
			HAVING @filter_type=0 OR COUNT(DISTINCT CASE WHEN S.IsCNA=0 AND S.IsScanned=0 THEN S.Suspect_PK ELSE NULL END)>0 OR @search_type>0
		--)
	
		SELECT * FROM #tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber
	
		SELECT UPPER(LEFT(PO.Address,1)) alpha1, UPPER(RIGHT(LEFT(PO.Address,2),1)) alpha2,Count(DISTINCT PO.ProviderOffice_PK) records
			FROM #tbl PO
			GROUP BY LEFT(PO.Address,1), RIGHT(LEFT(PO.Address,2),1)			
			ORDER BY alpha1, alpha2;
	END
	ELSE
	BEGIN
			SELECT DISTINCT ProviderOffice_PK,OfficeIssueStatus, X.ContactNotesOffice_PK,X.ContactNote_Text [Issue Note],X.ContactNoteText [Issue Additional Info],IssueDate INTO #tmp
			FROM tblProviderOfficeStatus POS WITH (NOLOCK)
				Outer Apply (
					SELECT TOP 1 CNO.ContactNotesOffice_PK,CNO.ContactNote_PK,CN.ContactNote_Text,CNO.ContactNoteText,CNO.LastUpdated_Date IssueDate
					FROM tblContactNotesOffice CNO WITH (NOLOCK) 
					INNER JOIN tblContactNote CN WITH (NOLOCK) ON CN.ContactNote_PK = CNO.ContactNote_PK AND CNO.Office_PK = POS.ProviderOffice_PK
					WHERE (CN.IsIssue=1 OR CN.IsDataIssue=1) 
					ORDER BY CNO.LastUpdated_Date DESC
				) X
			CREATE INDEX idxProviderOffice_PK ON #tmp (ProviderOffice_PK)
			CREATE INDEX idxContactNotesOffice_PK ON #tmp (ContactNotesOffice_PK)

			SELECT DISTINCT PO.LocationID,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,PO.ContactPerson,PO.ContactNumber,PO.FaxNumber
				,OIST.OfficeIssueStatusText
				,S.ChaseID
				,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider
				,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member
				,[Issue Note], [Issue Additional Info],IssueDate, IRT.IssueResponse+': '+IRO.AdditionalResponse IssueResponse, IRO.dtInsert ReponseDate
			FROM tblProviderOffice PO WITH (NOLOCK) 
				INNER JOIN tblProviderOfficeBucket POB WITH (NOLOCK) ON POB.ProviderOfficeBucket_PK = PO.ProviderOfficeBucket_PK
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
				INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
				INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
				INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
				INNER JOIN #tmp POS WITH (NOLOCK) ON POS.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblOfficeIssueStatusText OIST WITH (NOLOCK) ON OIST.OfficeIssueStatus_PK = POS.OfficeIssueStatus
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
				LEFT JOIN tblIssueResponseOffice IRO WITH (NOLOCK) ON IRO.ContactNotesOffice_PK = POS.ContactNotesOffice_PK
				LEFT JOIN tblIssueResponse IRT WITH (NOLOCK) ON IRT.IssueResponse_PK = IRO.IssueResponse_PK
			WHERE IsNull(PO.Address,0) Like @Alpha+'%'
				AND (@OFFICE=0 OR PO.ProviderOffice_PK=@OFFICE)
				AND (@OFFICE<>0 OR POS.OfficeIssueStatus IS NOT NULL)
				AND (@OFFICE<>0 OR (@filter_type=0 OR POS.OfficeIssueStatus=@filter_type))
	END
END
GO
