SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_retroTopHCC 0,1
*/
Create PROCEDURE [dbo].[rdb_retroTopHCC]
	@Projects varchar(20),
	@User int,
	@ProjectGroup varchar(10),
	@Channel int
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
		DELETE T FROM #tmpProject T INNER JOIN tblProject P ON P.Project_PK = T.Project_PK WHERE ProjectGroup_PK<>@ProjectGroup
		
	IF (@Channel<>0)
		DELETE T FROM #tmpChannel T WHERE Channel_PK<>@Channel				 
	-- PROJECT/Channel SELECTION

	--TOP 15 HCC
	SELECT TOP 15 H.HCC,H.HCC_Desc,COUNT(DISTINCT CD.Suspect_PK) HCCs FROM tblModelCode MC WITH (NOLOCK)
		INNER JOIN tblCodedData CD WITH (NOLOCK) ON CD.DiagnosisCode = MC.DiagnosisCode AND MC.V12HCC IS NOT NULL
		INNER JOIN tblSuspect S WITH (NOLOCK) ON CD.Suspect_PK = S.Suspect_PK
		INNER JOIN tblHCC H WITH (NOLOCK) ON H.HCC = MC.V12HCC AND H.PaymentModel=12
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
	GROUP BY H.HCC,H.HCC_Desc ORDER BY COUNT(DISTINCT CD.Suspect_PK) DESC
END
GO
