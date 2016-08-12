SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sch_getOffice @Projects='0', @ProjectGroup='0', @Page=1, @PageSize=100, @Alpha='', @Sort='', @Order='', @Provider=9, @bucket=0, @followup_bucket=0, @user=60, @scheduler=60, @PoolPK=0, @ZonePK=0, @OFFICE=0
CREATE PROCEDURE [dbo].[sch_getOffice] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4),
	@Provider BigInt,
	@bucket tinyint,
	@followup_bucket tinyint,
	@user int,
	@scheduler int,
	@PoolPK int,
	@ZonePK int,
	@OFFICE bigint
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)
	IF (@Provider<>0)
	BEGIN
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblProject P WITH (NOLOCK) WHERE P.IsRetrospective=1
	END
	ELSE IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT Project_PK FROM tblProject P WITH (NOLOCK) WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT P.Project_PK FROM tblProject P WITH (NOLOCK) LEFT JOIN tblUserProject UP WITH (NOLOCK) ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@User AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WITH (NOLOCK) WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');	
	-- PROJECT SELECTION

	DECLARE @IsScheduler AS BIT = 0
	DECLARE @IsSupervisor AS BIT = 0
	DECLARE @IsManager AS BIT = 0
	If (@Provider<>0) 
	BEGIN
		SET @scheduler = 0
		SET @PoolPK = 0;
		SET @ZonePK = 0;
		SET @bucket = 0;
		SET @followup_bucket=0;
		SET @Projects = '0'
		SET @ProjectGroup = '0'
		SET @IsManager=1
		SELECT TOP 1 @OFFICE = ProviderOffice_PK FROM tblProvider WITH (NOLOCK) WHERE Provider_PK=@Provider;
	END
	ELSE 
	BEGIN 
		IF @scheduler<>0
		BEGIN
			SET @IsScheduler = 1
		END
		ELSE
		BEGIN
			SELECT @IsScheduler=IsScheduler,@IsSupervisor=IsSchedulerSV,@IsManager=CASE WHEN IsSchedulerManager=1 OR IsAdmin=1 THEN 1 ELSE 0 END FROM tblUser WHERE User_PK = @user
			IF (@IsManager=1)	-- If User is Manager then we need to skip assignment for him
			BEGIN
				SET @IsScheduler = 0
				SET @IsSupervisor = 0			
			END
			ELSE IF (@PoolPK=0) -- If not a Manager and pool is not request then only showing assignements
			BEGIN
				SET @IsScheduler = 1
				SET @scheduler = @user
			END
		END
	END


	CREATE TABLE #tmpOffices (ProviderOffice_PK BIGINT,Providers INT, Charts Int, LastContact SmallDateTime, FollowUpDate SmallDateTime,Offices smallint)
	CREATE INDEX idxProviderOffice_PK ON #tmpOffices (ProviderOffice_PK)

	INSERT INTO #tmpOffices(ProviderOffice_PK,Providers, Charts, LastContact, FollowUpDate,Offices)
	SELECT PO.ProviderOffice_PK,Sum(cPO.Providers) Providers, Sum(cPO.Charts-cPO.extracted_count-cPO.cna_count) Charts,MAX(dtLastContact) LastContact,MAX(follow_up) FollowUpDate,Count(*) Offices 
		FROM tblProviderOffice PO WITH (NOLOCK)
		INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN #tmpProject P ON P.Project_PK = cPO.Project_PK 
		LEFT JOIN tblZoneZipcode ZZC WITH (NOLOCK) ON ZZC.ZipCode_PK = PO.ZipCode_PK
		WHERE (@bucket=0 OR PO.ProviderOfficeBucket_PK=@bucket)
			AND (@PoolPK=0 OR PO.Pool_PK=@PoolPK)
			AND (@ZonePK=0 OR ZZC.Zone_PK=@ZonePK)
			AND (@scheduler=0 OR PO.AssignedUser_PK=@scheduler)
			AND (@followup_bucket=0 OR follow_up<=GetDate())
			AND (@OFFICE=0 OR PO.ProviderOffice_PK=@OFFICE)
		GROUP BY PO.ProviderOffice_PK

	IF @Page>0 AND @PageSize>0
	BEGIN
		With tbl AS(
		SELECT ROW_NUMBER() OVER(
			ORDER BY 
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'LC' THEN IsNull(cPO.LastContact,DateAdd(day,+500,GetDate())) WHEN 'FU' THEN IsNull(FollowUpDate,DateAdd(day,+500,GetDate())) ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'LC' THEN IsNull(cPO.LastContact,DateAdd(day,-500,GetDate())) WHEN 'FU' THEN IsNull(FollowUpDate,DateAdd(day,-500,GetDate())) ELSE NULL END END DESC,
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'AD' THEN PO.Address WHEN 'CT' THEN ZC.City WHEN 'CN' THEN ZC.County WHEN 'ST' THEN ZC.State WHEN 'ZC' THEN ZC.Zipcode WHEN 'CP' THEN PO.ContactPerson WHEN 'GN' THEN PO.GroupName WHEN 'CNU' THEN PO.ContactNumber WHEN 'FN' THEN PO.FaxNumber ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'AD' THEN PO.Address WHEN 'CT' THEN ZC.City WHEN 'CN' THEN ZC.County WHEN 'ST' THEN ZC.State WHEN 'ZC' THEN ZC.Zipcode WHEN 'CP' THEN PO.ContactPerson WHEN 'FN' THEN PO.GroupName WHEN 'CNU' THEN PO.ContactNumber WHEN 'FN' THEN PO.FaxNumber ELSE NULL END END DESC,
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'CH' THEN cPO.Charts WHEN 'OS' THEN PO.ProviderOfficeBucket_PK WHEN 'PRV' THEN cPO.Providers ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'CH' THEN cPO.Charts WHEN 'OS' THEN PO.ProviderOfficeBucket_PK WHEN 'PRV' THEN cPO.Providers ELSE NULL END END DESC 
			) AS RowNumber
				,0 Project_PK,PO.ProviderOffice_PK,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode,PO.GroupName,PO.ContactPerson,PO.ContactNumber,PO.FaxNumber,PO.Email_Address,Isnull(PO.EMR_Type_PK,0) EMR_Type_PK
				,cPO.Providers
				,cPO.Charts
				,PO.ProviderOfficeBucket_PK OfficeStatus,cPO.FollowUpDate,cPO.LastContact
				,POAU.Lastname+IsNull(','+POAU.Firstname,'') AssignedScheduler,POAU.User_PK
			FROM #tmpOffices cPO WITH (NOLOCK)
				INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON cPO.ProviderOffice_PK=PO.ProviderOffice_PK 
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
				LEFT JOIN tblUser POAU WITH (NOLOCK) ON PO.AssignedUser_PK = POAU.User_PK

			WHERE IsNull(PO.Address,0) Like @Alpha+'%'
		)
	
		SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber
		
		IF @OFFICE=0
			SELECT UPPER(LEFT(PO.Address,1)) alpha1, UPPER(RIGHT(LEFT(PO.Address,2),1)) alpha2,Count(DISTINCT cPO.ProviderOffice_PK) records
			FROM #tmpOffices cPO WITH (NOLOCK)
				INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON cPO.ProviderOffice_PK=PO.ProviderOffice_PK 
			GROUP BY LEFT(PO.Address,1), RIGHT(LEFT(PO.Address,2),1)			
			ORDER BY alpha1, alpha2;
		ELSE
			SELECT TOP 0 0 alpha1, '' alpha2,0 records

	END
	ELSE
	BEGIN
		SELECT ROW_NUMBER() OVER(
			ORDER BY 
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'AD' THEN PO.Address WHEN 'CT' THEN ZC.City WHEN 'CN' THEN ZC.County WHEN 'ST' THEN ZC.State WHEN 'ZC' THEN ZC.Zipcode WHEN 'CP' THEN PO.ContactPerson WHEN 'GN' THEN PO.GroupName WHEN 'CNU' THEN PO.ContactNumber WHEN 'FN' THEN PO.FaxNumber ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'AD' THEN PO.Address WHEN 'CT' THEN ZC.City WHEN 'CN' THEN ZC.County WHEN 'ST' THEN ZC.State WHEN 'ZC' THEN ZC.Zipcode WHEN 'CP' THEN PO.ContactPerson WHEN 'GN' THEN PO.GroupName WHEN 'CNU' THEN PO.ContactNumber WHEN 'FN' THEN PO.FaxNumber ELSE NULL END END DESC,
				CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'CH' THEN cPO.Charts WHEN 'OS' THEN PO.ProviderOfficeBucket_PK WHEN 'PRV' THEN cPO.Providers ELSE NULL END END ASC,
				CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'CH' THEN cPO.Charts WHEN 'OS' THEN PO.ProviderOfficeBucket_PK WHEN 'PRV' THEN cPO.Providers ELSE NULL END END DESC 
			) AS [#]
				,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,PO.ContactPerson,PO.GroupName,PO.ContactNumber,PO.FaxNumber,PO.Email_Address,PO.EMR_Type,cPO.Providers,cPO.Charts
				,POB.Bucket [Office Status],FollowUpDate [Follow Up],cPO.LastContact [Last Contact]
				,IsNull(POAU.Lastname+IsNull(','+POAU.Firstname,''),'') AssignedScheduler
				,PO.LocationID [Location ID],cPO.ProviderOffice_PK ID
			FROM #tmpOffices cPO WITH (NOLOCK)
				INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON cPO.ProviderOffice_PK=PO.ProviderOffice_PK 
				INNER JOIN tblProviderOfficeBucket POB WITH (NOLOCK) ON POB.ProviderOfficeBucket_PK=PO.ProviderOfficeBucket_PK
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
				LEFT JOIN tblUser POAU WITH (NOLOCK) ON PO.AssignedUser_PK = POAU.User_PK
			WHERE IsNull(PO.Address,0) Like @Alpha+'%'
	END
END
GO
