SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	rca_searchCharts @search_type=101, @search_value='', @user=1, @level=1, @all=1,@search_filter=0,@Sort='M',@Order='ASC'
CREATE PROCEDURE [dbo].[rca_searchCharts] 
	@search_type int,
	@search_value varchar(1000),
	@user int,
	@level int,
	@all int,
	@search_filter int,
	@Sort Varchar(150),
	@Order Varchar(4)
AS
BEGIN
	DECLARE @chases AS INT
	SET @chases = CASE WHEN @all=0 THEN 10 ELSE 10000 END
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
	;
	WITH tbl AS (
	SELECT 
		ROW_NUMBER() OVER(
		ORDER BY 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'C' THEN S.ChaseID WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'A' THEN PO.Address WHEN 'M' THEN M.Lastname+IsNull(', '+M.Firstname,'') WHEN 'CS' THEN CS.CompletionStatus WHEN 'U' THEN U.Lastname+IsNULL(', '+U.Firstname,'') ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'C' THEN S.ChaseID WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'A' THEN PO.Address WHEN 'M' THEN M.Lastname+IsNull(', '+M.Firstname,'') WHEN 'CS' THEN CS.CompletionStatus WHEN 'U' THEN U.Lastname+IsNULL(', '+U.Firstname,'') ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'S' THEN CAST(S.IsScanned AS INT) ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'S' THEN CAST(S.IsScanned AS INT) ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'AD' THEN CA.LastUpdated_Date ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'AD' THEN CA.LastUpdated_Date ELSE NULL END END DESC, 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'M' THEN PO.Address ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'M' THEN PO.Address ELSE NULL END END DESC 		 
		) AS RowNumber,
		S.Suspect_PK,S.Member_PK,S.Provider_PK,PM.ProviderMaster_PK,P.ProviderOffice_PK,S.ChaseID,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.DOB
		,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider			
		,PO.Address,ZC.City,ZC.State,ZC.ZipCode

		,CAST(S.IsScanned AS INT) IsScanned
		,CAST(S.IsCoded AS INT) IsCoded
		,CS.CompletionStatus [Coded Status],CS.CompletionStatus_PK
		,U.Lastname+IsNULL(', '+U.Firstname,'') Assignment
		,CA.LastUpdated_Date AssignedDate
	FROM 
		tblSuspect S WITH (NOLOCK)
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
		INNER JOIN tblProvider P WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
		INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = P.ProviderOffice_PK
		LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
		LEFT JOIN tblCoderAssignment CA WITH (NOLOCK) ON CA.Suspect_PK = S.Suspect_PK AND CA.CoderLevel = @level
		LEFT JOIN tblUser U ON U.User_PK = CA.User_PK
		LEFT JOIN tblSuspectLevelCoded SLC WITH (NOLOCK) ON SLC.CoderLevel = @level AND SLC.Suspect_PK = S.Suspect_PK
		LEFT JOIN tblCompletionStatus CS WITH (NOLOCK) ON SLC.CompletionStatus_PK = CS.CompletionStatus_PK
	WHERE (
			@search_filter=0 OR 
			(@search_filter=101 AND IsNull(SLC.IsCompleted,0)=0 AND S.IsScanned=1) OR
			(@search_filter=102 AND IsNull(SLC.IsCompleted,0)=0) OR
			(@search_filter=103 AND S.IsScanned=1) OR
			(@search_filter=104 AND S.IsScanned=0) OR
			(@search_filter=105 AND SLC.IsCompleted=0 AND S.IsScanned=1) OR
			(SLC.CompletionStatus_PK=@search_filter AND S.IsScanned=1)
		) 
		AND
			(
			@search_type=0 OR
			--Office
			(@search_type=1 AND CAST(PO.ProviderOffice_PK AS VARCHAR)=@search_value) OR
			(@search_type=101 AND PO.Address Like '%'+@search_value+'%') OR
			(@search_type=102 AND PO.LocationID Like '%'+@search_value+'%') OR
			(@search_type=103 AND PO.ContactNumber Like '%'+@search_value+'%') OR
			(@search_type=104 AND PO.FaxNumber Like '%'+@search_value+'%') OR
			(@search_type=105 AND S.PlanLID Like '%'+@search_value+'%') OR
			--Provider
			(@search_type=2 AND CAST(PM.ProviderMaster_PK AS VARCHAR)=@search_value) OR
			(@search_type=201 AND PM.ProviderGroup Like '%'+@search_value+'%') OR
			(@search_type=202 AND PM.Provider_ID Like '%'+@search_value+'%') OR
			(@search_type=203 AND PM.NPI Like '%'+@search_value+'%') OR
			(@search_type=204 AND PM.Lastname+IsNull(', '+PM.Firstname,'') Like '%'+@search_value+'%') OR
			(@search_type=205 AND PM.PIN Like '%'+@search_value+'%') OR
			--Chase
			(@search_type=3 AND CAST(M.Member_PK AS VARCHAR)=@search_value) OR
			(@search_type=301 AND M.Member_ID Like '%'+@search_value+'%') OR
			(@search_type=302 AND M.Lastname+IsNull(', '+M.Firstname,'') Like '%'+@search_value+'%') OR
			(@search_type=303 AND M.HICNumber Like '%'+@search_value+'%') OR
			(@search_type=304 AND S.ChaseID Like '%'+@search_value+'%') OR
			--Coder
			(@search_type=4 AND CAST(CA.User_PK AS VARCHAR)=@search_value)
		)
	)
	SELECT 0 SOrder,COUNT(1) RowNumber,NULL Suspect_PK,NULL Member_PK, NULL ProviderMaster_PK,NULL ProviderOffice_PK,NULL ChaseID, NULL Member_ID,NULL Member,NULL DOB,NULL Provider_ID,NULL Provider,NULL Address,NULL City,NULL State,NULL ZipCode,SUM(IsScanned) Scanned,SUM(IsCoded) Coded,CAST(COUNT(Assignment) AS VARCHAR) Assignment,NULL [Coded Status],NULL AssignedDate
		,SUM(CASE WHEN CompletionStatus_PK=1 THEN 1 ELSE 0 END) CS_Completed
		,SUM(CASE WHEN CompletionStatus_PK=2 THEN 1 ELSE 0 END) CS_Escalate
		,SUM(CASE WHEN CompletionStatus_PK=3 THEN 1 ELSE 0 END) CS_Escalate2
		,SUM(CASE WHEN CompletionStatus_PK=4 THEN 1 ELSE 0 END) CS_ImageIssue
		,SUM(CASE WHEN CompletionStatus_PK=5 THEN 1 ELSE 0 END) CS_DiscrepancyReview  
		,SUM(CASE WHEN CompletionStatus_PK=6 THEN 1 ELSE 0 END) CS_Hold
		FROM tbl
	UNION
	SELECT TOP (@chases) 1 SOrder,RowNumber,Suspect_PK,Member_PK, ProviderMaster_PK,ProviderOffice_PK,ChaseID, Member_ID,Member,DOB,Provider_ID,Provider,Address,City,State,ZipCode,IsScanned,IsCoded,Assignment,[Coded Status],AssignedDate 
		,NULL CS_Completed
		,NULL CS_Escalate
		,NULL CS_Escalate2
		,NULL CS_ImageIssue
		,NULL CS_DiscrepancyReview  
		,NULL CS_Hold	
	FROM tbl
	ORDER BY SOrder,RowNumber
END
GO
