SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- um_UpdateAddUser 'demoe'
CREATE PROCEDURE [dbo].[um_UpdateAddUser] 
	@id int, 
	@username varchar(200),
	@email varchar(200), 
	@pwd varchar(200), 	
	@lastname varchar(200), 
	@firstname varchar(200), 
	@isScanTech bit, 
	@isScheduler bit, 
	@isCoder bit, 
	@isQA bit, 
	@isHRA bit, 
	@isQCC bit, 
	@isAdmin bit, 
	@IsClient bit, 
	@workingHours varchar(MAX), 
	@workingAreas varchar(MAX), 
	@isActive bit, 
	@DeativateAfter smalldatetime,
	@Provider_ID as varchar(10),
	@Provider_PK as bigint,
	@Modules varchar(MAX),
	@sch_name varchar(200),
	@sch_tel varchar(50),
	@sch_fax varchar(50),
	@isScanTechSV bit, 
	@isSchedulerSV bit,
	@IsChangePasswordOnFirstLogin bit,
	@location tinyint, 
	@IsAllowDownload bit,
	@IsSchedulerManager bit
AS
BEGIN
	DECLARE @only_work_selected_hours BIT
	DECLARE @only_work_selected_zipcodes BIT
	if (@workingHours='')
		SET @only_work_selected_hours=0
	else
		SET @only_work_selected_hours=1
		
	if (@workingAreas='')
		SET @only_work_selected_zipcodes=0
	else
		SET @only_work_selected_zipcodes=1	
	
	IF (@isHRA=1)
	BEGIN
		IF (@Provider_ID<>'')
		BEGIN
			SELECT TOP 1 @Provider_PK=Provider_PK FROM tblProvider P INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK=P.ProviderMaster_PK WHERE PM.Provider_ID=@Provider_ID
		END
			
		If (@Provider_PK=0)
		BEGIN
			DECLARE @ProviderMaster_PK AS INT

			INSERT INTO tblProviderMaster(Lastname,Firstname,LastUpdated,Provider_ID)
			VALUES(@lastname,@firstname,GETDATE(),@Provider_ID)

			SELECT @ProviderMaster_PK = @@IDENTITY;

			INSERT INTO tblProvider(ProviderMaster_PK,ProviderOffice_PK)
			VALUES(@ProviderMaster_PK,0)
		
			SELECT @Provider_PK = @@IDENTITY;
		END	
		ELSE
		BEGIN
			UPDATE PM SET Lastname=@lastname, Firstname=@firstname, Provider_ID = @Provider_ID
			FROM tblProvider P INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK=P.ProviderMaster_PK 
			WHERE P.Provider_PK = @Provider_PK
		END
	END
			
	IF (@id=0)
	BEGIN
		INSERT INTO tblUser(Username,[Password],Lastname,Firstname,Email_Address,IsClient,IsAdmin,IsScanTech,IsScheduler,IsReviewer,IsQA,IsHRA,isQCC,IsActive,only_work_selected_hours,only_work_selected_zipcodes,linked_provider_id,linked_provider_pk,sch_name,sch_tel,sch_fax,isScanTechSV,isSchedulerSV,IsChangePasswordOnFirstLogin,location_pk,isAllowDownload,IsSchedulerManager)
		VALUES(@Username,@pwd,@Lastname,@Firstname,@email,@IsClient,@IsAdmin,@IsScanTech,@IsScheduler,@isCoder,@IsQA,@IsHRA,@isQCC,@IsActive,@only_work_selected_hours,@only_work_selected_zipcodes,@Provider_ID,@Provider_PK,@sch_name,@sch_tel,@sch_fax,@isScanTechSV,@isSchedulerSV,@IsChangePasswordOnFirstLogin,@location,@isAllowDownload,@IsSchedulerManager)
		
		SELECT @id=@@IDENTITY;
	END
	ELSE
	BEGIN
		Update tblUser SET Lastname=@Lastname,Firstname=@Firstname,Email_Address=@email
			,IsClient=@IsClient,IsAdmin=@IsAdmin,IsScanTech=@IsScanTech,IsScheduler=@IsScheduler,IsReviewer=@isCoder,IsQA=@IsQA,IsHRA=@IsHRA,isQCC=@isQCC,IsActive=@IsActive,only_work_selected_hours=@only_work_selected_hours,only_work_selected_zipcodes=@only_work_selected_zipcodes
			,linked_provider_id=@Provider_ID, linked_provider_pk=@Provider_PK
			,sch_name=@sch_name,sch_tel=@sch_tel,sch_fax=@sch_fax
			,isScanTechSV = @isScanTechSV, isSchedulerSV = @isSchedulerSV, IsSchedulerManager=@IsSchedulerManager
			,IsChangePasswordOnFirstLogin=@IsChangePasswordOnFirstLogin
			,location_pk = @location, isAllowDownload = @isAllowDownload
		WHERE User_PK=@id
		
		IF (@pwd<>'')
			Update tblUser SET [Password]=@pwd WHERE User_PK=@id
	END
	
	DELETE FROM tblUserWorkingHour WHERE USER_PK = @id
	if (@workingHours<>'')
	BEGIN
		SET @workingHours = replace(@workingHours,'#id#',cast(@id as varchar));
		exec (@workingHours)
	END
	
	DELETE FROM tblUserZipCode WHERE USER_PK = @id
	if (@workingAreas<>'')
	BEGIN
		set @workingAreas='INSERT INTO tblUserZipCode(User_PK,ZipCode_PK) SELECT '+cast(@id as varchar)+' id,ZipCode_PK FROM tblZipCode WHERE ZipCode_PK IN ('+@workingAreas+');'
		exec (@workingAreas)
	END
	
	DELETE FROM tblUserPage WHERE USER_PK = @id
	DELETE FROM tblUserProject WHERE USER_PK = @id
	if (@Modules<>'')
	BEGIN
		SET @Modules = replace(@Modules,'#id#',cast(@id as varchar));
		exec (@Modules)
	END	
END
GO
