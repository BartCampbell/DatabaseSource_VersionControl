SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sch_getCharts 4,107,1
CREATE PROCEDURE [dbo].[sch_getCharts] 
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@drill_type tinyint,
	@office bigint,
	@User int
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
	-- PROJECT/Channel SELECTION

	DECLARE @SQL VARCHAR(MAX)
	--SELECT * FROM tblProviderMaster
	SET @SQL = 'SELECT S.Suspect_PK,S.ChaseID,M.Member_ID, M.Lastname+IsNull('', ''+M.Firstname,'''') MemberName,M.HICNumber, M.DOB,
		    PM.Provider_ID [Centauri Provider ID],PM.PIN [Plan Provider ID], PM.Lastname+IsNull('', ''+PM.Firstname,'''') ProviderName,PM.ProviderGroup,S.PlanLID [Plan Location ID] 
			,CS.ChaseStatus [Chase Status],CS.ChartResolutionCode [Chase Resolution Code]';
            if @drill_type = 0 --All
                SET @SQL = @SQL + ' ,IsNull(ChartRec_Date,Scanned_Date) Received, ChartRec_InComp_Date Incomplete,SICN.Note Notes, InvoiceRec_Date Invoice ,CNA_Date CNA,SN.Note_Text Notes, Scanned_Date Extracted, Coded_Date Coded';
            if (@drill_type = 1) --Chart Rec
                SET @SQL = @SQL + ' ,IsNull(ChartRec_Date,Scanned_Date) Received';
            else if (@drill_type = 2) --ChartRec_InComp
                SET @SQL = @SQL + ' ,ChartRec_InComp_Date Incomplete,SICNN.IncompleteNote, SICN.Note Notes,IsNull(IsInComp_Replied,0) Replied';
            else if (@drill_type = 3) --Invoice Rec
                SET @SQL = @SQL + ' ,InvoiceRec_Date Invoice';
            else if (@drill_type = 4) --CNA
                SET @SQL = @SQL + ' ,CNA_Date CNA,SN.Note_Text Notes';
		    SET @SQL = @SQL + ' FROM tblProvider P
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK 
				INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
				INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
				INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				LEFT JOIN tblChaseStatus CS WITH (NOLOCK) ON S.ChaseStatus_PK = CS.ChaseStatus_PK';
            if (@drill_type = 0) --//All
                SET @SQL = @SQL + ' LEFT JOIN tblSuspectScanningNotes SSN WITH (NOLOCK) ON SSN.Suspect_PK = S.Suspect_PK
					LEFT JOIN tblScanningNotes SN WITH (NOLOCK) ON SN.ScanningNote_PK = SSN.ScanningNote_PK
					LEFT JOIN tblSuspectIncompleteNotes SICN WITH (NOLOCK) ON SICN.Suspect_PK = S.Suspect_PK';
            if (@drill_type = 4) --CNA 
                SET @SQL = @SQL + ' LEFT JOIN tblSuspectScanningNotes SSN WITH (NOLOCK) ON SSN.Suspect_PK = S.Suspect_PK
					LEFT JOIN tblScanningNotes SN WITH (NOLOCK) ON SN.ScanningNote_PK = SSN.ScanningNote_PK';
            if (@drill_type = 2) --ChartRec_InComp 
                SET @SQL = @SQL + ' LEFT JOIN tblSuspectIncompleteNotes SICN WITH (NOLOCK) ON SICN.Suspect_PK = S.Suspect_PK
					LEFT JOIN tblIncompleteNote SICNN WITH (NOLOCK) ON SICN.IncompleteNote_PK = SICNN.IncompleteNote_PK';
            if (@drill_type = 6) --ISSUE
				SET @SQL = @SQL + ' INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK';



            SET @SQL = @SQL + ' WHERE P.ProviderOffice_PK=' + CAST(@office AS VARCHAR);

            if (@drill_type = 1) --Chart Rec
                SET @SQL = @SQL + ' AND (S.IsScanned=1 OR ChartRec_Date IS NOT NULL)'
            else if (@drill_type = 2) --ChartRec_InComp
                SET @SQL = @SQL + ' AND (S.IsScanned=0 AND InvoiceRec_Date IS NULL AND ChartRec_Date IS NULL AND ChartRec_InComp_Date IS NOT NULL)';
            else if (@drill_type = 3) --Invoice Rec
                SET @SQL = @SQL + ' AND (ChartRec_Date IS NULL AND InvoiceRec_Date IS NOT NULL AND S.IsCNA=0 AND S.IsScanned=0 AND S.IsCoded=0)';
            else if (@drill_type = 4) --CNA
                SET @SQL = @SQL + ' AND (S.IsCNA=1 AND S.IsScanned=0 AND S.IsCoded=0)';
            else if (@drill_type = 5) --Remaining
                SET @SQL = @SQL + ' AND (S.IsCNA=0 AND S.IsScanned=0 AND S.IsCoded=0)';
			else if (@drill_type = 6) --ISSUE
				SET @SQL = @SQL + ' AND CS.ProviderOfficeBucket_PK=5 AND (PO.ProviderOfficeSubBucket_PK IS NULL OR PO.ProviderOfficeSubBucket_PK<>3) AND S.IsCNA=0 AND S.IsScanned=0 AND S.IsCoded=0';

		EXEC  (@SQL)
END
GO
