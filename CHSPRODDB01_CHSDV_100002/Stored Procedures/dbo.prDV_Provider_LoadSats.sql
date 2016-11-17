SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 12/10/2015
-- Description:	Data Vault Provider Load
-- =============================================
CREATE PROCEDURE [dbo].[prDV_Provider_LoadSats]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--**S_PROVIDERDEMO LOAD
	INSERT INTO S_ProviderDemo
	(S_ProviderDemo_RK, LoadDate, H_Provider_RK, NPI, LastName, FirstName, HashDiff, RecordSource)
	SELECT
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.NPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProviderLastName,''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProviderFirstName,'')))
			))
			),2)),
	 LoadDate, 
	 ProviderHashKey,
	 NPI, 
	 ProviderLastName,
	 ProviderFirstName,
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.NPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProviderLastName,''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProviderFirstName,'')))
			))
			),2)),
	RecordSource
	FROM CHSStaging..Provider_Stage_Raw rw with(nolock)
	WHERE
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.NPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProviderLastName,''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProviderFirstName,'')))
			))
			),2))
	not in (SELECT HashDiff FROM S_ProviderDemo WHERE 
					H_Provider_RK = rw.ProviderHashKey and RecordEndDate is null )
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.NPI,''))),':',
			
			RTRIM(LTRIM(COALESCE(rw.ProviderLastName,''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProviderFirstName,'')))
			))
			),2)),
			LoadDate,
	 ProviderHashKey,
	 NPI, 
	 ProviderLastName,
	 ProviderFirstName,
	 upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.NPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProviderLastName,''))),':',
			RTRIM(LTRIM(COALESCE(rw.ProviderFirstName,'')))
			))
			),2)),
	RecordSource

	--RECORD END DATE CLEANUP
		UPDATE dbo.S_ProviderDemo set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_ProviderDemo z
			 Where
			  z.H_Provider_RK = a.H_Provider_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_ProviderDemo a
			Where a.RecordEndDate Is Null 

		

--*** Insert Into S_Type
	Insert into S_Type
		Select 
			upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
						RTRIM(LTRIM(COALESCE(ProviderTypeCode,''))),':',
						RTRIM(LTRIM(COALESCE(ProviderTypeDescription,'')))
					))
				),2)),
				LoadDate,
					upper(convert(char(32), HashBytes('MD5',
					Upper(
						RTRIM(LTRIM(COALESCE(ProviderTypeCode,''))
					))
				),2)),
				ProviderTypeDescription,
				upper(convert(char(32), HashBytes('MD5',
					Upper(
						RTRIM(LTRIM(COALESCE(ProviderTypeDescription,''))
					))
				),2)),
				RecordSource,
				Null		
		FROM CHSStaging..Provider_Stage_Raw rw with(nolock)
		where 
			upper(convert(char(32), HashBytes('MD5',
					Upper(
						RTRIM(LTRIM(COALESCE(ProviderTypeDescription,''))
					))
				),2)) not in (Select HashDiff from S_Type where RecordEndDate is null)

		GROUP BY
			upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
						RTRIM(LTRIM(COALESCE(ProviderTypeCode,''))),':',
						RTRIM(LTRIM(COALESCE(ProviderTypeDescription,'')))
					))
				),2)),
				LoadDate,
				upper(convert(char(32), HashBytes('MD5',
					Upper(
						RTRIM(LTRIM(COALESCE(ProviderTypeCode,''))
					))
				),2)),
				ProviderTypeDescription,
				upper(convert(char(32), HashBytes('MD5',
					Upper(
						RTRIM(LTRIM(COALESCE(ProviderTypeDescription,''))
					))
				),2)),
				RecordSource

--RECORD END DATE CLEANUP
		UPDATE dbo.S_Type set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_Type z
			 Where
			  z.H_Type_RK = a.H_Type_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_Type a
			Where a.RecordEndDate Is Null 

--*** Insert Into S_Specialty

	Insert into S_Specialty
		Select 
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
						RTRIM(LTRIM(COALESCE(SpecialtyTypeCode,''))),':',
						RTRIM(LTRIM(COALESCE(PrimarySpecialty,'')))
					))
				),2)),
				LoadDate, --LOAD DATE
				upper(convert(char(32), HashBytes('MD5',
					Upper(
						RTRIM(LTRIM(COALESCE(SpecialtyTypeCode,''))
					))
				),2)),
				
				PrimarySpecialty,
				upper(convert(char(32), HashBytes('MD5',
					Upper(
						RTRIM(LTRIM(COALESCE(PrimarySpecialty,''))
					))
				),2)),
				RecordSource,
				Null	
		FROM CHSStaging..Provider_Stage_Raw rw with(nolock)
		where 
			upper(convert(char(32), HashBytes('MD5',
					Upper(
						RTRIM(LTRIM(COALESCE(PrimarySpecialty,''))
					))
				),2)) not in (Select HashDiff from S_Specialty where RecordEndDate is null)

		GROUP BY
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
						RTRIM(LTRIM(COALESCE(SpecialtyTypeCode,''))),':',
						RTRIM(LTRIM(COALESCE(PrimarySpecialty,'')))
					))
				),2)),
				LoadDate,
					upper(convert(char(32), HashBytes('MD5',
					Upper(
						RTRIM(LTRIM(COALESCE(SpecialtyTypeCode,''))
					))
				),2)),
				
				PrimarySpecialty,
				upper(convert(char(32), HashBytes('MD5',
					Upper(
						RTRIM(LTRIM(COALESCE(PrimarySpecialty,''))
					))
				),2)),
				RecordSource

--RECORD END DATE CLEANUP
		UPDATE dbo.S_Specialty set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_Specialty z
			 Where
			  z.H_Specialty_RK = a.H_Specialty_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_Specialty a
			Where a.RecordEndDate Is Null 




--*** Insert Into S_Location
		Insert into S_Location
		Select
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(ZipCode,''))),':',
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(ZipCode,''))),':',
				RTRIM(LTRIM(COALESCE(County,'')))
				))
				),2)),
			LoadDate,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(ZipCode,'')))
				))
				),2)),
				Address1,
				Address2,
				City,
				[State],
				ZipCode,
				County,
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(ZipCode,''))),':',
					RTRIM(LTRIM(COALESCE(County,'')))
					))
				),2)),
				RecordSource,
				Null
		FROM CHSStaging..Provider_Stage_Raw rw WITH(NOLOCK)
		Where 
			upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(ZipCode,''))),':',
					RTRIM(LTRIM(COALESCE(County,'')))
					))
				),2)) not in (Select HashDiff from S_Location where RecordEndDate is null)
		GROUP BY
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(ZipCode,''))),':',
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(ZipCode,''))),':',
				RTRIM(LTRIM(COALESCE(County,'')))
				))
				),2)),
				LoadDate,
			upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(Address1,''))),':',
				RTRIM(LTRIM(COALESCE(Address2,''))),':',
				RTRIM(LTRIM(COALESCE(City,''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(ZipCode,'')))
				))
				),2)),
				Address1,
				Address2,
				City,
				[State],
				ZipCode,
				County,
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(ZipCode,''))),':',
					RTRIM(LTRIM(COALESCE(County,'')))
					))
				),2)),
				RecordSource

--RECORD END DATE CLEANUP
		UPDATE dbo.S_Location set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_Location z
			 Where
			  z.H_Location_RK = a.H_Location_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_Location a
			Where a.RecordEndDate Is Null 
			
--**** INSERT S_CONTACT

Insert into S_Contact
		Select 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))),':',
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		LoadDate,
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		rw.Phone, 
		rw.Mobile, 
		rw.Fax, 
		rw.Email,
		rw.URL,
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(Url,''))))
		)),2)),
		RecordSource,
		Null
	 FROM 
		CHSStaging..Provider_Stage_Raw rw
		where 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(Url,''))))
		)),2))
		not in (Select HashDiff from S_Contact where RecordEndDate is null)
	GROUP BY
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(Url,''))),':',
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(Url,''))))
		)),2)),
		LoadDate,
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(Url,''))))
		)),2)),
		rw.Phone, 
		rw.Mobile, 
		rw.Fax, 
		rw.Email,
		rw.URL,
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(Phone,''))),':',
				RTRIM(LTRIM(COALESCE(Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(Fax,''))),':',
				RTRIM(LTRIM(COALESCE(Email,''))),':',
				RTRIM(LTRIM(COALESCE(Url,''))))
		)),2)),
		RecordSource


		
--RECORD END DATE CLEANUP
		UPDATE dbo.S_Contact set
			RecordEndDate = (
			 Select 
			  DATEADD(ss,-1,Min(z.LoadDate))
			 From
			 dbo.S_Contact z
			 Where
			  z.H_Contact_RK = a.H_Contact_RK
			  and z.LoadDate > a.LoadDate
			  )
			FROM 
			 dbo.S_Contact a
			Where a.RecordEndDate Is Null 

END


GO
