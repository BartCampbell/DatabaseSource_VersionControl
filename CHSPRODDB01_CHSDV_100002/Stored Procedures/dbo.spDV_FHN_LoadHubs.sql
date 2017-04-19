SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 04/03/2017
-- Description:	Load Hubs for FHN Providers
-- =============================================
CREATE PROCEDURE [dbo].[spDV_FHN_LoadHubs]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO dbo.RecordSources
	        ( RecordSource ,
	          LoadDate ,
	          CreateDate
	        )
	SELECT DISTINCT a.Filename ,a.LoadDate,GETDATE() FROM CHSStaging.dbo.FHN_Provider_Stage a LEFT OUTER JOIN dbo.RecordSources b ON a.FileName=b.RecordSource WHERE b.RecordSource_PK IS null

--** LOAD H_PROVIDER
INSERT INTO [dbo].[H_Provider]
           ([H_Provider_RK]
           ,[Provider_BK]
           ,[ClientProviderID]
           ,[RecordSource]
           ,[LoadDate])
	SELECT 
		DISTINCT HashKey, CentauriProviderID, '',FileName,LoadDate
	 FROM   CHSStaging.dbo.FHN_Provider_Stage
	WHERE HashKey not in (Select H_Provider_RK from H_Provider)
		


--** LOAD H_Contact 
INSERT INTO [dbo].[H_Contact]
           ([H_Contact_RK]
           ,[Contact_BK]
           ,[RecordSource]
           ,[LoadDate])
	SELECT 
	UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
		UPPER(CONCAT(
		RTRIM(LTRIM(COALESCE(a.[Phone],''))),':',
		RTRIM(LTRIM(COALESCE(a.[Fax],'')))
		))),2)),
	CONCAT(RTRIM(LTRIM(COALESCE(a.[Phone],''))),RTRIM(LTRIM(COALESCE(a.[Fax],'')))),
	a.Filename,
	a.LoadDate
	  FROM CHSStaging.dbo.FHN_Provider_Stage a
	  WHERE 
	UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
		UPPER(CONCAT(
		RTRIM(LTRIM(COALESCE(a.[Phone],''))),':',
RTRIM(LTRIM(COALESCE(a.[Fax],'')))))),2))
		NOT IN (SELECT H_Contact_RK FROM H_Contact)
	
		GROUP BY 
		UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
		UPPER(CONCAT(
		RTRIM(LTRIM(COALESCE(a.[Phone],''))),':',
		RTRIM(LTRIM(COALESCE(a.[Fax],'')))
		))),2)),
	CONCAT(RTRIM(LTRIM(COALESCE(a.[Phone],''))),RTRIM(LTRIM(COALESCE(a.[Fax],'')))),
	a.Filename,
	a.LoadDate


--** LOAD H_Location 
	INSERT INTO dbo.H_Location
	        ( H_Location_RK ,
	          Location_BK ,
	          LoadDate ,
	          RecordSource
	        )
	SELECT 
		UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
			UPPER(CONCAT(
				RTRIM(LTRIM(COALESCE(a.[Address],''))),':',
				 RTRIM(LTRIM(COALESCE([City],''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(a.[Zip Code],'')))
				))),2)),
				CONCAT(RTRIM(LTRIM(COALESCE(a.[Address],''))),RTRIM(LTRIM(COALESCE([City],''))),RTRIM(LTRIM(COALESCE([State],''))),RTRIM(LTRIM(COALESCE(a.[Zip Code],'')))),				
				a.LoadDate,
				a.FileName
		FROM CHSStaging.dbo.FHN_Provider_Stage a 
		WHERE 
		UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
			UPPER(CONCAT(
				RTRIM(LTRIM(COALESCE(a.[Address],''))),':',
				 RTRIM(LTRIM(COALESCE([City],''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(a.[Zip Code],'')))
				))),2)) NOT IN (SELECT H_Location_RK FROM H_Location)
		GROUP BY
		UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
			UPPER(CONCAT(
				RTRIM(LTRIM(COALESCE(a.[Address],''))),':',
				 RTRIM(LTRIM(COALESCE([City],''))),':',
				RTRIM(LTRIM(COALESCE([State],''))),':',
				RTRIM(LTRIM(COALESCE(a.[Zip Code],'')))
				))),2)),
				CONCAT(RTRIM(LTRIM(COALESCE(a.[Address],''))),RTRIM(LTRIM(COALESCE([City],''))),RTRIM(LTRIM(COALESCE([State],''))),RTRIM(LTRIM(COALESCE(a.[Zip Code],'')))),				
				a.LoadDate,
				a.FileName

		
--Load H_Specialty
		INSERT INTO dbo.H_Specialty
		        ( H_Specialty_RK ,
		          SpecialtyCode_BK ,
		          LoadDate ,
		          RecordSource
		        )
		SELECT UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Specialty Type Code]	, ''))))),2)) ,
		a.[Specialty Type Code]		,
				a.LoadDate,
				a.FileName

		FROM CHSStaging.dbo.FHN_Provider_Stage a 
		WHERE UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Specialty Type Code]	, ''))))),2)) NOT IN 
			(SELECT H_Specialty_RK  FROM dbo.H_Specialty)
			GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Specialty Type Code]	, ''))))),2)) ,
		a.[Specialty Type Code]		,
				a.LoadDate,
				a.FileName;

				
--Load H_Network


		INSERT INTO dbo.H_Network
		        ( H_Network_RK ,
		          Network_BK ,
		          ClientNetworkID ,
		          RecordSource ,
		          LoadDate
		        )
		SELECT DISTINCT b.NetworkHashKey ,
				b.CentauriNetworkID,
				a.[Report To ID],
				a.FileName,
				a.LoadDate
		FROM CHSStaging.dbo.FHN_Provider_Stage a 
			INNER JOIN CHSDV.dbo.R_Network b ON a.CentauriNetworkID=b.CentauriNetworkID AND b.ClientID=100002
			LEFT OUTER JOIN dbo.H_Network n ON b.NetworkHashKey=n.H_Network_RK
		WHERE n.H_Network_RK IS NULL

		

--Load H_ProviderType
		INSERT INTO dbo.H_Type
		        ( H_Type_RK ,
		          TypeCode_BK ,
		          LoadDate ,
		          RecordSource
		        )
		
		SELECT UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Provider Type Code]	, ''))))),2)) ,
		a.[Provider Type Code]		,
				a.LoadDate,
				a.FileName

		FROM CHSStaging.dbo.FHN_Provider_Stage a 
		WHERE UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Provider Type Code]	, ''))))),2)) NOT IN 
			(SELECT H_Type_RK  FROM dbo.H_Type)
			GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Provider Type Code]	, ''))))),2)) ,
		a.[Provider Type Code]		,
				a.LoadDate,
				a.FileName;




END

GO
