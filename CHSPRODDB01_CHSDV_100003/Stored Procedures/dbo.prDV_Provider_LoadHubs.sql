SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 12/11/2015
-- Description:	Load all Hubs from the provider staging table. 
-- =============================================
CREATE PROCEDURE [dbo].[prDV_Provider_LoadHubs]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** LOAD H_PROVIDER
INSERT INTO H_Provider
	SELECT 
		DISTINCT ProviderHashKey, CPI, RecordSource,LoadDate
	FROM 
		CHSStaging..Provider_Stage_Raw 
	WHERE
		ProviderHashKey not in (Select H_Provider_RK from H_Provider)
		
--** LOAD H_CLIENT
INSERT INTO H_Client
	SELECT 
		DISTINCT ClientHashKey, CCI, ClientName, RecordSource, LoadDate
	FROM 
		CHSStaging..Provider_Stage_Raw 
	WHERE
		ClientHashKey not in (Select H_Client_RK from H_Client)
	

--** LOAD H_NETWORK
INSERT INTO H_Network
	SELECT 
		DISTINCT NetworkHashKey , NetworkID, NetworkName, RecordSource, LoadDate	
	FROM 
		CHSStaging..Provider_Stage_Raw 
	WHERE
		NetworkHashKey not in (Select H_Network_RK from H_Network)

--** LOAD H_Specialty

	Insert into H_Specialty
	Select 
	upper(convert(char(32), HashBytes('MD5',
		Upper(RTRIM(LTRIM(COALESCE(SpecialtyTypeCode,''))))),2)),
	SpecialtyTypeCode,
	LoadDate,
	RecordSource
	 FROM 
		CHSStaging..Provider_Stage_Raw 
		where 
		upper(convert(char(32), HashBytes('MD5',
		Upper(RTRIM(LTRIM(COALESCE(SpecialtyTypeCode,''))))),2))
		not in (Select H_Specialty_RK from H_Specialty)
	GROUP BY
		upper(convert(char(32), HashBytes('MD5',
		Upper(RTRIM(LTRIM(COALESCE(SpecialtyTypeCode,''))))),2)),
	SpecialtyTypeCode,
	LoadDate,
	RecordSource

--** LOAD H_Contact 
	Insert into H_Contact
	Select 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(URL,''))))
		)),2)),
	Concat(Phone,
	Mobile, 
	Fax, 
	Email, 
	URL),
	LoadDate,
	RecordSource
	 FROM 
		CHSStaging..Provider_Stage_Raw rw
		where 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(URL,''))))
		)),2))
		not in (Select H_Contact_RK from H_Contact)
	GROUP BY
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(URL,''))))
		)),2)),
	Concat(Phone,
	Mobile, 
	Fax, 
	Email, 
	URL),
	LoadDate,
	RecordSource


--** LOAD H_Type
	Insert into H_Type
	Select 
	upper(convert(char(32), HashBytes('MD5',
		Upper(RTRIM(LTRIM(COALESCE(ProviderTypeCode,''))))),2)),
	ProviderTypeCode,
	LoadDate,
	RecordSource
	 FROM 
		CHSStaging..Provider_Stage_Raw 
		where
		upper(convert(char(32), HashBytes('MD5',
		Upper(RTRIM(LTRIM(COALESCE(ProviderTypeCode,''))))),2))
		not in (Select H_Type_RK from H_Type)
	GROUP BY
		upper(convert(char(32), HashBytes('MD5',
		Upper(RTRIM(LTRIM(COALESCE(ProviderTypeCode,''))))),2)),
	ProviderTypeCode,
	ProviderTypeDescription, 
	LoadDate,
	RecordSource

--** LOAD H_Location 
	INSERT INTO H_Location
		Select 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(ZipCode,'')))
				))
				),2)),
				Concat(Address1,
				Address2,
				City,
				[State],
				ZipCode),				
				LoadDate,
				RecordSource
		FROM CHSStaging..Provider_Stage_Raw
		where 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(ZipCode,'')))
				))
				),2)) not in (Select H_Location_RK from H_Location)
		GROUP BY
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(ZipCode,'')))
				))
				),2)),
				Concat(Address1,
				Address2,
				City,
				[State],
				ZipCode),	
				LoadDate,			
				RecordSource

			


END



GO
