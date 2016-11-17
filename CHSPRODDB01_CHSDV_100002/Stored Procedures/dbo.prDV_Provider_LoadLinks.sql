SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks
-- Create date: 12/14/2015
-- Description:	Load all Link Tables from the provider staging raw table. 
-- =============================================
CREATE PROCEDURE [dbo].[prDV_Provider_LoadLinks]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
--** Load L_ProviderNetwork
	Insert into L_ProviderNetworkClient
	Select upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.NetworkID,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
			))
			),2)),
		rw.ProviderHashKey,
		rw.ClientHashKey,
		rw.NetworkHashKey,
		rw.RecordSource,
	 LoadDate, 
	 null
	 from CHSStaging..Provider_Stage_Raw rw
	 where upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.NetworkID,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
			))
			),2)) not in (Select L_ProviderNetworkClient_RK from L_ProviderNetworkClient where RecordEndDate is null)
	GROUP BY 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.NetworkID,''))),':',
			RTRIM(LTRIM(COALESCE(rw.CCI,'')))
			))
			),2)),
		rw.ProviderHashKey,
		rw.ClientHashKey,
		rw.NetworkHashKey,
		rw.RecordSource,
		rw.LoadDate



--*** INSERT INTO L_PROVIDERSPECIALTY

INSERT INTO L_ProviderSpecialty
Select 
upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.SpecialtyTypeCode,'')))
			))
			),2)),
			rw.ProviderHashKey, 
			upper(convert(char(32), HashBytes('MD5',
				Upper(
			RTRIM(LTRIM(COALESCE(rw.SpecialtyTypeCode,''))))
			),2)),
			LoadDate,
			RecordSource,
			Null
			FROM CHSStaging..Provider_Stage_Raw rw
			WHERE
						upper(convert(char(32), HashBytes('MD5',
						Upper(Concat(
						RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
						RTRIM(LTRIM(COALESCE(rw.SpecialtyTypeCode,'')))
						))
						),2)) not in (Select L_ProviderSpecialty_RK from L_ProviderSpecialty where RecordEndDate is null)

			GROUP BY
						upper(convert(char(32), HashBytes('MD5',
						Upper(Concat(
						RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
						RTRIM(LTRIM(COALESCE(rw.SpecialtyTypeCode,'')))
						))
						),2)),
						rw.ProviderHashKey,  
						upper(convert(char(32), HashBytes('MD5',
						Upper(
						RTRIM(LTRIM(COALESCE(rw.SpecialtyTypeCode,''))))
						),2)),
						rw.LoadDate,
						rw.RecordSource

					

--*** INSERT INTO L_PROVIDERLOCATION

		INSERT INTO L_ProviderLocation
			Select 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CPI,''))),':',
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(ZipCode,'')))
					))
				),2)),
				rw.ProviderHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(ZipCode,'')))
					))
				),2)),
				LoadDate,
				RecordSource,
				Null
			FROM CHSStaging..Provider_Stage_Raw rw
			WHERE
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CPI,''))),':',
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(ZipCode,'')))
					))
				),2)) not in (Select L_ProviderLocation_RK from L_ProviderLocation where RecordEndDate is null)
			GROUP BY
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(CPI,''))),':',
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(ZipCode,'')))
					))
				),2)),
				rw.ProviderHashKey, 
					upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(Address1,''))),':',
					RTRIM(LTRIM(COALESCE(Address2,''))),':',
					RTRIM(LTRIM(COALESCE(City,''))),':',
					RTRIM(LTRIM(COALESCE([State],''))),':',
					RTRIM(LTRIM(COALESCE(ZipCode,'')))
					))
				),2)),
				LoadDate,
				RecordSource


--*** INSERT INTO L_PROVIDERCONTACT

	
		INSERT INTO L_ProviderContact
			SELECT 
				upper(convert(char(32), HashBytes('MD5',
				Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Phone,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Fax,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Email,''))),':',
				RTRIM(LTRIM(COALESCE(rw.URL,'')))
				))
				),2)),
				rw.ProviderHashKey, 
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.Phone,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Mobile,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Fax,''))),':',
				RTRIM(LTRIM(COALESCE(rw.Email,''))),':',
				RTRIM(LTRIM(COALESCE(rw.URL,'')))
				))
				),2)),
				LoadDate,
				RecordSource,
				Null
			FROM CHSStaging..Provider_Stage_Raw rw
			WHERE
				upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
			RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
			RTRIM(LTRIM(COALESCE(rw.Phone,''))),':',
			RTRIM(LTRIM(COALESCE(rw.Mobile,''))),':',
			RTRIM(LTRIM(COALESCE(rw.Fax,''))),':',
			RTRIM(LTRIM(COALESCE(rw.Email,''))),':',
			RTRIM(LTRIM(COALESCE(rw.URL,'')))
			))
			),2)) not in (Select L_ProviderContact_RK from L_ProviderContact where RecordEndDate is null)

			GROUP BY
				upper(convert(char(32), HashBytes('MD5',
				Upper(Concat(
					RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
					RTRIM(LTRIM(COALESCE(rw.Phone,''))),':',
					RTRIM(LTRIM(COALESCE(rw.Mobile,''))),':',
					RTRIM(LTRIM(COALESCE(rw.Fax,''))),':',
					RTRIM(LTRIM(COALESCE(rw.Email,''))),':',
					RTRIM(LTRIM(COALESCE(rw.URL,'')))
					))
				),2)),
				rw.ProviderHashKey, 
				upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE(rw.Phone,''))),':',
					RTRIM(LTRIM(COALESCE(rw.Mobile,''))),':',
					RTRIM(LTRIM(COALESCE(rw.Fax,''))),':',
					RTRIM(LTRIM(COALESCE(rw.Email,''))),':',
					RTRIM(LTRIM(COALESCE(rw.URL,'')))
				))
				),2)),
				LoadDate,
				RecordSource


--*** INSERT INTO L_PROVIDERTYPE


		INSERT INTO L_ProviderType
			SELECT 
				upper(convert(char(32), HashBytes('MD5',
				Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
				RTRIM(LTRIM(COALESCE(rw.ProviderTypeCode,'')))
				))
				),2)),
				rw.ProviderHashKey, 
				upper(convert(char(32), HashBytes('MD5',
					Upper(
				RTRIM(LTRIM(COALESCE(rw.ProviderTypeCode,''))))
				),2)),
				LoadDate,			
				RecordSource,
				Null
			FROM CHSStaging..Provider_Stage_Raw rw
			WHERE
						upper(convert(char(32), HashBytes('MD5',
						Upper(Concat(
						RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
						RTRIM(LTRIM(COALESCE(rw.ProviderTypeCode,'')))
						))
						),2)) not in (Select L_ProviderType_RK from L_ProviderType where RecordEndDate is null)

			GROUP BY
				upper(convert(char(32), HashBytes('MD5',
				Upper(Concat(
				RTRIM(LTRIM(COALESCE(rw.CPI,''))),':',
				RTRIM(LTRIM(COALESCE(rw.ProviderTypeCode,'')))
				))
				),2)),
				rw.ProviderHashKey, 
				upper(convert(char(32), HashBytes('MD5',
					Upper(
				RTRIM(LTRIM(COALESCE(rw.ProviderTypeCode,''))))
				),2)),
				LoadDate,		
				RecordSource


END
GO
