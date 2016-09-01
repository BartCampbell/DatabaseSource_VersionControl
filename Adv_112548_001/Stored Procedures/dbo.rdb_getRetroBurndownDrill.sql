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
rdb_getRetroBurndownDrill 0,1,'0',1,'08/26/2015',0
*/
CREATE PROCEDURE [dbo].[rdb_getRetroBurndownDrill]
	@Projects varchar(20),
	@User int,
	@ProjectGroup varchar(10),
	@DrillType int,
	@Dt date,
	@Export int
AS
BEGIN
	SET @Dt = DateAdd(day,1,@Dt);
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
	CREATE TABLE #tmp(Suspect_PK [bigint] NOT NULL primary key,Sch_Date date)
	INSERT INTO #tmp
	SELECT DISTINCT S.Suspect_PK,MIN(IsNull(PO.LastUpdated_Date,S.Scanned_Date)) Sch_Date--, MIN(PO.sch_type)
	FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject AP ON AP.Project_PK = S.Project_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			LEFT JOIN tblProviderOfficeSchedule PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK AND S.Project_PK = PO.Project_PK
	WHERE PO.ProviderOffice_PK IS NOT NULL OR S.Scanned_Date IS NOT NULL
	GROUP BY S.Suspect_PK

	--Overall Progress for All Projects
	IF (SELECT COUNT(*) FROM #tmpProject)>1
	BEGIN
		SELECT 
			S.Project_PK,Pr.Project_Name Project,
			COUNT(CASE WHEN IsNull(T.Sch_Date,S.Scanned_Date) IS NOT NULL THEN S.Suspect_PK ELSE NULL END) Scheduled,
			COUNT(CASE WHEN S.IsScanned=1 THEN S.Suspect_PK ELSE NULL END) Extracted,
			COUNT(CASE WHEN S.IsScanned=0 AND S.IsCNA=1 THEN S.Suspect_PK ELSE NULL END) CNA,
			COUNT(CASE WHEN S.IsCoded=1 THEN S.Suspect_PK ELSE NULL END) Coded
		FROM tblSuspect S WITH (NOLOCK) 
			INNER JOIN #tmpProject tP ON tP.Project_PK = S.Project_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProject Pr WITH (NOLOCK) ON Pr.Project_PK = S.Project_PK
			LEFT JOIN #tmp T ON T.Suspect_PK = S.Suspect_PK
				WHERE  (@DrillType=1 AND IsNull(IsNull(T.Sch_Date,S.Scanned_Date),S.CNA_Date)<@Dt)
					OR (@DrillType=2 AND S.Scanned_Date<@Dt)
					OR (@DrillType=3 AND S.Coded_Date<@Dt)
		GROUP BY S.Project_PK,Pr.Project_Name
		ORDER BY Pr.Project_Name
	END
	ELSE
	BEGIN	
		With tbl AS(
			SELECT 
				ROW_NUMBER() OVER(ORDER BY M.Lastname ASC) AS [#],
				S.ChaseID,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,
				PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,
				PO.Address,ZC.ZipCode [Zip Code],ZC.City,ZC.State,
				POB.Bucket [Office Status],
				T.Sch_Date Scheduled,
				S.Scanned_Date Extracted,
				CNA_Date CNA,
				Coded_Date Coded
			FROM tblSuspect S WITH (NOLOCK) 
				INNER JOIN #tmpProject tP ON tP.Project_PK = S.Project_PK
				INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				LEFT JOIN tblProviderOfficeBucket POB WITH (NOLOCK) ON PO.ProviderOfficeBucket_PK = POB.ProviderOfficeBucket_PK
				LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
				LEFT JOIN #tmp T ON T.Suspect_PK = S.Suspect_PK
				WHERE  (@DrillType=1 AND IsNull(T.Sch_Date,S.Scanned_Date)<@Dt)
					OR (@DrillType=2 AND S.Scanned_Date<@Dt)
					OR (@DrillType=3 AND S.Coded_Date<@Dt)
					OR (@DrillType=4 AND S.CNA_Date<@Dt)
		)
		SELECT * FROM tbl WHERE [#]<=25 OR @Export=1 ORDER BY [#]

		SELECT P.Project_Name FROM tblProject P INNER JOIN #tmpProject tP ON tP.Project_PK=P.Project_PK
	END
END
GO
