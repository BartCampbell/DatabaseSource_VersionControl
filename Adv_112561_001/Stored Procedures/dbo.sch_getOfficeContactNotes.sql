SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sch_getOfficeContactNotes 0,107
CREATE PROCEDURE [dbo].[sch_getOfficeContactNotes] 
	@Project int,
	@Office int
AS
BEGIN
	SELECT ContactNote_Text,ContactNoteText,IsNull(U.Lastname+', '+U.Firstname,'Not Available') ByUser, CNO.LastUpdated_Date--, contact_num
		--,IR.IssueResponse
		--,IRO.AdditionalResponse
		--,UC.firstname+' '+UC.lastname client
		--,IRO.dtInsert ResponseDate
		--,CASE WHEN COUNT(*)=1 THEN IsNull('<p>'+MAX(P.ProjectGroup)+'</p>','') ELSE NULL END ProjectGroup
		,MIN(CNO.ContactNotesOffice_PK) ContactNotesOffice_PK,U.User_PK,0 Hide  --P.Project_PK,
		,CASE WHEN CN.IsIssueLogResponse=1 THEN 0 ELSE CN.IsSystem END IsSystem, U.User_PK, MAX(CNO.MergedProviderOffice_PK) MergedProviderOffice_PK, CN.IsIssueLogResponse
        FROM tblContactNotesOffice CNO WITH (NOLOCK)
        INNER JOIN tblContactNote CN WITH (NOLOCK) ON CN.ContactNote_PK = CNO.ContactNote_PK
		--LEFT JOIN tblProject P WITH (NOLOCK) ON P.Project_PK = CNO.Project_PK
		LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = LastUpdated_User_PK

        --LEFT JOIN tblIssueResponseOffice IRO ON CNO.ContactNotesOffice_PK = IRO.ContactNotesOffice_PK
        --LEFT JOIN tblIssueResponse IR ON IR.IssueResponse_PK = IRO.IssueResponse_PK
        --LEFT JOIN tblUser UC ON UC.User_PK = IRO.User_PK

		WHERE CNO.Office_PK=@Office --CNO.Project_PK = @Project AND 
		GROUP BY ContactNote_Text,ContactNoteText,IsNull(U.Lastname+', '+U.Firstname,'Not Available'), CNO.LastUpdated_Date, contact_num,U.User_PK
		--,IR.IssueResponse, IRO.AdditionalResponse ,UC.firstname+' '+UC.lastname ,IRO.dtInsert,
		,CN.IsSystem, U.User_PK,CN.IsIssueLogResponse
		/*
		UNION
		SELECT ContactNote_Text,ContactNoteText,IsNull(U.Lastname+', '+U.Firstname,'Not Available') ByUser, CNO.LastUpdated_Date, contact_num
		,IR.IssueResponse
		,IRO.AdditionalResponse
		,UC.firstname+' '+UC.lastname client
		,IRO.dtInsert ResponseDate
		,CASE WHEN COUNT(*)=1 THEN IsNull('<p>'+MAX(P.ProjectGroup)+'</p>','') ELSE NULL END ProjectGroup,MIN(CNO.ContactNotesOffice_PK) ContactNotesOffice_PK,U.User_PK,1 Hide  --P.Project_PK,
		,CN.IsSystem, U.User_PK, NULL MergedProviderOffice_PK
        FROM tblContactNotesOfficeArc CNO WITH (NOLOCK)
        INNER JOIN tblContactNote CN WITH (NOLOCK) ON CN.ContactNote_PK = CNO.ContactNote_PK
		LEFT JOIN tblProject P WITH (NOLOCK) ON P.Project_PK = CNO.Project_PK
		LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = LastUpdated_User_PK

		LEFT JOIN tblIssueResponseOffice IRO ON CNO.ContactNotesOffice_PK = IRO.ContactNotesOffice_PK
        LEFT JOIN tblIssueResponse IR ON IR.IssueResponse_PK = IRO.IssueResponse_PK
        LEFT JOIN tblUser UC ON UC.User_PK = IRO.User_PK
		WHERE CNO.Office_PK=@Office AND IsHide=1
			GROUP BY ContactNote_Text,ContactNoteText,IsNull(U.Lastname+', '+U.Firstname,'Not Available'), CNO.LastUpdated_Date, contact_num,U.User_PK
		,IR.IssueResponse, IRO.AdditionalResponse ,UC.firstname+' '+UC.lastname ,IRO.dtInsert,CN.IsSystem, U.User_PK
		*/
		ORDER BY CNO.LastUpdated_Date DESC 

		SELECT PO.Address+IsNull(', '+City+', '+State+' '+ZipCode,'') OfficeAddress FROM tblProviderOffice PO INNER JOIN tblZipCode ZC ON ZC.ZipCode_PK = PO.ZipCode_PK WHERE ProviderOffice_PK = @Office

		SELECT DISTINCT CNO.MergedProviderOffice_PK,PO.Address+IsNull(', '+City+', '+State+' '+ZipCode,'') OfficeAddress
        FROM tblContactNotesOffice CNO WITH (NOLOCK)
        INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK=CNO.MergedProviderOffice_PK
		INNER JOIN tblZipCode ZC ON ZC.ZipCode_PK = PO.ZipCode_PK
		WHERE CNO.Office_PK=@Office
END
GO
