SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/22/2016
-- Description:	Load all Hubs from the Vendor staging table.  
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Vendor_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** LOAD H_PROVIDER
INSERT INTO [dbo].[H_Vendor]
           ([H_Vendor_RK]
           ,[Vendor_BK]
           ,[ClientVendorID]
           ,[RecordSource]
           ,[LoadDate])
 
SELECT	DISTINCT VendorHashKey, CVI, Vendor_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblVendorStage
	WHERE
		VendorHashKey not in (Select H_Vendor_RK from H_Vendor)
		AND CCI = @CCI



--** LOAD H_CLIENT
INSERT INTO H_Client
	SELECT 
		DISTINCT ClientHashKey, CCI, Client, RecordSource,  LoadDate
	FROM 
		CHSStaging.adv.tblVendorStage
	WHERE
		ClientHashKey not in (Select H_Client_RK from H_Client)
			AND CCI = @CCI

			
--*** LOAD H_CONTACT
INSERT INTO [dbo].[H_Contact]
           ([H_Contact_RK]
           ,[Contact_BK]
           ,[RecordSource]
           ,[LoadDate])
 Select 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		Concat(rw.ContactNumber, rw.FaxNumber, rw.Email_Address),
			RecordSource,
		LoadDate 
	
	 FROM 
		CHSStaging.adv.tblVendorStage rw
		where 
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2))
		not in (Select H_Contact_RK from H_Contact)
		AND CCI= @CCI
	GROUP BY
		upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)),
		Concat(rw.ContactNumber, rw.FaxNumber, rw.Email_Address),
		LoadDate ,
		RecordSource


	---*** LOAD H_Location
	INSERT INTO H_Location
		Select 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
				))
				),2)),
			CONCAT(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
				),				
				LoadDate,
				RecordSource
		FROM CHSStaging.adv.tblVendorStage 
		where 
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
				))
				),2)) not in (Select H_Location_RK from H_Location)
				AND CCI= @CCI
		GROUP BY
		upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
				))
				),2)),
			CONCAT(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
				),	
				LoadDate ,			
				RecordSource



END



GO
