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
rdb_retroTopHCC 0,1
*/
Create PROCEDURE [dbo].[rdb_retroTopHCC]
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
	

	--TOP 15 HCC
	SELECT TOP 15 H.HCC,H.HCC_Desc,COUNT(DISTINCT CD.Suspect_PK) HCCs FROM tblModelCode MC WITH (NOLOCK)
		INNER JOIN tblCodedData CD WITH (NOLOCK) ON CD.DiagnosisCode = MC.DiagnosisCode AND MC.V12HCC IS NOT NULL
		INNER JOIN tblSuspect S WITH (NOLOCK) ON CD.Suspect_PK = S.Suspect_PK
		INNER JOIN tblHCC H WITH (NOLOCK) ON H.HCC = MC.V12HCC AND H.PaymentModel=12
		INNER JOIN #tmpProject AP ON AP.Project_PK = S.Project_PK
	GROUP BY H.HCC,H.HCC_Desc ORDER BY COUNT(DISTINCT CD.Suspect_PK) DESC
END
GO
