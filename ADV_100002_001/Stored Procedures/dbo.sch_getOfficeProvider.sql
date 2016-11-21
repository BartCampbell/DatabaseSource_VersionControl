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
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@Office bigint,
	@user int,
	@channel int
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

	SELECT PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') ProviderName,P.Provider_PK,Count(S.Member_PK) Charts,SUM(CASE WHEN IsScanned=0 AND IsCNA=0 THEN 1 ELSE 0 END) Remaining
	FROM tblProvider P
		INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK 
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
	WHERE P.ProviderOffice_PK=@Office
	GROUP BY P.Provider_PK,PM.Provider_ID,PM.Lastname,PM.Firstname

	--Office location is scheduled for total xx charts. 31 charts recieved correctly. 10 charts recieved incomplete. 5 charts invoices recieved
	SELECT COUNT(S.Suspect_PK) Charts
		,SUM(CASE WHEN Scanned_Date IS NOT NULL OR ChartRec_Date IS NOT NULL THEN 1 ELSE 0 END) ChartRec
		,SUM(CASE WHEN Scanned_Date IS NULL AND InvoiceRec_Date IS NULL AND ChartRec_Date IS NULL AND ChartRec_InComp_Date IS NOT NULL THEN 1 ELSE 0 END) ChartRec_InComp
		,SUM(CASE WHEN Scanned_Date IS NULL AND ChartRec_Date IS NULL AND InvoiceRec_Date IS NOT NULL THEN 1 ELSE 0 END) InvoiceRec
		,SUM(CASE WHEN Scanned_Date IS NULL AND InvoiceRec_Date IS NULL AND ChartRec_Date IS NULL AND IsCNA=1 THEN 1 ELSE 0 END) CNA
	FROM tblProvider P
		INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK 
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
	WHERE P.ProviderOffice_PK=@Office
END
GO
