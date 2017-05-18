SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	oil_updateIssue @Channel='',@Projects='',@ProjectGroup='',@User=0,@issue_res=0,@issue_res_text='',@Office=0
CREATE PROCEDURE [dbo].[oil_updateIssue]
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@User int,
	@issue_res int,
	@issue_res_text varchar(1000),
	@Office int
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
		EXEC ('DELETE T FROM #tmpProject T INNER JOIN tblProject P ON P.Project_PK = T.Project_PK WHERE ProjectGroup_PK NOT IN ('+@ProjectGroup+')')
		
	IF (@Channel<>'0')
		EXEC ('DELETE T FROM #tmpChannel T WHERE Channel_PK NOT IN ('+@Channel+')')					 
	-- PROJECT/Channel SELECTION
	/*
	2-Re Contact Office			
	3-Other
	5-Update
	*/
	IF (@issue_res IN (2,3,10,11))	
	BEGIN
		DECLARE @OTL_ChaseStatus AS SmallINT = 0
		SELECT @OTL_ChaseStatus = ChaseStatus_PK FROM tblChaseStatus WHERE 
			(VendorCodeType='CIOX' AND VendorCode='Scheduled' AND @issue_res=10) -- OTL Approved
			OR
			(VendorCodeType='CIOX' AND VendorCode='NCA' AND @issue_res=11) -- OTL Rejected
			
		UPDATE S SET FollowUp = GetDate(), ChaseStatus_PK = CASE WHEN @issue_res IN (10,11) THEN @OTL_ChaseStatus ELSE S.ChaseStatus_PK END
			,IsCNA = CASE WHEN @issue_res=11 THEN 1 ELSE 0 END
			,CNA_Date = CASE WHEN @issue_res=11 THEN GetDate() ELSE NULL END
			,CNA_User_PK = CASE WHEN @issue_res=11 THEN @User ELSE NULL END
		FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (ROWLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN tblChaseStatus CS ON CS.ChaseStatus_PK = S.ChaseStatus_PK
		WHERE P.ProviderOffice_PK=@Office AND S.IsCoded=0 AND S.IsScanned=0 AND S.IsCNA=0 AND CS.ProviderOfficeBucket_PK=5
	END


	DECLARE @ContactNote AS INT
	SELECT @ContactNote=ContactNote_PK FROM tblContactNote WHERE (@issue_res=2 AND ContactNoteID='OILRO') OR (@issue_res=3 AND ContactNoteID='OILON') OR (@issue_res=5 AND ContactNoteID='OILU') OR (@issue_res=10 AND ContactNoteID='OILOA') OR (@issue_res=11 AND ContactNoteID='OILOR')

	INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num,followup) 
	VALUES(0,@office,@ContactNote,@issue_res_text,@User,getdate(),0,GetDate())

	If (@issue_res=10) --OTL Approved
		Update tblProviderOfficeInvoice SET ProviderOfficeInvoiceBucket_PK=10 WHERE ProviderOffice_PK=@Office AND ProviderOfficeInvoiceBucket_PK=9
	else if (@issue_res=11) --OTL Rejected
		Update tblProviderOfficeInvoice SET ProviderOfficeInvoiceBucket_PK=13 WHERE ProviderOffice_PK=@Office AND ProviderOfficeInvoiceBucket_PK=9
		

		
/*
		if (issue_res == 2 || issue_res == 3)
        {//Recontact or Others go to scheduler 
            iOfficeIssueStatus = 2;
            sql = "Update tblProviderOffice WITH (ROWLOCK) SET ProviderOfficeBucket_PK=9 WHERE ProviderOffice_PK = " + office + ";";
        }
        else if (issue_res == 1)
        {//Remove from Chase List //Close
            iOfficeIssueStatus = 4;
            sql = "Update S SET IsCNA=1,CNA_User_PK=" + usr + ",CNA_Date=GetDate() FROM tblSuspect S WITH (RowLock) INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK WHERE S.IsScanned=0 AND P.ProviderOffice_PK=" + office + ";";
            sql += "Update tblProviderOffice WITH (ROWLOCK) SET ProviderOfficeBucket_PK=0 WHERE ProviderOffice_PK = " + office + ";";
        }
        else if (issue_res == 4)
        {//Data Issue
            iOfficeIssueStatus = 6;
            sql = "Update tblProviderOffice WITH (ROWLOCK) SET ProviderOfficeBucket_PK=8 WHERE ProviderOffice_PK = " + office + ";";
        }

        if (issue_res == 1 || issue_res==6)
        {
            sql += "Update tblContactNotesOffice SET IsResponded=1 WHERE Office_PK = " + office + ";";
            sql += "DELETE tblProviderOfficeStatus WHERE ProviderOffice_PK = " + office + ";";
            sql += "INSERT INTO tblIssueResponseOffice(IssueResponse_PK,ContactNotesOffice_PK,AdditionalResponse,User_PK,dtInsert) SELECT TOP 1 " + issue_res + ",ContactNotesOffice_PK,'" + issue_res_text.Replace("'", "`") + "'," + usr + ",GetDate() FROM tblContactNotesOffice WHERE ContactNotesOffice_PK IN (" + allIds + ") ORDER BY ContactNotesOffice_PK DESC;";
        }
        else if (issue_res != 5)
        {
            sql += "Update tblContactNotesOffice SET IsResponded=1 WHERE Office_PK = " + office + ";";
            sql += "Update tblProviderOfficeStatus SET OfficeIssueStatus=" + iOfficeIssueStatus + "  WHERE ProviderOffice_PK = " + office + ";";
            sql += "INSERT INTO tblIssueResponseOffice(IssueResponse_PK,ContactNotesOffice_PK,AdditionalResponse,User_PK,dtInsert) SELECT TOP 1 " + issue_res + ",ContactNotesOffice_PK,'" + issue_res_text.Replace("'", "`") + "'," + usr + ",GetDate() FROM tblContactNotesOffice WHERE ContactNotesOffice_PK IN (" + allIds + ") ORDER BY ContactNotesOffice_PK DESC;";
        }
        else
        {
            sql += "INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num,followup) VALUES(0," + office + ",0,'" + issue_res_text.Replace("'", "`") + "'," + usr + ",getdate(),0,null)";
        }
*/
END
GO
