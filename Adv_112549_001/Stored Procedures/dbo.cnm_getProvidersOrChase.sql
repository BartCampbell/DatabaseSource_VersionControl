SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cnm_getProvidersOrChase 1,0,1
Create PROCEDURE [dbo].[cnm_getProvidersOrChase] 
	@office int,
	@provider int,
	@providerList int 
AS
BEGIN
	IF (@providerList=1)
	BEGIN
		SELECT ROW_NUMBER() OVER(ORDER BY PM.Lastname+IsNull(', '+PM.Firstname,'') ASC) AS RowNumber,
				PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,PM.NPI,PM.PIN [Plan Provider ID]
				,S.Provider_PK,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,PM.ProviderGroup
				,Count(DISTINCT S.Suspect_PK) Charts
			FROM tblProviderOffice PO WITH (NOLOCK) 
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
		WHERE PO.ProviderOffice_PK = @office
		GROUP BY PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,''),PM.NPI,PM.PIN
				,S.Provider_PK,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,PM.ProviderGroup
	END
	ELSE
	BEGIN
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
		WHERE (@office>0 AND PO.ProviderOffice_PK = @office) OR 
			(@provider>0 AND P.Provider_PK = @provider)
	END
END
GO
