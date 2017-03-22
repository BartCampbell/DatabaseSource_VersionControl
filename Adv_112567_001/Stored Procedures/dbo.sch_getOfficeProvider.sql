SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sch_getOfficeProvider 1,1
CREATE PROCEDURE [dbo].[sch_getOfficeProvider] 
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Status1 varchar(1000),
	@Status2 varchar(1000),
	@Office bigint,
	@user int
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

	SELECT PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') ProviderName,PM.ProviderGroup,P.Provider_PK,Count(S.Member_PK) Charts,SUM(CASE WHEN IsScanned=0 AND IsCNA=0 THEN 1 ELSE 0 END) Remaining
	FROM tblProvider P
		INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK 
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
	WHERE P.ProviderOffice_PK=@Office
	GROUP BY P.Provider_PK,PM.Provider_ID,PM.Lastname,PM.Firstname,PM.ProviderGroup

	--Office location is scheduled for total xx charts. 31 charts recieved correctly. 10 charts recieved incomplete. 5 charts invoices recieved
	SELECT COUNT(DISTINCT S.Suspect_PK) Charts
		,COUNT(DISTINCT CASE WHEN Scanned_Date IS NOT NULL OR ChartRec_Date IS NOT NULL THEN S.Suspect_PK ELSE NULL END) ChartRec
		,COUNT(DISTINCT CASE WHEN Scanned_Date IS NULL AND InvoiceRec_Date IS NULL AND ChartRec_Date IS NULL AND ChartRec_InComp_Date IS NOT NULL THEN S.Suspect_PK ELSE NULL END) ChartRec_InComp
		,COUNT(DISTINCT CASE WHEN Scanned_Date IS NULL AND ChartRec_Date IS NULL AND InvoiceRec_Date IS NOT NULL THEN S.Suspect_PK ELSE NULL END) InvoiceRec
		,COUNT(DISTINCT CASE WHEN Scanned_Date IS NULL AND InvoiceRec_Date IS NULL AND ChartRec_Date IS NULL AND IsCNA=1 THEN S.Suspect_PK ELSE NULL END) CNA
		,COUNT(DISTINCT CASE WHEN Scanned_Date IS NULL AND S.CNA_Date IS NULL THEN S.Suspect_PK ELSE NULL END) Remaining
	FROM tblProvider P
		INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK 
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
	WHERE P.ProviderOffice_PK=@Office

	--
	SELECT Count(Distinct S.Suspect_PK) IssueCharts 
			FROM tblProviderOffice PO WITH (NOLOCK) 
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
				INNER JOIN tblChaseStatus CS WITH (NOLOCK) ON S.ChaseStatus_PK = CS.ChaseStatus_PK
				INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
				INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
				INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
	WHERE PO.ProviderOffice_PK=@Office AND CS.ProviderOfficeBucket_PK=5 AND (PO.ProviderOfficeSubBucket_PK IS NULL OR PO.ProviderOfficeSubBucket_PK<>3) AND S.IsCNA=0 AND S.IsScanned=0
END
GO
