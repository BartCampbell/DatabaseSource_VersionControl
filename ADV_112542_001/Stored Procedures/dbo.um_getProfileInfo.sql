SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- um_getProfileInfo 1
CREATE PROCEDURE [dbo].[um_getProfileInfo] 
	@id int
AS
BEGIN
	SELECT IsClient [Client],IsAdmin [System Administrator]
			,IsScheduler [Scheduler], isSchedulerSV [Scheduling Supervisor], IsSchedulerManager [Scheduling Manager]
			,IsReviewer [Coder],IsQA [Coding QA]
			,IsHRA [Practitioner], isQCC [QCC]
			,IsScanTech [Scan Tech], isScanTechSV [Scan Tech Supervisor]
			,isAllowDownload [Excel Download Allowed]
			--,only_work_selected_hours, only_work_selected_zipcodes
			--,linked_provider_id,IsNull(linked_provider_pk,0) linked_provider_pk
			--,sch_name,sch_tel,sch_fax
			--,IsNull(Location_PK,0) Location_PK, isAllowDownload
		FROM tblUser
		WHERE User_PK=@id

	SELECT SchPrac.Lastname+', '+SchPrac.Firstname SchPracName,U.linked_provider_id,U.willing2travell,U.EmploymentStatus,EA.EmploymentAgency,U.allergic_to_cats,U.allergic_to_dogs
		,U.address, City, State, ZipCode 
		,PS.PractitionerSpecialty,U.PractitionerSpecialty_Other
	from tblUser U 
		LEFT JOIN tblUser SchPrac ON SchPrac.User_PK = U.linked_scheduler_user_pk
		LEFT JOIN tblEmploymentAgency EA ON EA.EmploymentAgency_PK = U.EmploymentAgency
		LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK = U.zipcode_pk
		LEFT JOIN tblPractitionerSpecialty PS ON PS.PractitionerSpecialty_PK = U.PractitionerSpecialty_PK
	WHERE U.User_PK=@id

	SELECT D.Day_Name,UWH.FromHour,UWH.FromMin,UWH.ToHour,UWH.ToMin 
	FROM tblUserWorkingHour UWH 
		INNER JOIN tblDay D ON D.Day_PK = UWH.Day_PK 
	WHERE User_PK=@id

	SELECT DISTINCT ZipCode,City,State 
	FROM tblUserZipCode UZC 
		INNER JOIN tblZipCode ZC ON ZC.ZipCode_PK = UZC.ZipCode_PK 
	WHERE User_PK=@id

	SELECT U.User_PK,U.Lastname+', '+U.Firstname Practitioner,QCC.Lastname+', '+QCC.Firstname QCC
		,U.address, City, State, ZipCode 
	from tblUser U 
		LEFT JOIN tblUser QCC ON QCC.linked_scheduler_user_pk = U.User_PK
		LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK = U.zipcode_pk
	WHERE U.linked_scheduler_user_pk=@id
END    
GO
