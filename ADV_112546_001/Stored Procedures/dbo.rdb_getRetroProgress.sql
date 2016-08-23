SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:	Sajid Ali
-- Create date: Oct-02-2015
-- Description:	
-- =============================================
/* Sample Executions
rdb_getRetroProgress '0',1,'0'
PrepareCacheProviderOffice
*/
CREATE PROCEDURE [dbo].[rdb_getRetroProgress]
	@Projects varchar(20),
	@User int,
	@ProjectGroup varchar(10)
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@User AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');

	--Schedule Info
	CREATE TABLE #tmp(Project_PK [int] NOT NULL,Provider_PK bigint NOT NULL) --,Sch_Date DateTime
	--PRINT 'INSERT INTO #tmp'
	INSERT INTO #tmp
	SELECT DISTINCT S.Project_PK,S.Provider_PK--,MIN(PO.LastUpdated_Date) Sch_Date	
	FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject AP ON AP.Project_PK = S.Project_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			LEFT JOIN tblProviderOfficeSchedule PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK AND S.Project_PK = PO.Project_PK
	WHERE PO.ProviderOffice_PK IS NOT NULL OR S.Scanned_Date IS NOT NULL
	--GROUP BY S.Project_PK,S.Provider_PK
	CREATE CLUSTERED INDEX  idxTProjectPK ON #tmp (Project_PK,Provider_PK)
	/*
	INSERT INTO #tmp
	SELECT DISTINCT S.Project_PK,TP.Provider_PK--,GetDate() Sch_Date	
	FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject AP ON AP.Project_PK = S.Project_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProvider TP WITH (NOLOCK) ON TP.ProviderOffice_PK = P.ProviderOffice_PK
			LEFT JOIN #tmp T WITH (NOLOCK) ON P.Provider_PK = T.Provider_PK AND S.Project_PK = T.Project_PK
	WHERE (S.IsCNA=1 OR S.IsScanned=1 OR S.IsCoded=1) AND T.Provider_PK IS NULL
		*/

	--Overall Progress
		SELECT S.ChartPriority, COUNT(*) Chases
			,SUM(CASE WHEN T.Provider_PK IS NULL THEN 0 ELSE 1 END) Scheduled
			,SUM(CASE WHEN S.IsScanned=1 THEN 1 ELSE 0 END) Extracted
			,SUM(CASE WHEN S.IsScanned=0 AND S.IsCNA=1 THEN 1 ELSE 0 END) CNA
			,SUM(CASE WHEN S.IsCoded=1 AND S.IsScanned=1 THEN 1 ELSE 0 END) Coded
		INTO #tmpX
		FROM tblSuspect S WITH (NOLOCK) 
			INNER JOIN #tmpProject AP ON AP.Project_PK = S.Project_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			LEFT JOIN #tmp T ON S.Project_PK = T.Project_PK AND S.Provider_PK = T.Provider_PK
		GROUP BY S.ChartPriority --ORDER BY ChartPriority
		UNION
		SELECT '' ChartPriority, 0 Chases
			,0 Scheduled
			,0 Extracted
			,0 CNA
			,0 Coded

		SELECT * FROM #tmpX ORDER BY CASE WHEN ChartPriority='' THEN 'ZZZZZZ' ELSE ChartPriority END

		SELECT S.ChartPriority, SLC.CoderLevel, COUNT(*) Chases
		FROM tblSuspectLevelCoded SLC WITH (NOLOCK) 
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = SLC.Suspect_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			INNER JOIN #tmpProject tP ON tP.Project_PK = S.Project_PK
		WHERE SLC.IsCompleted=1
		GROUP BY S.ChartPriority, SLC.CoderLevel
		ORDER BY S.ChartPriority
END
GO
