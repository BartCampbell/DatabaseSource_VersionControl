SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sch_mergeOffice 7,'0,0',1
CREATE PROCEDURE [dbo].[sch_mergeOffice] 
	@OFFICE BIGINT,
	@OFFICE_FROM VARCHAR(MAX),
	@user int,
	@forceMerge int
AS
BEGIN
		CREATE TABLE #Offices2Merge(ProviderOffice_PK BIGINT)
		CREATE INDEX idxProviderOffice_PK ON #Offices2Merge (ProviderOffice_PK)

		DECLARE @SQL VARCHAR(MAX)
		SET @SQL = 'INSERT INTO #Offices2Merge SELECT DISTINCT ProviderOffice_PK FROM tblProviderOffice WHERE ProviderOffice_PK IN ('+@OFFICE_FROM+')';
		EXEC (@SQL);

		IF (@forceMerge=0)
		BEGIN
			If EXISTS(SELECT * FROM tblProviderOfficeSchedule P INNER JOIN #Offices2Merge PO ON P.ProviderOffice_PK = PO.ProviderOffice_PK WHERE sch_type=0 AND Sch_Start>GetDate())
			BEGIN
				SELECT 1 Error;
				return;
			END 
		END
		SELECT 0 Error;

		--Adding Log for Child Office Providers and Chases
		INSERT INTO tblProviderOfficeMergeLog(ProviderOffice_PK,Provider_PK,Suspect_PK) 
		SELECT DISTINCT P.ProviderOffice_PK,P.Provider_PK,Suspect_PK FROM tblSuspect S WITH (NOLOCK) INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK INNER JOIN #Offices2Merge PO ON P.ProviderOffice_PK = PO.ProviderOffice_PK

		--To Parent Office
		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num,MergedProviderOffice_PK) 
		SELECT 0 Project_PK, @OFFICE,5 ContactNote_PK,'Merged '+CAST(COUNT(DISTINCT P.Provider_PK) AS VARCHAR)+' providers with '+CAST(COUNT(DISTINCT S.Suspect_PK) AS VARCHAR)+' charts' ContactNoteText,@user LastUpdated_User_PK,getdate() LastUpdated_Date,0 contact_num,P.ProviderOffice_PK FROM tblSuspect S WITH (NOLOCK) INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK INNER JOIN #Offices2Merge PO ON P.ProviderOffice_PK = PO.ProviderOffice_PK GROUP BY P.ProviderOffice_PK

		--To Child Offices
		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num,MergedProviderOffice_PK) 
		SELECT 0 Project_PK, ProviderOffice_PK,5 ContactNote_PK,'All chases are merged' ContactNoteText,@user LastUpdated_User_PK,getdate() LastUpdated_Date,0 contact_num,@OFFICE FROM #Offices2Merge

		--Merging Child Office to Parent Office
		Update P SET ProviderOffice_PK = @OFFICE FROM tblProvider P INNER JOIN #Offices2Merge PO ON P.ProviderOffice_PK = PO.ProviderOffice_PK

		--Remove Assignment
		Update P SET AssignedDate = NULL, AssignedUser_PK=NULL FROM tblProviderOffice P INNER JOIN #Offices2Merge PO ON P.ProviderOffice_PK = PO.ProviderOffice_PK

		--Removing On-site Scheduling for Child offices
		DELETE P FROM tblProviderOfficeSchedule P INNER JOIN #Offices2Merge PO ON P.ProviderOffice_PK = PO.ProviderOffice_PK WHERE sch_type=0

		--Replace Parent Office for Child offices scheduling
		UPDATE P SET ProviderOffice_PK=@OFFICE FROM tblProviderOfficeSchedule P INNER JOIN #Offices2Merge PO ON P.ProviderOffice_PK = PO.ProviderOffice_PK WHERE sch_type=0

		--Deleting Cache for Child Offices
		DELETE P FROM cacheProviderOffice P INNER JOIN #Offices2Merge PO ON P.ProviderOffice_PK = PO.ProviderOffice_PK WHERE P.ProviderOffice_PK <> @OFFICE;


END
GO
