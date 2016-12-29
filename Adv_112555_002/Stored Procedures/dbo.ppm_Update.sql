SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ppm_Update] 
	@id int, 
	@email varchar(200), 
	@lastname varchar(200), 
	@firstname varchar(200), 
	@workingHours varchar(MAX), 
	@workingAreas varchar(MAX), 
	@Provider_ID as varchar(10),
	@Provider_PK as bigint,
	@is_male bit,
	@scheduler int,
	@address varchar(200),
	@zip int,
	@willing2travell int
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
	
	IF @Provider_PK = 0
	BEGIN
		SELECT TOP 1 @Provider_PK=Provider_PK FROM tblProvider P INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK=P.ProviderMaster_PK WHERE PM.Provider_ID=@Provider_ID
	END
	ELSE IF NOT EXISTS(SELECT * FROM tblProvider P INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK=P.ProviderMaster_PK WHERE P.Provider_PK=@Provider_PK)
	BEGIN
		SET @Provider_PK = 0
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
			
	Update tblUser SET Lastname=@Lastname,Firstname=@Firstname,Email_Address=@email
		,only_work_selected_hours=@only_work_selected_hours,only_work_selected_zipcodes=@only_work_selected_zipcodes
		,linked_provider_id=@Provider_ID, linked_provider_pk=@Provider_PK
		,is_male=@is_male,linked_scheduler_user_pk = @scheduler
		,[address]=@address, zipcode_pk=@zip, willing2travell = @willing2travell
	WHERE User_PK=@id

	--ALTER TABLE tblUser ADD is_male bit 
	--ALTER TABLE tblUser ADD linked_scheduler_user_pk int
	
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
END
GO
