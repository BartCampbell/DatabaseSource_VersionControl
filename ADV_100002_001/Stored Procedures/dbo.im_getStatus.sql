SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Oct-19-2014
-- Description:	Status Report will use this sp to pull list of status with count
-- =============================================
--  im_getStatus 0,0,1
CREATE PROCEDURE [dbo].[im_getStatus]
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@user int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)
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
	-- PROJECT SELECTION
	SELECT COUNT(DISTINCT POI.ProviderOfficeInvoice_PK) Invoices,COUNT(S.Suspect_PK) Charts,POI.ProviderOfficeInvoiceBucket_PK
		INTO #tmp
		FROM
			tblProviderOfficeInvoice POI WITH (NOLOCK)
			INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK=POI.ProviderOffice_PK 
			INNER JOIN tblProviderOfficeInvoiceSuspect POIS WITH (NOLOCK) ON POIS.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = POIS.Suspect_PK
			INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
	GROUP BY POI.ProviderOfficeInvoiceBucket_PK

	SELECT POIB.Bucket,POIB.ProviderOfficeInvoiceBucket_PK,IsNull(Invoices,0) Invoices,IsNull(Charts,0) Charts
	INTO #tmp2
	FROM tblProviderOfficeInvoiceBucket POIB 
			LEFT JOIN #tmp POI WITH (NOLOCK) ON POIB.ProviderOfficeInvoiceBucket_PK = POI.ProviderOfficeInvoiceBucket_PK
			WHERE ParentProviderOfficeInvoiceBucket_PK IS NULL
	ORDER BY POIB.sortOrder
	SELECT * FROM #tmp2

	SELECT * FROM (
		SELECT POIB.Bucket,POIB.ProviderOfficeInvoiceBucket_PK,IsNull(Invoices,0) Invoices,IsNull(Charts,0) Charts,ParentProviderOfficeInvoiceBucket_PK,sortOrder
		FROM tblProviderOfficeInvoiceBucket POIB 
				LEFT JOIN #tmp POI WITH (NOLOCK) ON POIB.ProviderOfficeInvoiceBucket_PK = POI.ProviderOfficeInvoiceBucket_PK
				WHERE ParentProviderOfficeInvoiceBucket_PK IS NOT NULL
		UNION
		SELECT 'Non OTL Rejections' Bucket,ProviderOfficeInvoiceBucket_PK,Invoices,Charts,2 ParentProviderOfficeInvoiceBucket_PK,0 sortOrder FROM #tmp2 WHERE ProviderOfficeInvoiceBucket_PK=2
		UNION
		SELECT 'Awaiting Charts' Bucket,ProviderOfficeInvoiceBucket_PK, COUNT(DISTINCT ProviderOfficeInvoice_PK) Invoices,0 Charts,ParentProviderOfficeInvoiceBucket_PK,1 sortOrder FROM
			(SELECT ProviderOfficeInvoiceBucket_PK*100+1 ProviderOfficeInvoiceBucket_PK,POI.ProviderOfficeInvoice_PK,ProviderOfficeInvoiceBucket_PK ParentProviderOfficeInvoiceBucket_PK
			FROM
			tblProviderOfficeInvoice POI WITH (NOLOCK)
			INNER JOIN tblProviderOfficeInvoiceSuspect POIS WITH (NOLOCK) ON POIS.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = POIS.Suspect_PK
			INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
			WHERE ProviderOfficeInvoiceBucket_PK IN (4,5)
			GROUP BY ProviderOfficeInvoiceBucket_PK,POI.ProviderOfficeInvoice_PK
			Having MIN(CASE WHEN S.IsScanned=1 OR S.IsCNA=1 THEN 1 ELSE 0 END)=0
			UNION
			SELECT 401 ProviderOfficeInvoiceBucket_PK,NULL ProviderOfficeInvoice_PK,4 ParentProviderOfficeInvoiceBucket_PK
			UNION
			SELECT 501 ProviderOfficeInvoiceBucket_PK,NULL ProviderOfficeInvoice_PK,5 ParentProviderOfficeInvoiceBucket_PK
			) T GROUP BY ProviderOfficeInvoiceBucket_PK,ParentProviderOfficeInvoiceBucket_PK
		UNION
		SELECT 'All Charts Received' Bucket,ProviderOfficeInvoiceBucket_PK, COUNT(DISTINCT ProviderOfficeInvoice_PK) Invoices,0 Charts,ParentProviderOfficeInvoiceBucket_PK,2 sortOrder FROM
			(SELECT ProviderOfficeInvoiceBucket_PK*100+2 ProviderOfficeInvoiceBucket_PK,POI.ProviderOfficeInvoice_PK,ProviderOfficeInvoiceBucket_PK ParentProviderOfficeInvoiceBucket_PK
			FROM
			tblProviderOfficeInvoice POI WITH (NOLOCK)
			INNER JOIN tblProviderOfficeInvoiceSuspect POIS WITH (NOLOCK) ON POIS.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = POIS.Suspect_PK
			INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
			WHERE ProviderOfficeInvoiceBucket_PK IN (4,5)
			GROUP BY ProviderOfficeInvoiceBucket_PK,POI.ProviderOfficeInvoice_PK
			Having MIN(CASE WHEN S.IsScanned=1 OR S.IsCNA=1 THEN 1 ELSE 0 END)=1
			UNION
			SELECT 402 ProviderOfficeInvoiceBucket_PK,NULL ProviderOfficeInvoice_PK,4 ParentProviderOfficeInvoiceBucket_PK
			UNION
			SELECT 502 ProviderOfficeInvoiceBucket_PK,NULL ProviderOfficeInvoice_PK,5 ParentProviderOfficeInvoiceBucket_PK
			) T GROUP BY ProviderOfficeInvoiceBucket_PK,ParentProviderOfficeInvoiceBucket_PK
	) T	ORDER BY sortOrder
END
GO
