SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Oct-19-2014
-- Description:	Status Report will use this sp to pull list of status with count
-- =============================================
--  sr_getOfficeStatus 0,1
CREATE PROCEDURE [dbo].[sr_getOfficeStatus]
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@user int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@User AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');	
	-- PROJECT SELECTION
		
	SELECT office_status [Status],COUNT(*) [Count],SUM(CASE WHEN charts=CNA_count THEN 1 ELSE 0 END) CNA,SUM(Charts) Charts,SUM(extracted_count) ScannedCharts,SUM(coded_count) CodedCharts,SUM(CNA_count) CNACharts FROM cacheProviderOffice cPO
		INNER JOIN #tmpProject Pr ON Pr.Project_PK = cPO.Project_PK
	GROUP BY office_status	
	ORDER BY office_status DESC	

	--SELECT * FROM cacheProviderOffice
END
GO
