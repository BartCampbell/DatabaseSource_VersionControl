SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/19/2016
-- Description:	Load all Hubs from the provider staging table.  based on CHSDV.[dbo].[prDV_Provider_LoadHubs]
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Provider_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** LOAD H_PROVIDER
INSERT INTO [dbo].[H_Provider]
           ([H_Provider_RK]
           ,[Provider_BK]
           ,[ClientProviderID]
           ,[RecordSource]
           ,[LoadDate])
	SELECT 
		DISTINCT ProviderHashKey, CPI, Provider_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblProviderStage
	WHERE
		ProviderHashKey not in (Select H_Provider_RK from H_Provider)
		AND CCI = @CCI

--** LOAD H_ProviderOfficeSchedule
INSERT INTO [dbo].[H_ProviderOfficeSchedule]
           ([H_ProviderOfficeSchedule_RK]
           ,[ProviderOfficeSchedule_BK]
           ,[ClientProviderOfficeScheduleID]
           ,[RecordSource]
           ,[LoadDate])
	SELECT 
		DISTINCT ProviderOfficeScheduleHashKey, CPI, ProviderOfficeSchedule_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblProviderOfficeScheduleStage
	WHERE
		ProviderOfficeScheduleHashKey not in (Select H_ProviderOfficeSchedule_RK from H_ProviderOfficeSchedule)
		AND CCI = @CCI

		--** LOAD H_ProviderOffice
INSERT INTO [dbo].[H_ProviderOffice]
           ([H_ProviderOffice_RK]
           ,[ProviderOffice_BK]
           ,[ClientProviderOfficeID]
           ,[RecordSource]
           ,[LoadDate])
	SELECT 
		DISTINCT ProviderOfficeHashKey, CPI, ProviderOffice_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblProviderOfficeStage
	WHERE
		ProviderOfficeHashKey not in (Select H_ProviderOffice_RK from H_ProviderOffice)
		AND CCI = @CCI


INSERT INTO [dbo].[H_ProviderMaster]
           ([H_ProviderMaster_RK]
           ,[ProviderMaster_BK]
           ,[ClientProviderMasterID]
           ,[RecordSource]
           ,[LoadDate])
	SELECT 
		DISTINCT ProviderMasterHashKey, CPI, ProviderMaster_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblProviderMasterStage
	WHERE
		ProviderMasterHashKey not in (Select H_ProviderMaster_RK from H_ProviderMaster)
		AND CCI = @CCI

--** LOAD H_CLIENT
INSERT INTO H_Client
	SELECT 
		DISTINCT ClientHashKey, CCI, Client, RecordSource,  LoadDate
	FROM 
		CHSStaging.adv.tblProviderStage
	WHERE
		ClientHashKey not in (Select H_Client_RK from H_Client)
			AND CCI = @CCI


--** LOAD H_Contact 
INSERT INTO [dbo].[H_Contact]
           ([H_Contact_RK]
           ,[Contact_BK]
           ,[RecordSource]
           ,[LoadDate])
	Select 
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(a.ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.Email_Address,''))))
		)),2)),
	Concat(RTRIM(LTRIM(COALESCE(a.ContactNumber,''))),RTRIM(LTRIM(COALESCE(a.FaxNumber,''))),RTRIM(LTRIM(COALESCE(a.Email_Address,'')))),
	a.RecordSource,
	a.LoadDate
	  FROM [CHSStaging].[adv].[tblProviderOfficeStage] a
				
		where 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
			RTRIM(LTRIM(COALESCE(a.ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.Email_Address,''))))
		)),2))
		not in (Select H_Contact_RK from H_Contact)
					AND a.CCI = @CCI
	GROUP BY
	upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(a.ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(a.Email_Address,''))))
		)),2)),
	Concat(RTRIM(LTRIM(COALESCE(a.ContactNumber,''))),RTRIM(LTRIM(COALESCE(a.FaxNumber,''))),RTRIM(LTRIM(COALESCE(a.Email_Address,'')))),
	a.LoadDate,
	a.RecordSource




--** LOAD H_Location 
	INSERT INTO H_Location
		Select 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
				RTRIM(LTRIM(COALESCE(a.[Address],''))),':',
				RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),'')))
				))
				),2)),
				Concat(RTRIM(LTRIM(COALESCE(a.[Address],''))),RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),'')))),				
				a.LoadDate,
				a.RecordSource
		FROM [CHSStaging].[adv].[tblProviderOfficeStage] a
		where 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE(a.[Address],''))),':',
					RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),'')))
				))
				),2)) not in (Select H_Location_RK from H_Location)
							AND a.CCI = @CCI
		GROUP BY
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE(a.[Address],''))),':',
					RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),'')))
				))
				),2)),
				Concat(RTRIM(LTRIM(COALESCE(a.[Address],''))),RTRIM(LTRIM(COALESCE(CAST(a.ZipCode_PK AS VARCHAR),'')))),
				a.LoadDate,			
				a.RecordSource

			


END



GO
