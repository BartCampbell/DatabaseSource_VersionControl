SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: 
-- Description:	
-- =============================================
--	prepareCacheProviderOffice

CREATE PROCEDURE [dbo].[prepareCacheProviderOffice]
AS
BEGIN
	Truncate Table cacheProviderOffice

	--Any changes from here should be applied to sch_mergeOffice
	INSERT INTO cacheProviderOffice(Project_PK,ProviderOffice_PK,charts,providers,schedule_type,extracted_count,coded_count,cna_count)
	SELECT S.Project_PK,P.ProviderOffice_PK,Count(S.Suspect_PK) Charts,Count(DISTINCT S.Provider_PK) Providers	
			,MAX(sch_type) schedule_type
			,SUM(CASE WHEN IsScanned=1 THEN 1 ELSE 0 END) extracted
			,SUM(CASE WHEN IsCoded=1 THEN 1 ELSE 0 END) coded
			,SUM(CASE WHEN IsScanned=0 AND IsCNA=1 THEN 1 ELSE 0 END) cna
		FROM 
			tblProvider P WITH (NOLOCK) 
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON P.ProviderOffice_PK=PO.ProviderOffice_PK 
			LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
			OUTER APPLY (SELECT DISTINCT TOP 1 ProviderOffice_PK,sch_type FROM tblProviderOfficeSchedule WITH (NOLOCK) WHERE Project_PK=S.Project_PK AND ProviderOffice_PK=PO.ProviderOffice_PK) POS

		GROUP BY S.Project_PK,P.ProviderOffice_PK

	--Updating combine follow up
	Update CNO SET follow_up=T.followup, dtLastContact = T.LastUpdated_Date, contact_num = T.contact_num
		FROM cacheProviderOffice CNO 
		Outer APPLY (SELECT TOP 1 followup,LastUpdated_Date,contact_num FROM tblContactNotesOffice X WHERE CNO.ProviderOffice_PK = X.Office_PK 
		AND X.followup is not null  ORDER BY X.ContactNotesOffice_PK DESC) T

	--Updating Master Table
	SELECT SUM(Charts) Charts, SUM(Charts-extracted_count-cna_count) Remaining, ProviderOffice_PK INTO #tmp3 FROM cacheProviderOffice GROUP BY ProviderOffice_PK

	IF EXISTS (SELECT * FROM #tmp3 WHERE Remaining=0)
		Update C SET C.ProviderOfficeBucket_PK=0
		FROM tblProviderOffice C WITH (ROWLock) 
			INNER JOIN #tmp3 T ON T.ProviderOffice_PK = C.ProviderOffice_PK AND T.Remaining=0

	IF EXISTS (SELECT * FROM #tmp3 WHERE Remaining>0 AND Charts>Remaining)
		Update C SET C.ProviderOfficeBucket_PK=6
		FROM tblProviderOffice C WITH (ROWLock) 
			INNER JOIN #tmp3 T ON T.ProviderOffice_PK = C.ProviderOffice_PK AND T.Remaining>0 AND T.Charts>T.Remaining
END
GO
