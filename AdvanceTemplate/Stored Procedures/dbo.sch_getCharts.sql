SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sch_getCharts 4,107
CREATE PROCEDURE [dbo].[sch_getCharts] 
	@drill_type tinyint,
	@office bigint
AS
BEGIN
	DECLARE @SQL VARCHAR(MAX)
	--SELECT * FROM tblSuspect
	SET @SQL = 'SELECT S.Suspect_PK,S.ChaseID,M.Member_ID, M.Lastname+IsNull('', ''+M.Firstname,'''') MemberName, M.DOB,
		    PM.Provider_ID, PM.Lastname+IsNull('', ''+PM.Firstname,'''') ProviderName ';
            if @drill_type = 0 --All
                SET @SQL = @SQL + ' ,IsNull(ChartRec_Date,Scanned_Date) Received, ChartRec_InComp_Date Incomplete,SICN.Note Notes, InvoiceRec_Date Invoice ,CNA_Date CNA,SN.Note_Text Notes, Scanned_Date Extracted, Coded_Date Coded';
            if (@drill_type = 1) --Chart Rec
                SET @SQL = @SQL + ' ,IsNull(ChartRec_Date,Scanned_Date) Received';
            else if (@drill_type = 2) --ChartRec_InComp
                SET @SQL = @SQL + ' ,ChartRec_InComp_Date Incomplete,SICNN.IncompleteNote, SICN.Note Notes,IsNull(IsInComp_Replied,0) Replied';
            else if (@drill_type = 3) --Invoice Rec
                SET @SQL = @SQL + ' ,InvoiceRec_Date Invoice';
            else if (@drill_type = 4) --CNA
                SET @SQL = @SQL + ' ,CNA_Date CNA,SN.Note_Text Notes';
		    SET @SQL = @SQL + ' FROM tblProvider P
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK 
				INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK';
            if (@drill_type = 0) --//All
                SET @SQL = @SQL + ' LEFT JOIN tblSuspectScanningNotes SSN WITH (NOLOCK) ON SSN.Suspect_PK = S.Suspect_PK
					LEFT JOIN tblScanningNotes SN WITH (NOLOCK) ON SN.ScanningNote_PK = SSN.ScanningNote_PK
					LEFT JOIN tblSuspectIncompleteNotes SICN WITH (NOLOCK) ON SICN.Suspect_PK = S.Suspect_PK';
            if (@drill_type = 4) --CNA 
                SET @SQL = @SQL + ' LEFT JOIN tblSuspectScanningNotes SSN WITH (NOLOCK) ON SSN.Suspect_PK = S.Suspect_PK
					LEFT JOIN tblScanningNotes SN WITH (NOLOCK) ON SN.ScanningNote_PK = SSN.ScanningNote_PK';
            if (@drill_type = 2) --ChartRec_InComp 
                SET @SQL = @SQL + ' LEFT JOIN tblSuspectIncompleteNotes SICN WITH (NOLOCK) ON SICN.Suspect_PK = S.Suspect_PK
					LEFT JOIN tblIncompleteNote SICNN WITH (NOLOCK) ON SICN.IncompleteNote_PK = SICNN.IncompleteNote_PK';

            SET @SQL = @SQL + ' WHERE P.ProviderOffice_PK=' + CAST(@office AS VARCHAR);

            if (@drill_type = 1) --Chart Rec
                SET @SQL = @SQL + ' AND (Scanned_Date IS NOT NULL OR ChartRec_Date IS NOT NULL)'
            else if (@drill_type = 2) --ChartRec_InComp
                SET @SQL = @SQL + ' AND (Scanned_Date IS NULL AND InvoiceRec_Date IS NULL AND ChartRec_Date IS NULL AND ChartRec_InComp_Date IS NOT NULL)';
            else if (@drill_type = 3) --Invoice Rec
                SET @SQL = @SQL + ' AND (Scanned_Date IS NULL AND ChartRec_Date IS NULL AND InvoiceRec_Date IS NOT NULL)';
            else if (@drill_type = 4) --CNA
                SET @SQL = @SQL + ' AND (Scanned_Date IS NULL AND InvoiceRec_Date IS NULL AND ChartRec_Date IS NULL AND S.IsCNA=1)';

		EXEC  (@SQL)
END
GO
