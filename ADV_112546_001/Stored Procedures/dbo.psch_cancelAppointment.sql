SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--psch_cancelAppointment 28,1
CREATE PROCEDURE [dbo].[psch_cancelAppointment] 
	@schedule_id int,
	@Usr smallint
AS
BEGIN
		SELECT 
			U.Lastname+', '+U.Firstname ScanTech,U.email_address,
			U2.Lastname+', '+U2.Firstname Scheduler,U2.email_address scheduler_email,
			PO.Address ALine1, City+' '+County+', '+ZipCode+' '+State ALine2 ,
			Sch_Start, Sch_End,GetDate() LastUpdated_Date,
			POS.Project_PK,POS.Member_PK
		INTO #tmpX				
		FROM tblMemberSchedule POS
			INNER JOIN tblUser U ON Sch_User_PK = U.User_PK
			INNER JOIN tblMember PO ON PO.Member_PK = POS.Member_PK
			INNER JOIN tblUser U2 ON U2.User_PK = @Usr		
			LEFT JOIN tblZipCode ZC ON PO.ZipCode_PK = ZC.ZipCode_PK
		WHERE POS.Schedule_PK = @schedule_id
		
		PRINT 'Updating Contact Log'
		DECLARE @ScheduleInfo AS VARCHAR(200)	
		DECLARE @project AS INT
		DECLARE @member AS INT
		SELECT @ScheduleInfo = CAST(Month(Sch_Start) AS VARCHAR)+'/'+CAST(Day(Sch_Start) AS VARCHAR)+'/'+CAST(Year(Sch_Start) AS VARCHAR) + ' for ' + ScanTech 
			,@project = Project_PK
			,@member = Member_PK
		FROM #tmpX
		
		INSERT INTO tblMemberContactNotes(Project_PK,Member_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date) 
		VALUES(@project,@member,3,@ScheduleInfo,@Usr,GetDate())		
		
		PRINT 'Removing Scheduling Info'
		Update tblSuspect SET MemberStatus=5,LastUpdated=GETDATE() WHERE Suspect_PK IN (SELECT Suspect_PK FROM tblMemberSchedule WHERE Schedule_PK = @schedule_id)
		DELETE FROM tblMemberSchedule WHERE Schedule_PK = @schedule_id
		
		PRINT 'Return Result for Cancel Email'
		SELECT * FROM #tmpX
END
GO
