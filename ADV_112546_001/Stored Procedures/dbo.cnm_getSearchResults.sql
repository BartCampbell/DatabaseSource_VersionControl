SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cnm_getSearchResults 301,'1'
Create PROCEDURE [dbo].[cnm_getSearchResults] 
	@search_type int,
	@search_value varchar(1000)
AS
BEGIN
	IF (@search_type>100 AND @search_type<200)
	BEGIN
		-- 101 Provider Office Address</option>
		-- 102 Office Location ID</option>
		-- 103 Phone Number</option>
		-- 104 Fax Number</option>   
		SELECT ROW_NUMBER() OVER(ORDER BY PO.Address ASC) AS RowNumber,
				PO.ProviderOffice_PK,PO.LocationID,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,PO.ContactNumber,PO.FaxNumber
				,Count(DISTINCT S.Provider_PK) Providers
				,Count(DISTINCT S.Suspect_PK) Charts
			FROM tblProviderOffice PO WITH (NOLOCK) 
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
			--WHERE Address Like '%'+@search_value+'%'
		WHERE 
			(@search_type=101 AND PO.Address Like '%'+@search_value+'%') OR
			(@search_type=102 AND PO.LocationID Like '%'+@search_value+'%') OR
			(@search_type=103 AND PO.ContactNumber Like '%'+@search_value+'%') OR
			(@search_type=104 AND PO.FaxNumber Like '%'+@search_value+'%')
		GROUP BY PO.ProviderOffice_PK,PO.LocationID,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,PO.ContactNumber,PO.FaxNumber
	END
	ELSE IF (@search_type>200 AND @search_type<300)
	BEGIN
        --201	Provider Group
        --202	Provider ID
        --203	Provider NPI
        --204	Provider Name
		SELECT ROW_NUMBER() OVER(ORDER BY PM.Lastname+IsNull(', '+PM.Firstname,'') ASC) AS RowNumber,
				PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,PM.NPI,PM.PIN [Plan Provider ID]
				,S.Provider_PK,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,PM.ProviderGroup
				,Count(DISTINCT S.Suspect_PK) Charts
			FROM tblProviderOffice PO WITH (NOLOCK) 
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
		WHERE 
			(@search_type=201 AND PM.ProviderGroup Like '%'+@search_value+'%') OR
			(@search_type=202 AND PM.Provider_ID Like '%'+@search_value+'%') OR
			(@search_type=203 AND PM.NPI Like '%'+@search_value+'%') OR
			(@search_type=204 AND PM.Lastname+IsNull(' '+PM.Firstname,'') Like '%'+@search_value+'%') OR
			(@search_type=205 AND PM.PIN Like '%'+@search_value+'%')
		GROUP BY PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,''),PM.NPI,PM.PIN
				,S.Provider_PK,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,PM.ProviderGroup
	END
	ELSE IF (@search_type>300 AND @search_type<400)
	BEGIN
		--301	Member ID
		--302	Member Name
		--303	HIC NUmber
		--304	Chase ID
		SELECT ROW_NUMBER() OVER(ORDER BY M.Lastname+IsNull(', '+M.Firstname,'') ASC) AS RowNumber,
				S.ChaseID,M.Member_ID,M.HICNumber,M.Lastname+IsNull(', '+M.Firstname,'') Member
				,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,PM.NPI,PM.PIN [Plan Provider ID]
				,S.Suspect_PK,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode
				,C.Channel_Name Channel
			FROM tblProviderOffice PO WITH (NOLOCK) 
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
				INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK		
				LEFT JOIN tblChannel C WITH (NOLOCK) ON C.Channel_PK = S.Channel_PK
		WHERE 
			(@search_type=301 AND M.Member_ID Like '%'+@search_value+'%') OR
			(@search_type=302 AND M.Lastname+IsNull(' '+M.Firstname,'') Like '%'+@search_value+'%') OR
			(@search_type=303 AND M.HICNumber Like '%'+@search_value+'%') OR
			(@search_type=304 AND S.ChaseID Like '%'+@search_value+'%')

	END
END
GO
