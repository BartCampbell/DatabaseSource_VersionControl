SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[psch_saveMemberContactNote] 
	@project int,
	@member bigint,
	@note int,
	@aditionaltext varchar(max),
	@User_PK int
AS
BEGIN
	    INSERT INTO tblMemberContactNotes(Project_PK,Member_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date) 
	    VALUES(@project,@member,@note,@aditionaltext,@User_PK,getdate());

            if (@note = 22)
            BEGIN 
                Update S
                SET IsCNA=1,CNA_User_PK=@User_PK,CNA_Date=GetDate()
                FROM tblSuspect S
                WHERE Member_PK=@member AND S.Project_PK=@project
                AND Scanned_User_PK IS NULL AND Coded_User_PK IS NULL AND CNA_User_PK IS NULL
            END

			DECLARE @MemberStatus AS INT = 7
			IF EXISTS(SELECT ContactNote_PK FROM tblContactNote WHERE ContactNote_Text='Appointment Confirmed' AND ContactNote_PK=@note)
				SET @MemberStatus = 3
			
			Update S
                SET MemberStatus=@MemberStatus, LastUpdated=GETDATE()
                FROM tblSuspect S
                WHERE Member_PK=@member AND S.Project_PK=@project AND MemberStatus>@MemberStatus
END
GO
