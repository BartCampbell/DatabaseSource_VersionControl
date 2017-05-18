SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sch_getOfficeContactNotes 0,107,1
CREATE PROCEDURE [dbo].[sch_getOfficeContactNotes] 
	@Project int,
	@Office int,
	@SessionPK tinyint
AS
BEGIN
	SELECT ContactNote_Text,ContactNoteText,IsNull(U.Lastname+', '+U.Firstname,'Not Available') ByUser, CNO.LastUpdated_Date--, contact_num
		,MIN(CNO.ContactNotesOffice_PK) ContactNotesOffice_PK,U.User_PK,0 Hide  --P.Project_PK,
		,CASE WHEN CN.IsIssueLogResponse=1 THEN 0 ELSE CN.IsSystem END IsSystem, U.User_PK, MAX(CNO.MergedProviderOffice_PK) MergedProviderOffice_PK, CN.IsIssueLogResponse
		,CN.sortOrder
        FROM tblContactNotesOffice CNO WITH (NOLOCK)
        INNER JOIN tblContactNote CN WITH (NOLOCK) ON CN.ContactNote_PK = CNO.ContactNote_PK
		LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = LastUpdated_User_PK
		WHERE CNO.Office_PK=@Office AND (
			(CNO.Session_PK IS NULL AND (@SessionPK IS NULL OR @SessionPK=0)) 
			OR CNO.Session_PK=@SessionPK
			)
		GROUP BY ContactNote_Text,ContactNoteText,IsNull(U.Lastname+', '+U.Firstname,'Not Available'), CNO.LastUpdated_Date, contact_num,U.User_PK
		,CN.IsSystem, U.User_PK,CN.IsIssueLogResponse,CN.sortOrder
		ORDER BY CNO.LastUpdated_Date DESC 

		SELECT PO.Address+IsNull(', '+City+', '+State+' '+ZipCode,'') OfficeAddress FROM tblProviderOffice PO INNER JOIN tblZipCode ZC ON ZC.ZipCode_PK = PO.ZipCode_PK WHERE ProviderOffice_PK = @Office

		SELECT DISTINCT CNO.MergedProviderOffice_PK,PO.Address+IsNull(', '+City+', '+State+' '+ZipCode,'') OfficeAddress
        FROM tblContactNotesOffice CNO WITH (NOLOCK)
        INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK=CNO.MergedProviderOffice_PK
		LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK = PO.ZipCode_PK
		WHERE CNO.Office_PK=@Office

		IF (@SessionPK IS NULL OR @SessionPK=0)
		BEGIN
			--Old Session List
			SELECT DISTINCT S.Session_PK,S.Session_Description FROM tblSession S WITH (NOLOCK) INNER JOIN tblContactNotesOffice CNO WITH (NOLOCK) ON CNO.Session_PK=S.Session_PK WHERE CNO.Office_PK=@Office AND S.IsActiveSession=0
		END
		ELSE
		BEGIN
			DECLARE @ScheduleType VARCHAR(100)
			DECLARE @IsInvoiced AS BIT = 0
			--Session Chart Break Down
			SELECT TOP 1 @ScheduleType = ST.ScheduleType FROM tblProviderOfficeSchedule S WITH (NOLOCK) INNER JOIN tblScheduleType ST WITH (NOLOCK) ON ST.ScheduleType_PK = S.sch_type WHERE S.ProviderOffice_PK=@Office AND S.Session_PK=@SessionPK Order By S.LastUpdated_Date DESC
			IF EXISTS(SELECT * FROM tblProviderOfficeSchedule WITH (NOLOCK) WHERE sch_type=1 AND ProviderOffice_PK=@Office AND Session_PK=@SessionPK)
				SET @IsInvoiced=1

			SELECT Count(DISTINCT S.Suspect_PK) Charts, 
				COUNT(DISTINCT CASE WHEN IsScanned=1 THEN S.Suspect_PK ELSE NULL END) Extracted, IsNull(@ScheduleType,'Unknown') ScheduleType,
				@IsInvoiced IsInvoiced, 
				COUNT(DISTINCT CASE WHEN POIS.ProviderOfficeInvoice_PK IS NOT NULL THEN POIS.Suspect_PK ELSE NULL END) Invoiced, 
				COUNT(DISTINCT CASE WHEN POIS.ProviderOfficeInvoice_PK IS NOT NULL AND S.IsScanned=1 THEN POIS.Suspect_PK ELSE NULL END) InvoicedExtracted--,
				--COUNT(DISTINCT CASE WHEN CS.IsIssue=1 THEN S.Suspect_PK ELSE NULL END) IssueChart, @IssueDesc LastIssue
			FROM tblSuspect S WITH (NOLOCK) 
				INNER JOIN tblChaseStatus CS WITH (NOLOCK) ON CS.ChaseStatus_PK = S.ChaseStatus_PK
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
				LEFT JOIN tblProviderOfficeInvoiceSuspect POIS WITH (NOLOCK) ON S.Suspect_PK = POIS.Suspect_PK
				LEFT JOIN tblProviderOfficeInvoice POI WITH (NOLOCK) ON POIS.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK AND POI.ProviderOfficeInvoiceBucket_PK IN (4,5)
			WHERE S.Session_PK=@SessionPK AND P.ProviderOffice_PK=@Office

			SELECT DISTINCT CS.ChaseStatus,CS.ChartResolutionCode
			FROM tblSuspect S WITH (NOLOCK) 
				INNER JOIN tblSessionChaseHistory SCH WITH (NOLOCK) ON SCH.Suspect_PK = S.Suspect_PK AND SCH.Session_PK = S.Session_PK
				INNER JOIN tblChaseStatus CS WITH (NOLOCK) ON SCH.ChaseStatus_PK = CS.ChaseStatus_PK
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			WHERE S.Session_PK=@SessionPK AND P.ProviderOffice_PK=@Office AND CS.IsIssue=1
		END
END
GO
