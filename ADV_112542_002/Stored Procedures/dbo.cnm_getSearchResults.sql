SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cnm_getSearchResults '0','0','0',0,'',1,'',''
Create PROCEDURE [dbo].[cnm_getSearchResults] 
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Status1 varchar(1000),
	@Status2 varchar(1000),
	@search_type int,
	@search_value varchar(1000),
	@User int,
	@Sort Varchar(150),
	@Order Varchar(4)
AS
BEGIN
	-- PROJECT/Channel SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)

	CREATE TABLE #tmpChannel (Channel_PK INT)
	CREATE INDEX idxChannelPK ON #tmpChannel (Channel_PK)

	CREATE TABLE #tmpChaseStatus (ChaseStatus_PK INT, ChaseStatusGroup_PK INT)
	CREATE INDEX idxChaseStatusPK ON #tmpChaseStatus (ChaseStatus_PK)

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
	INSERT INTO #tmpChaseStatus(ChaseStatus_PK,ChaseStatusGroup_PK) SELECT DISTINCT ChaseStatus_PK,ChaseStatusGroup_PK FROM tblChaseStatus

	IF (@Projects<>'0')
		EXEC ('DELETE FROM #tmpProject WHERE Project_PK NOT IN ('+@Projects+')')
		
	IF (@ProjectGroup<>'0')
		EXEC ('DELETE T FROM #tmpProject T INNER JOIN tblProject P ON P.Project_PK = T.Project_PK WHERE ProjectGroup_PK NOT IN ('+@ProjectGroup+')')
		
	IF (@Channel<>'0')
		EXEC ('DELETE T FROM #tmpChannel T WHERE Channel_PK NOT IN ('+@Channel+')')	
		
	IF (@Status1<>'0')
		EXEC ('DELETE T FROM #tmpChaseStatus T WHERE ChaseStatusGroup_PK NOT IN ('+@Status1+')')	
		
	IF (@Status2<>'0')
		EXEC ('DELETE T FROM #tmpChaseStatus T WHERE ChaseStatus_PK NOT IN ('+@Status2+')')						 
	-- PROJECT/Channel SELECTION

	IF (@search_type<200) --@search_type>100 AND 
	BEGIN
		-- 101 Provider Office Address</option>
		-- 102 Office Location ID</option>
		-- 103 Phone Number</option>
		-- 104 Fax Number</option>
		SELECT PO.ProviderOffice_PK,
				ROW_NUMBER() OVER(
				ORDER BY 
					CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'CLI' THEN PO.LocationID WHEN 'AL1' THEN PO.Address WHEN 'AL2' THEN ZC.City WHEN 'PN' THEN PO.ContactNumber WHEN 'FN' THEN PO.FaxNumber WHEN 'CP' THEN PO.ContactPerson WHEN 'Pr' THEN CASE WHEN COUNT(DISTINCT C.Channel_PK)=1 THEN MIN(C.Channel_Name) ELSE 'Multiple' END WHEN 'PG' THEN CASE WHEN COUNT(DISTINCT IsNUll(PM.ProviderGroup,''))=1 THEN MIN(PM.ProviderGroup) ELSE 'Multiple' END WHEN 'PLI' THEN CASE WHEN COUNT(DISTINCT IsNUll(S.PlanLID,''))=1 THEN MIN(S.PlanLID) ELSE 'Multiple' END ELSE NULL END END ASC,
					CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'CLI' THEN PO.LocationID WHEN 'AL1' THEN PO.Address WHEN 'AL2' THEN ZC.City WHEN 'PN' THEN PO.ContactNumber WHEN 'FN' THEN PO.FaxNumber WHEN 'CP' THEN PO.ContactPerson WHEN 'Pr' THEN CASE WHEN COUNT(DISTINCT C.Channel_PK)=1 THEN MIN(C.Channel_Name) ELSE 'Multiple' END WHEN 'PG' THEN CASE WHEN COUNT(DISTINCT IsNUll(PM.ProviderGroup,''))=1 THEN MIN(PM.ProviderGroup) ELSE 'Multiple' END WHEN 'PLI' THEN CASE WHEN COUNT(DISTINCT IsNUll(S.PlanLID,''))=1 THEN MIN(S.PlanLID) ELSE 'Multiple' END ELSE NULL END END DESC,
					CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'C' THEN Count(DISTINCT S.Suspect_PK) WHEN 'P' THEN Count(DISTINCT S.Provider_PK) ELSE NULL END END ASC,
					CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'C' THEN Count(DISTINCT S.Suspect_PK) WHEN 'P' THEN Count(DISTINCT S.Provider_PK) ELSE NULL END END DESC 
				) AS RowNumber
				,CASE WHEN COUNT(DISTINCT IsNull(S.PlanLID,''))=1 THEN MIN(S.PlanLID) ELSE 'Multiple' END [Plan Location ID]
				,PO.LocationID [Centauri Location ID],PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,PO.ContactNumber,PO.FaxNumber,PO.ContactPerson
				,Count(DISTINCT S.Provider_PK) Providers
				,Count(DISTINCT S.Suspect_PK) Charts
				,CASE WHEN COUNT(DISTINCT IsNull(PM.ProviderGroup,''))=1 THEN MIN(PM.ProviderGroup) ELSE 'Multiple' END [Provider Group]
				,CASE WHEN COUNT(DISTINCT C.Channel_PK)=1 THEN MIN(C.Channel_Name) ELSE 'Multiple' END Project
			FROM tblProviderOffice PO WITH (NOLOCK) 
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON P.ProviderMaster_PK = PM.ProviderMaster_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
				INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
				INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
				INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
				LEFT JOIN tblChannel C WITH (NOLOCK) ON C.Channel_PK = S.Channel_PK
			--WHERE Address Like '%'+@search_value+'%'
		WHERE @search_type=0 OR
			(@search_type=101 AND PO.Address Like '%'+@search_value+'%') OR
			(@search_type=102 AND PO.LocationID Like '%'+@search_value+'%') OR
			(@search_type=103 AND PO.ContactNumber Like '%'+@search_value+'%') OR
			(@search_type=104 AND PO.FaxNumber Like '%'+@search_value+'%') OR
			(@search_type=105 AND S.PlanLID Like '%'+@search_value+'%')
		GROUP BY PO.ProviderOffice_PK,PO.LocationID,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,PO.ContactNumber,PO.FaxNumber,PO.ContactPerson
	END
	ELSE IF (@search_type>200 AND @search_type<300)
	BEGIN
        --201	Provider Group
        --202	Provider ID
        --203	Provider NPI
        --204	Provider Name
		SELECT	P.ProviderMaster_PK,
				ROW_NUMBER() OVER(
				ORDER BY 
					CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'CPI' THEN PM.Provider_ID WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'NPI' THEN PM.NPI WHEN 'A' THEN PO.Address WHEN 'PG' THEN PM.ProviderGroup WHEN 'Pr' THEN CASE WHEN COUNT(DISTINCT C.Channel_PK)=1 THEN MIN(C.Channel_Name) ELSE 'Multiple' END ELSE NULL END END ASC,
					CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'CPI' THEN PM.Provider_ID WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'NPI' THEN PM.NPI WHEN 'A' THEN PO.Address WHEN 'PG' THEN PM.ProviderGroup WHEN 'Pr' THEN CASE WHEN COUNT(DISTINCT C.Channel_PK)=1 THEN MIN(C.Channel_Name) ELSE 'Multiple' END ELSE NULL END END DESC,
					CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'C' THEN Count(DISTINCT S.Suspect_PK) ELSE NULL END END ASC,
					CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'C' THEN Count(DISTINCT S.Suspect_PK) ELSE NULL END END DESC 
				) AS RowNumber
				,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,PM.NPI,PM.PIN [Plan Provider ID]
				,CASE WHEN COUNT(DISTINCT IsNull(S.PlanLID,''))=1 THEN MIN(S.PlanLID) ELSE 'Multiple' END [Plan Location ID]
				,S.Provider_PK,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,PM.ProviderGroup
				,Count(DISTINCT S.Suspect_PK) Charts,PM.Lastname,PM.Firstname
				,CASE WHEN COUNT(DISTINCT C.Channel_PK)=1 THEN MIN(C.Channel_Name) ELSE 'Multiple' END Project
			FROM tblProviderOffice PO WITH (NOLOCK) 
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
				INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
				INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
				INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
				LEFT JOIN tblChannel C WITH (NOLOCK) ON C.Channel_PK = S.Channel_PK
		WHERE 
			(@search_type=201 AND PM.ProviderGroup Like '%'+@search_value+'%') OR
			(@search_type=202 AND PM.Provider_ID Like '%'+@search_value+'%') OR
			(@search_type=203 AND PM.NPI Like '%'+@search_value+'%') OR
			(@search_type=204 AND PM.Lastname+IsNull(', '+PM.Firstname,'') Like '%'+@search_value+'%') OR
			(@search_type=205 AND PM.PIN Like '%'+@search_value+'%')
		GROUP BY PM.Provider_ID,PM.Lastname,PM.Firstname,PM.NPI,PM.PIN
				,S.Provider_PK,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,PM.ProviderGroup,P.ProviderMaster_PK
	END
	ELSE IF (@search_type>300 AND @search_type<400)
	BEGIN
		--301	Member ID
		--302	Member Name
		--303	HIC NUmber
		--304	Chase ID
		SELECT	S.Suspect_PK,				
				ROW_NUMBER() OVER(
				ORDER BY 
					CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'MID' THEN M.Member_ID WHEN 'HN' THEN M.HICNumber WHEN 'M' THEN M.Lastname+IsNull(', '+M.Firstname,'') WHEN 'CPI' THEN PM.Provider_ID WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'NPI' THEN PM.NPI WHEN 'A' THEN PO.Address WHEN 'PG' THEN PM.ProviderGroup WHEN 'CS' THEN CS.ChaseStatus WHEN 'CRC' THEN CS.ChartResolutionCode WHEN 'LOB' THEN Pr.Project_Name WHEN 'Pr' THEN C.Channel_Name ELSE NULL END END ASC,
					CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'MID' THEN M.Member_ID WHEN 'HN' THEN M.HICNumber WHEN 'M' THEN M.Lastname+IsNull(', '+M.Firstname,'') WHEN 'CPI' THEN PM.Provider_ID WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'NPI' THEN PM.NPI WHEN 'A' THEN PO.Address WHEN 'PG' THEN PM.ProviderGroup WHEN 'CS' THEN CS.ChaseStatus WHEN 'CRC' THEN CS.ChartResolutionCode WHEN 'LOB' THEN Pr.Project_Name WHEN 'Pr' THEN C.Channel_Name ELSE NULL END END DESC,
					CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'DOB' THEN M.DOB WHEN 'EX' THEN S.Scanned_Date WHEN 'CD' THEN S.Coded_Date ELSE NULL END END ASC,
					CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'DOB' THEN M.DOB WHEN 'EX' THEN S.Scanned_Date WHEN 'CD' THEN S.Coded_Date ELSE NULL END END DESC 
				) AS RowNumber
				,S.ChaseID,M.Member_ID,M.HICNumber,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.DOB,S.Scanned_Date Extracted,S.Coded_Date Coded
				,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,PM.NPI,PM.PIN [Plan Provider ID],PM.ProviderGroup [Provider Group]
				,S.PlanLID [Plan Location ID]
				,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,CS.ChaseStatus [Chase Status],CS.ChartResolutionCode [Chase Resolution Code]
				,Pr.Project_Name LOB,C.Channel_Name Project
			FROM tblProviderOffice PO WITH (NOLOCK) 
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
				INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
				INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
				INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
				INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
				INNER JOIN tblProject Pr ON Pr.Project_PK = S.Project_PK
				LEFT JOIN tblChaseStatus CS WITH (NOLOCK) ON CS.ChaseStatus_PK = S.ChaseStatus_PK
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK		
				LEFT JOIN tblChannel C WITH (NOLOCK) ON C.Channel_PK = S.Channel_PK
		WHERE 
			(@search_type=301 AND M.Member_ID Like '%'+@search_value+'%') OR
			(@search_type=302 AND M.Lastname+IsNull(', '+M.Firstname,'') Like '%'+@search_value+'%') OR
			(@search_type=303 AND M.HICNumber Like '%'+@search_value+'%') OR
			(@search_type=304 AND S.ChaseID Like '%'+@search_value+'%')

	END
END
GO
