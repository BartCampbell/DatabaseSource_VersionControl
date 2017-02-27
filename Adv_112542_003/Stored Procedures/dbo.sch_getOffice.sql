SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--[sch_getOffice] '0','0','0',1,50,'','AD','ASC',-1,0,1,0,0,0,0,101,''
--[sch_getOffice] '0','0','0',1,50,'','AD','ASC',-1,0,1,0,0,0,0,101,''
--	sch_getOffice @Projects='0', @ProjectGroup='0', @Page=1, @PageSize=100, @Alpha='', @Sort='', @Order='', @Provider=9, @bucket=0, @followup_bucket=0, @user=1, @scheduler=0, @PoolPK=0, @ZonePK=0, @OFFICE=0
CREATE PROCEDURE [dbo].[sch_getOffice] 
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4),
	@bucket int,
	@followup_bucket tinyint,
	@user int,
	@scheduler int,
	@PoolPK int,
	@ZonePK int,
	@OFFICE bigint,
	@search_type int,
	@search_value varchar(1000)
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

	DECLARE @IsScheduler AS BIT = 0
	DECLARE @IsSupervisor AS BIT = 0
	DECLARE @IsManager AS BIT = 0
	If (@search_value<>'') 
	BEGIN
		SET @scheduler = 0
		SET @PoolPK = 0;
		SET @ZonePK = 0;
		SET @bucket = -1;
		SET @followup_bucket=0;
		SET @IsManager=1
	END
	ELSE 
	BEGIN 
		SET @search_type=0
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
	SELECT PO.ProviderOffice_PK,COUNT(DISTINCT S.Provider_PK) Providers, COUNT(DISTINCT CASE WHEN IsScanned=0 AND IsCNA=0 THEN S.Suspect_PK ELSE NULL END) Charts,MAX(dtLastContact) LastContact,MAX(follow_up) FollowUpDate,Count(DISTINCT S.Project_PK) Offices 
		FROM tblProviderOffice PO WITH (NOLOCK)
		INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
		INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		LEFT JOIN tblZoneZipcode ZZC WITH (NOLOCK) ON ZZC.ZipCode_PK = PO.ZipCode_PK
		WHERE (@bucket=-1 OR PO.ProviderOfficeBucket_PK=@bucket)
			AND (@OFFICE=0 OR PO.ProviderOffice_PK=@OFFICE)
			AND (@PoolPK=0 OR PO.Pool_PK=@PoolPK)
			AND (@ZonePK=0 OR ZZC.Zone_PK=@ZonePK)
			AND (@scheduler=0 OR PO.AssignedUser_PK=@scheduler)
			AND (@followup_bucket=0 OR follow_up<=GetDate())
			AND (@search_type=0   OR
				(@search_type=101 AND PO.Address Like '%'+@search_value+'%') OR
				(@search_type=102 AND PO.LocationID Like '%'+@search_value+'%') OR
				(@search_type=103 AND PO.ContactNumber Like '%'+@search_value+'%') OR
				(@search_type=104 AND PO.FaxNumber Like '%'+@search_value+'%') OR
				(@search_type=105 AND S.PlanLID Like '%'+@search_value+'%') OR
				(@search_type=201 AND PM.ProviderGroup Like '%'+@search_value+'%') OR
				(@search_type=202 AND PM.Provider_ID Like '%'+@search_value+'%') OR
				(@search_type=203 AND PM.NPI Like '%'+@search_value+'%') OR
				(@search_type=204 AND PM.Lastname+IsNull(' '+PM.Firstname,'') Like '%'+@search_value+'%') OR
				(@search_type=205 AND PM.PIN Like '%'+@search_value+'%') OR
				(@search_type=301 AND M.Member_ID Like '%'+@search_value+'%') OR
				(@search_type=302 AND M.Lastname+IsNull(' '+M.Firstname,'') Like '%'+@search_value+'%') OR
				(@search_type=303 AND M.HICNumber Like '%'+@search_value+'%') OR
				(@search_type=304 AND S.ChaseID Like '%'+@search_value+'%')
			)
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
