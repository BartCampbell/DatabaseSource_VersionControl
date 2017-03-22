SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sch_scheduleOffice 2,5,1,2014,4,21,18,15,10,0,999,1,1,1
CREATE PROCEDURE [dbo].[sch_scheduleOffice] 
	@project smallint,
	@office bigint,
	@ScanTech int,
	@Year int,
	@Month int,
	@Day int,
	@fh int,
	@fm int,
	@th int,
	@tm int,
	@Usr smallint,
	@schedule_type smallint,
	@followup smallint,
	@AddInfo varchar(200)
AS
BEGIN
	-- PROJECT/Channel SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)

	CREATE TABLE #tmpChannel (Channel_PK INT)
	CREATE INDEX idxChannelPK ON #tmpChannel (Channel_PK)

	IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@Usr)	--For Admins
	BEGIN
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblChannel 
	END
	ELSE
	BEGIN
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblUserProject WHERE User_PK=@Usr
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblUserChannel WHERE User_PK=@Usr
	END
	-- PROJECT/Channel SELECTION

		--Update tblProviderOfficeStatus WITH (ROWLOCK) SET OfficeIssueStatus=3 WHERE ProviderOffice_PK=@office

		DECLARE @Followup_Date AS DATE
		DECLARE @ScheduleInfo AS VARCHAR(200)
		if (@schedule_type=0) 
		BEGIN
			DECLARE @dt_from AS SmallDateTime
			DECLARE @dt_to AS SmallDateTime
			SET @dt_from = CAST(CAST(@Year AS VARCHAR)+'-'+CAST(@Month AS VARCHAR)+'-'+CAST(@Day AS VARCHAR) AS SMALLDATETIME)
			SET @dt_to = @dt_from 

			SET @dt_from = DateAdd(minute,@fm,DateAdd(hour,@fh,@dt_from))
			SET @dt_to = DateAdd(minute,@tm,DateAdd(hour,@th,@dt_to))

			SET @Followup_Date = @dt_from
			
-----------Transaction Starts-------------------
			RETRY1: -- Transaction RETRY
			BEGIN TRANSACTION
			BEGIN TRY
				INSERT INTO tblProviderOfficeSchedule(Project_PK,ProviderOffice_PK,Sch_Start,Sch_End,Sch_User_PK,LastUpdated_User_PK,LastUpdated_Date,Sch_Type,followup)
				SELECT 0 Project_PK,@office,@dt_from,@dt_to,@ScanTech,@Usr,GetDate(),0,0-- FROM cacheProviderOffice WHERE ProviderOffice_PK=@office
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
				BEGIN
					WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
					GOTO RETRY1 -- Go to Label RETRY
				END
			END CATCH
-----------Transaction Starts-------------------
		
			SELECT @ScheduleInfo = Lastname+', '+Firstname FROM tblUser WHERE User_PK = @ScanTech
			SET @ScheduleInfo = CAST(@Month AS VARCHAR)+'/'+CAST(@Day AS VARCHAR)+'/'+CAST(@Year AS VARCHAR) + ' from ' + RIGHT('0'+CAST(@fh AS VARCHAR),2) + RIGHT('0'+CAST(@fm AS VARCHAR),2) + ' to ' + RIGHT('0'+CAST(@th AS VARCHAR),2) + RIGHT('0'+CAST(@tm AS VARCHAR),2) + ' for ' + @ScheduleInfo;
		END
		ELSE		
		BEGIN
-----------Transaction Starts-------------------
			RETRY2: -- Transaction RETRY
			BEGIN TRANSACTION
			BEGIN TRY
				INSERT INTO tblProviderOfficeSchedule(Project_PK,ProviderOffice_PK,Sch_Start,Sch_End,Sch_User_PK,LastUpdated_User_PK,LastUpdated_Date,Sch_Type,followup,AddInfo)
				SELECT 0 Project_PK,@office,DateAdd(day,@followup,GetDate()),DateAdd(day,@followup,GetDate()),@ScanTech,@Usr,GetDate(),@schedule_type,@followup,@AddInfo --FROM cacheProviderOffice WHERE ProviderOffice_PK=@office
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
				BEGIN
					WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
					GOTO RETRY2 -- Go to Label RETRY
				END
			END CATCH
-----------Transaction Starts-------------------

			SET @Followup_Date = DateAdd(day,@followup,GetDate())

			SET @ScheduleInfo = 'Scheduled to '
			if @schedule_type=1
				SET @ScheduleInfo = @ScheduleInfo + 'fax in'
			else if @schedule_type=2
				SET @ScheduleInfo = @ScheduleInfo + 'email'
			else if @schedule_type=3
				SET @ScheduleInfo = @ScheduleInfo + 'post'
			else if @schedule_type=4
			BEGIN
				Update tblProviderOffice WITH (ROWLOCK) SET ProviderOfficeSubBucket_PK=2 WHERE ProviderOffice_PK=@office
				SET @ScheduleInfo = @ScheduleInfo + 'invoiced'
			END
			SET @ScheduleInfo = @ScheduleInfo + ' with follow up in ' + CAST(@followup AS VARCHAR) + ' day'
			IF @AddInfo<>''
				SET @ScheduleInfo = @ScheduleInfo + '('+ @AddInfo +')'
			
		END

		DECLARE @contact_num AS INT = 0
		DECLARE @contact_date AS date
		SELECT @contact_num = IsNull(MAX(contact_num),0), @contact_date = IsNull(MAX(LastUpdated_Date),GetDate()) FROM tblContactNotesOffice WITH (NOLOCK) WHERE Office_PK=@office AND Project_PK=@project
		IF @contact_date<>CAST(GETDATE() AS DATE)
			SET @contact_num = @contact_num + 1
		ELSE IF @contact_num=0
			SET @contact_num = 1

-----------Transaction Starts-------------------
			RETRY3: -- Transaction RETRY
			BEGIN TRANSACTION
			BEGIN TRY
				INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num) 
				SELECT 0 Project_PK,@office,2,@ScheduleInfo,@Usr,GetDate(),@contact_num --FROM cacheProviderOffice WHERE ProviderOffice_PK=@office
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
				BEGIN
					WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
					GOTO RETRY3 -- Go to Label RETRY
				END
			END CATCH
-----------Transaction Starts-------------------

-----------Transaction Starts-------------------
			RETRY4: -- Transaction RETRY
			BEGIN TRANSACTION
			BEGIN TRY
				DECLARE @ChaseStatusPK AS INT
				SELECT TOP 1 @ChaseStatusPK=ChaseStatus_PK FROM tblChaseStatus WHERE IsScheduled=1 ORDER BY ChaseStatus_PK

				UPDATE S SET FollowUp = @Followup_Date, ChaseStatus_PK = @ChaseStatusPK, LastContacted=GetDate()
				FROM tblProvider P WITH (NOLOCK)
					INNER JOIN tblSuspect S WITH (ROWLOCK) ON S.Provider_PK = P.Provider_PK
					INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
					INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
				WHERE P.ProviderOffice_PK=@office AND S.IsScanned=0 AND S.IsCNA=0
				--Update Cache
				----UPDATE cacheProviderOffice WITH (RowLock) SET schedule_type=@schedule_type,follow_up=@Followup_Date,dtLastContact=GetDate() WHERE ProviderOffice_PK=@office --Project_PK=@project AND 
				--In case of schedule, we need to set bucket to schedule no matter what status we are on
				----UPDATE tblProviderOffice WITH (RowLock) SET ProviderOfficeBucket_PK=CASE WHEN @schedule_type=4 THEN 5 ELSE 3 END WHERE ProviderOffice_PK=@office --AND ProviderOfficeBucket_PK IN (1,2) --
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
				BEGIN
					WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
					GOTO RETRY4 -- Go to Label RETRY
				END
			END CATCH
-----------Transaction Starts-------------------
		
-----------Transaction Starts-------------------
			RETRY5: -- Transaction RETRY
			BEGIN TRANSACTION
			BEGIN TRY
				UPDATE tblContactNotesOffice WITH (RowLock) SET followup = @Followup_Date WHERE Office_PK=@office --Project_PK=@project AND 
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
				BEGIN
					WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
					GOTO RETRY5 -- Go to Label RETRY
				END
			END CATCH
-----------Transaction Starts-------------------

		if (@schedule_type IN (1,2,3,4,5))
			return;
	
	--Reading Schedule Info
	SELECT 
		U.Lastname+', '+U.Firstname ScanTech,U.email_address,
		U2.Lastname+', '+U2.Firstname Scheduler,U2.email_address scheduler_email,
		PO.Address ALine1, City+' '+County+', '+ZipCode+' '+State ALine2 ,
		@dt_from Sch_Start, @dt_to Sch_End,GetDate() LastUpdated_Date,
		ContactPerson, ContactNumber
		FROM tblUser U WITH (NOLOCK) 
		INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = @office 
		INNER JOIN tblUser U2 WITH (NOLOCK) ON U2.User_PK = @Usr		
		LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON PO.ZipCode_PK = ZC.ZipCode_PK		
		WHERE U.User_PK = @ScanTech		
		
	--Reading Provider Info
	SELECT Distinct Provider_ID,Lastname+', '+Firstname Provider FROM tblProvider P WITH (NOLOCK) 
		INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
	WHERE ProviderOffice_PK = @office-- AND S.Project_PK=@project	
END
GO
