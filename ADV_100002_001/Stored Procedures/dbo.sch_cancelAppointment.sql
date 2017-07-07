SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	[sch_cancelAppointment] 1067,1
CREATE PROCEDURE [dbo].[sch_cancelAppointment] 
	@schedule_id int,
	@Usr smallint
AS
BEGIN
		SELECT 
			U.Lastname+', '+U.Firstname ScanTech,U.email_address,
			U2.Lastname+', '+U2.Firstname Scheduler,U2.email_address scheduler_email,
			PO.Address ALine1, City+' '+County+', '+ZipCode+' '+State ALine2 ,
			Sch_Start, Sch_End,GetDate() LastUpdated_Date,
			POS.Project_PK,POS.ProviderOffice_PK,POS.Sch_Type
		INTO #tmp				
		FROM tblProviderOfficeSchedule POS WITH (NOLOCK)
			LEFT JOIN tblUser U WITH (NOLOCK) ON Sch_User_PK = U.User_PK
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = POS.ProviderOffice_PK
			LEFT JOIN tblUser U2 WITH (NOLOCK) ON U2.User_PK = @Usr		
			LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON PO.ZipCode_PK = ZC.ZipCode_PK
		WHERE POS.ProviderOfficeSchedule_PK = @schedule_id
		
		--Updating Contact Log
		DECLARE @ScheduleInfo AS VARCHAR(200)	
		DECLARE @project AS INT
		DECLARE @office AS INT
		SELECT @ScheduleInfo = CAST(Month(Sch_Start) AS VARCHAR)+'/'+CAST(Day(Sch_Start) AS VARCHAR)+'/'+CAST(Year(Sch_Start) AS VARCHAR) + ' for ' + ScanTech 
			,@project = Project_PK
			,@office = ProviderOffice_PK
		FROM #tmp
		
		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date) 
		VALUES(@project,@office,3,@ScheduleInfo,@Usr,GetDate())		
		
		--Removing Scheduling Info
		DELETE D FROM tblProviderOfficeSchedule D 
			INNER JOIN tblProviderOfficeSchedule POS WITH (NOLOCK) ON
				((D.Sch_User_PK IS NULL AND POS.Sch_User_PK IS NULL) OR D.Sch_User_PK = POS.Sch_User_PK) AND 
				((D.Sch_Start IS NULL AND POS.Sch_Start IS NULL) OR D.Sch_Start = POS.Sch_Start) AND
				((D.Sch_End IS NULL AND POS.Sch_End IS NULL) OR D.Sch_End = POS.Sch_End)
		WHERE POS.ProviderOfficeSchedule_PK = @schedule_id
		
		--Update Chase Status
		DECLARE @ChaseStatusPK AS INT
		SELECT TOP 1 @ChaseStatusPK=ChaseStatus_PK FROM tblChaseStatus WHERE IsSchedulingInProgress=1 ORDER BY ChaseStatus_PK

		UPDATE S SET ChaseStatus_PK = @ChaseStatusPK, LastContacted=GetDate()
		FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (ROWLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblChaseStatus CS WITH (ROWLOCK) ON CS.ChaseStatus_PK = S.ChaseStatus_PK 
		WHERE P.ProviderOffice_PK=@office AND S.IsScanned=0 AND S.IsCNA=0 AND CS.IsScheduled=1
		
		--Return Result for Cancel Email
		SELECT * FROM #tmp
END
GO
