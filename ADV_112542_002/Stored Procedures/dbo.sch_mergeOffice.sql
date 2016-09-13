SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sch_mergeOffice 7,'0,0',1
CREATE PROCEDURE [dbo].[sch_mergeOffice] 
	@OFFICE BIGINT,
	@OFFICE_FROM VARCHAR(MAX),
	@user int
AS
BEGIN
		DECLARE @SQL VARCHAR(MAX)
		--Inserting Contact Notes (Starts)
		SELECT TOP 0 Project_PK,SUM(providers) providers,sum(charts) charts INTO #tmpOffice FROM cacheProviderOffice GROUP BY Project_PK

		SET @SQL = 'INSERT INTO #tmpOffice SELECT Project_PK,SUM(providers) providers,sum(charts) charts FROM cacheProviderOffice WITH (NOLOCK) WHERE ProviderOffice_PK IN ('+@OFFICE_FROM+') GROUP BY Project_PK';
		EXEC (@SQL);
	
		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num) 
		SELECT O.Project_PK, ProviderOffice_PK,5 ContactNote_PK,'Merged '+CAST(T.providers AS VARCHAR)+' providers with '+CAST(T.charts AS VARCHAR)+' charts' ContactNoteText,@user LastUpdated_User_PK,getdate() LastUpdated_Date,0 contact_num 
		FROM cacheProviderOffice O WITH (NOLOCK) INNER JOIN #tmpOffice T ON T.Project_PK = O.Project_PK WHERE ProviderOffice_PK=@OFFICE
		--Inserting Contact Notes (Ends)

		--Added to Move notes STARTs
		SET @SQL = 'Update CNO SET ContactNoteText = PO.Address+''<br>''+CNO.ContactNoteText FROM tblContactNotesOffice CNO WITH (ROWLOCK) INNER JOIN tblProviderOffice PO ON PO.ProviderOffice_PK = CNO.Office_PK WHERE ProviderOffice_PK IN ('+@OFFICE_FROM+');'
		EXEC (@SQL);
		SET @SQL = 'Update CNO SET Office_PK = ' + CAST(@OFFICE AS VARCHAR) + ' FROM tblContactNotesOffice CNO WITH (ROWLOCK) WHERE Office_PK IN ('+@OFFICE_FROM+');'
		EXEC (@SQL);
		--Added to Move notes ENDs

		SET @SQL = 'Update tblProvider WITH (ROWLOCK) SET ProviderOffice_PK = ' + CAST(@OFFICE AS VARCHAR) + ' WHERE ProviderOffice_PK IN ('+@OFFICE_FROM+'); DELETE cacheProviderOffice WHERE ProviderOffice_PK IN ('+@OFFICE_FROM+'); Update tblProviderOffice SET [Address] = ''Merged - ''+IsNull([Address],'''') WHERE ProviderOffice_PK IN ('+@OFFICE_FROM+');';
		EXEC (@SQL);

		DELETE cacheProviderOffice WHERE ProviderOffice_PK = @OFFICE;

		--Code Picked from [prepareCacheProviderOffice]
		INSERT INTO cacheProviderOffice(Project_PK,ProviderOffice_PK,charts,providers,office_status,contact_num,follow_up,schedule_type,extracted_count,coded_count,cna_count)
		SELECT S.Project_PK,P.ProviderOffice_PK,Count(S.Suspect_PK) Charts,Count(DISTINCT S.Provider_PK) Providers	
				,CASE WHEN Count(S.Coded_User_PK)>0 THEN 1 WHEN Count(S.Scanned_User_PK)>0 THEN 2 WHEN COUNT(POS.ProviderOffice_PK)>0 THEN 3 WHEN COUNT(CNO.Office_PK)>0 THEN 4 ELSE 5 END OfficeStatus
				,IsNull(MAX(contact_num),0) contact_num
				,MAX(followup) followup 
				,MAX(sch_type) schedule_type
				,SUM(CASE WHEN IsScanned=1 THEN 1 ELSE 0 END) extracted
				,SUM(CASE WHEN IsCoded=1 THEN 1 ELSE 0 END) coded
				,SUM(CASE WHEN IsScanned=0 AND IsCNA=1 THEN 1 ELSE 0 END) cna
			FROM 
				tblProvider P WITH (NOLOCK) 
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
				LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON P.ProviderOffice_PK=PO.ProviderOffice_PK 
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
				OUTER APPLY (SELECT DISTINCT TOP 1 ProviderOffice_PK,sch_type,Sch_Start followup FROM tblProviderOfficeSchedule WITH (NOLOCK) WHERE Project_PK=S.Project_PK AND ProviderOffice_PK=PO.ProviderOffice_PK) POS
				OUTER APPLY (SELECT Office_PK,MAX(contact_num) contact_num FROM tblContactNotesOffice WITH (NOLOCK) WHERE Project_PK=S.Project_PK AND Office_PK=PO.ProviderOffice_PK GROUP BY Office_PK) CNO
			WHERE P.ProviderOffice_PK = @OFFICE
			GROUP BY S.Project_PK,P.ProviderOffice_PK

		Update cacheProviderOffice WITH (ROWLOCK) SET
			contacted = CASE WHEN office_status=4 THEN 1 ELSE 0 END,
			scheduled = CASE WHEN office_status=3 THEN 1 ELSE 0 END,
			extracted = CASE WHEN office_status=2 THEN 1 ELSE 0 END,
			coded	  = CASE WHEN office_status=1 THEN 1 ELSE 0 END
		WHERE ProviderOffice_PK = @OFFICE
END
GO
