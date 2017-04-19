SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 04/03/2017
-- Description:	Data Vault FHN Provider satelites Load 
-- =============================================
CREATE PROCEDURE [dbo].[spDV_FHN_LoadSats]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

--**S_PROVIDERDEMO LOAD


        INSERT  INTO dbo.S_ProviderDemo
                ( S_ProviderDemo_RK ,
                  LoadDate ,
                  H_Provider_RK ,
                  NPI ,
                  LastName ,
                  FirstName ,
                  HashDiff ,
                  RecordSource 
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(a.NPI, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.[Provider Name], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) ,
                        a.LoadDate ,
                        a.HashKey ,
                        a.NPI ,
                        CASE WHEN CHARINDEX(',', a.[Provider Name]) > 0 THEN LEFT(a.[Provider Name], CHARINDEX(',', a.[Provider Name]) - 1)
                             ELSE a.[Provider Name]
                        END ,
                        CASE WHEN CHARINDEX(',', a.[Provider Name]) > 0
                             THEN RIGHT(a.[Provider Name], LEN(a.[Provider Name]) - CHARINDEX(',', a.[Provider Name]) - 1)
                             ELSE ''
                        END ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.NPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.[Provider Name], '')))))), 2)) ,
                        a.FileName
                FROM    CHSStaging.dbo.FHN_Provider_Stage a
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.NPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.[Provider Name], '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_ProviderDemo
                        WHERE   H_Provider_RK = a.HashKey
                                AND RecordEndDate IS NULL )
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(a.NPI, ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(a.[Provider Name], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) ,
                        a.LoadDate ,
                        a.HashKey ,
                        a.NPI ,
                        CASE WHEN CHARINDEX(',', a.[Provider Name]) > 0 THEN LEFT(a.[Provider Name], CHARINDEX(',', a.[Provider Name]) - 1)
                             ELSE a.[Provider Name]
                        END ,
                        CASE WHEN CHARINDEX(',', a.[Provider Name]) > 0
                             THEN RIGHT(a.[Provider Name], LEN(a.[Provider Name]) - CHARINDEX(',', a.[Provider Name]) - 1)
                             ELSE ''
                        END ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.NPI, ''))), ':', RTRIM(LTRIM(COALESCE(a.[Provider Name], '')))))), 2)) ,
                        a.FileName;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_ProviderDemo
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_ProviderDemo z
                                  WHERE     z.H_Provider_RK = a.H_Provider_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_ProviderDemo a
        WHERE   a.RecordEndDate IS NULL; 

	
			--History Table
        IF ( SELECT COUNT(*)
             FROM   dbo.TableNames
             WHERE  TableName = 'S_ProviderDemo'
           ) = 0
            INSERT  INTO dbo.TableNames
                    ( TableName, CreateDate )
            VALUES  ( 'S_ProviderDemo', GETDATE() );


--Load History Table for S_ProviderDemo
        INSERT  INTO LoadHistory2
                ( TableName_PK ,
                  HashKey ,
                  RecordSource_PK
                )
                SELECT	DISTINCT
                        ( SELECT    TableName_PK
                          FROM      TableNames
                          WHERE     TableName = 'S_ProviderDemo'
                        ) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':', RTRIM(LTRIM(COALESCE(a.NPI, ''))),
                                                                       ':', RTRIM(LTRIM(COALESCE(a.[Provider Name], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.LoadDate, '')))))), 2)) ,
                        ( SELECT    RecordSource_PK
                          FROM      RecordSources
                          WHERE     RecordSource = a.FileName
                        )
                FROM    CHSStaging.dbo.FHN_Provider_Stage a;
		





--*** Insert Into S_Location
        INSERT  INTO [dbo].[S_Location]
                ( [S_Location_RK] ,
                  [LoadDate] ,
                  [H_Location_RK] ,
                  [Address1] ,
                  City ,
                  State ,
                  [Zip] ,
                  County ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE(a.City, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[County], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE(a.City, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], '')))))), 2)) ,
                        RTRIM(LTRIM(COALESCE(a.[Address], ''))) AS [Address] ,
                        RTRIM(LTRIM(COALESCE(a.City, ''))) ,
                        RTRIM(LTRIM(COALESCE(a.[State], ''))) ,
                        RTRIM(LTRIM(COALESCE(a.[Zip Code], ''))) AS ZipCode ,
                        RTRIM(LTRIM(COALESCE(a.[County], ''))) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE(a.City, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[County], '')))))), 2)) ,
                        a.FileName
                FROM    CHSStaging.dbo.FHN_Provider_Stage a
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE(a.City, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[County], '')))))), 2)) NOT IN ( SELECT   HashDiff
                                                                                                                               FROM     S_Location
                                                                                                                               WHERE    RecordEndDate IS NULL )
                        AND UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE(a.City, ''))), ':',
                                                                           RTRIM(LTRIM(COALESCE(a.[State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], ''))),
                                                                           ':', RTRIM(LTRIM(COALESCE(a.[County], '')))))), 2)) NOT IN ( SELECT  S_Location_RK
                                                                                                                                        FROM    dbo.S_Location )
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE(a.City, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], ''))),
                                                                        ':', RTRIM(LTRIM(COALESCE(a.[County], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE(a.City, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], '')))))), 2)) ,
                        RTRIM(LTRIM(COALESCE(a.[Address], ''))) ,
                        RTRIM(LTRIM(COALESCE(a.City, ''))) ,
                        RTRIM(LTRIM(COALESCE(a.[State], ''))) ,
                        RTRIM(LTRIM(COALESCE(a.[Zip Code], ''))) ,
                        RTRIM(LTRIM(COALESCE(a.[County], ''))) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE(a.City, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[County], '')))))), 2)) ,
                        a.FileName;


--RECORD END DATE CLEANUP
        UPDATE  dbo.S_Location
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_Location z
                                  WHERE     z.H_Location_RK = a.H_Location_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_Location a
        WHERE   a.RecordEndDate IS NULL; 


			--History Table
        IF ( SELECT COUNT(*)
             FROM   dbo.TableNames
             WHERE  TableName = 'S_Location'
           ) = 0
            INSERT  INTO dbo.TableNames
                    ( TableName, CreateDate )
            VALUES  ( 'S_Location', GETDATE() );


--Load History Table for S_Location

        INSERT  INTO LoadHistory2
                ( TableName_PK ,
                  HashKey ,
                  RecordSource_PK
                )
                SELECT	DISTINCT
                        ( SELECT    TableName_PK
                          FROM      TableNames
                          WHERE     TableName = 'S_Location'
                        ) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE(a.City, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[County], '')))))), 2)) ,
                        ( SELECT    RecordSource_PK
                          FROM      RecordSources
                          WHERE     RecordSource = a.FileName
                        )
                FROM    CHSStaging.dbo.FHN_Provider_Stage a;
			
--**** INSERT S_CONTACT
        INSERT  INTO [dbo].[S_Contact]
                ( [S_Contact_RK] ,
                  [LoadDate] ,
                  H_Contact_RK ,
                  [Phone] ,
                  [Fax] ,
                  [HashDiff] ,
                  [RecordSource]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Phone, ''))), ':', RTRIM(LTRIM(COALESCE(a.Fax, '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Phone, ''))), ':', RTRIM(LTRIM(COALESCE(a.Fax, '')))))), 2)) ,
                        RTRIM(LTRIM(COALESCE(a.Phone, ''))) AS Phone ,
                        RTRIM(LTRIM(COALESCE(a.Fax, ''))) AS Fax ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Phone, ''))), ':', RTRIM(LTRIM(COALESCE(a.Fax, '')))))), 2)) ,
                        a.FileName
                FROM    CHSStaging.dbo.FHN_Provider_Stage a
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Phone, ''))), ':', RTRIM(LTRIM(COALESCE(a.Fax, '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Contact
                        WHERE   RecordEndDate IS NULL )
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Phone, ''))), ':', RTRIM(LTRIM(COALESCE(a.Fax, '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Phone, ''))), ':', RTRIM(LTRIM(COALESCE(a.Fax, '')))))), 2)) ,
                        RTRIM(LTRIM(COALESCE(a.Phone, ''))) ,
                        RTRIM(LTRIM(COALESCE(a.Fax, ''))) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Phone, ''))), ':', RTRIM(LTRIM(COALESCE(a.Fax, '')))))), 2)) ,
                        a.FileName;


		
--RECORD END DATE CLEANUP
        UPDATE  dbo.S_Contact
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_Contact z
                                  WHERE     z.H_Contact_RK = a.H_Contact_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_Contact a
        WHERE   a.RecordEndDate IS NULL; 


				--History Table
        IF ( SELECT COUNT(*)
             FROM   dbo.TableNames
             WHERE  TableName = 'S_Contact'
           ) = 0
            INSERT  INTO dbo.TableNames
                    ( TableName, CreateDate )
            VALUES  ( 'S_Contact', GETDATE() );


--Load History Table for S_Contact

        INSERT  INTO LoadHistory2
                ( TableName_PK ,
                  HashKey ,
                  RecordSource_PK
                )
                SELECT	DISTINCT
                        ( SELECT    TableName_PK
                          FROM      TableNames
                          WHERE     TableName = 'S_Contact'
                        ) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Phone, ''))), ':', RTRIM(LTRIM(COALESCE(a.Fax, '')))))), 2)) ,
                        ( SELECT    RecordSource_PK
                          FROM      RecordSources
                          WHERE     RecordSource = a.FileName
                        )
                FROM    CHSStaging.dbo.FHN_Provider_Stage a;


--Load  [S_Specialty]
        INSERT  INTO [dbo].[S_Specialty]
                ( [S_Specialty_RK] ,
                  [LoadDate] ,
                  [H_Specialty_RK] ,
                  [SpecialtyDesc] ,
                  [HashDiff] ,
                  [RecordSource] 
		        )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Specialty Type Code], ''))),':',
																RTRIM(LTRIM(COALESCE(a.[Primary Specialty], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Specialty Type Code], ''))))), 2)) ,
                        a.[Primary Specialty] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Primary Specialty], ''))))), 2)) ,
                        a.FileName
                FROM    CHSStaging.dbo.FHN_Provider_Stage a
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Primary Specialty], ''))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    dbo.S_Specialty
                        WHERE   RecordEndDate IS NULL )
						AND UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Specialty Type Code], ''))),':',
																RTRIM(LTRIM(COALESCE(a.[Primary Specialty], '')))))), 2)) NOT IN (SELECT S_Specialty_RK FROM dbo.S_Specialty)
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Specialty Type Code], ''))),':',
																RTRIM(LTRIM(COALESCE(a.[Primary Specialty], '')))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Specialty Type Code], ''))))), 2)) ,
                        a.[Primary Specialty] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Primary Specialty], ''))))), 2)) ,
                        a.FileName;


--RECORD END DATE CLEANUP
        UPDATE  dbo.S_Specialty
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_Specialty z
                                  WHERE     z.H_Specialty_RK = a.H_Specialty_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_Specialty a
        WHERE   a.RecordEndDate IS NULL; 


				--History Table
        IF ( SELECT COUNT(*)
             FROM   dbo.TableNames
             WHERE  TableName = 'S_Specialty'
           ) = 0
            INSERT  INTO dbo.TableNames
                    ( TableName, CreateDate )
            VALUES  ( 'S_Specialty', GETDATE() );

			
--Load History Table for S_Specialty

        INSERT  INTO LoadHistory2
                ( TableName_PK ,
                  HashKey ,
                  RecordSource_PK
                )
                SELECT	DISTINCT
                        ( SELECT    TableName_PK
                          FROM      TableNames
                          WHERE     TableName = 'S_Specialty'
                        ) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Specialty Type Code], ''))),':',
																RTRIM(LTRIM(COALESCE(a.[Primary Specialty], '')))))), 2)) ,
                        ( SELECT    RecordSource_PK
                          FROM      RecordSources
                          WHERE     RecordSource = a.FileName
                        )
                FROM    CHSStaging.dbo.FHN_Provider_Stage a;


--Load S_Network 


        INSERT  INTO dbo.S_Network
                ( S_Network_RK ,
                  H_Network_RK ,
                  Name ,
                  NPI ,
                  LoadDate ,
                  RecordSource ,
                  HashDiff 
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Network Name], ''))),':',
															RTRIM(LTRIM(COALESCE(a.[Report To ID], '')))))), 2)) ,
                        b.NetworkHashKey ,
                        a.[Network Name] ,
                        '' ,
                        a.LoadDate ,
                        a.FileName ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Network Name], ''))))), 2))
                FROM    CHSStaging.dbo.FHN_Provider_Stage a
                        INNER JOIN CHSDV.dbo.R_Network b ON a.CentauriNetworkID = b.CentauriNetworkID
                                                            AND b.ClientID = 100002

                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Network Name], ''))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    dbo.S_Network
                        WHERE   RecordEndDate IS NULL )
						AND UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Network Name], ''))),':',
															RTRIM(LTRIM(COALESCE(a.[Report To ID], '')))))), 2)) NOT IN (SELECT S_Network_RK FROM dbo.S_Network )
						
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Network Name], ''))),':',
															RTRIM(LTRIM(COALESCE(a.[Report To ID], '')))))), 2)) ,
                        b.NetworkHashKey ,
                        a.[Network Name] ,
                        a.LoadDate ,
                        a.FileName ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Network Name], ''))))), 2));


--RECORD END DATE CLEANUP
        UPDATE  dbo.S_Network
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_Network z
                                  WHERE     z.H_Network_RK = a.H_Network_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_Network a
        WHERE   a.RecordEndDate IS NULL; 


	--History Table
        IF ( SELECT COUNT(*)
             FROM   dbo.TableNames
             WHERE  TableName = 'S_Network'
           ) = 0
            INSERT  INTO dbo.TableNames
                    ( TableName, CreateDate )
            VALUES  ( 'S_Network', GETDATE() );


--Load History Table for S_Network

        INSERT  INTO LoadHistory2
                ( TableName_PK ,
                  HashKey ,
                  RecordSource_PK
                )
                SELECT	DISTINCT
                        ( SELECT    TableName_PK
                          FROM      TableNames
                          WHERE     TableName = 'S_Network'
                        ) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Network Name], ''))),':',
																	RTRIM(LTRIM(COALESCE(a.[Report To ID], '')))))), 2)) ,
                        ( SELECT    RecordSource_PK
                          FROM      RecordSources
                          WHERE     RecordSource = a.FileName
                        )
                FROM    CHSStaging.dbo.FHN_Provider_Stage a;
			
--Load  [S_Type]
        INSERT  INTO [dbo].[S_Type]
                ( [S_Type_RK] ,
                  [LoadDate] ,
                  [H_Type_RK] ,
                  [TypeDesc] ,
                  [HashDiff] ,
                  [RecordSource] 
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[ProviderType Description], ''))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Provider Type Code], ''))))), 2)) ,
                        a.[ProviderType Description] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[ProviderType Description], ''))))), 2)) ,
                        a.FileName
                FROM    CHSStaging.dbo.FHN_Provider_Stage a
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[ProviderType Description], ''))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    dbo.S_Type
                        WHERE   RecordEndDate IS NULL )
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[ProviderType Description], ''))))), 2)) ,
                        a.LoadDate ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Provider Type Code], ''))))), 2)) ,
                        a.[ProviderType Description] ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[ProviderType Description], ''))))), 2)) ,
                        a.FileName;


--RECORD END DATE CLEANUP
        UPDATE  dbo.S_Type
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_Type z
                                  WHERE     z.H_Type_RK = a.H_Type_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_Type a
        WHERE   a.RecordEndDate IS NULL; 

			--History Table
        IF ( SELECT COUNT(*)
             FROM   dbo.TableNames
             WHERE  TableName = 'S_Type'
           ) = 0
            INSERT  INTO dbo.TableNames
                    ( TableName, CreateDate )
            VALUES  ( 'S_Type', GETDATE() );


--Load History Table for S_Type

        INSERT  INTO LoadHistory2
                ( TableName_PK ,
                  HashKey ,
                  RecordSource_PK
                )
                SELECT	DISTINCT
                        ( SELECT    TableName_PK
                          FROM      TableNames
                          WHERE     TableName = 'S_Type'
                        ) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[ProviderType Description], ''))))), 2)) ,
                        ( SELECT    RecordSource_PK
                          FROM      RecordSources
                          WHERE     RecordSource = a.FileName
                        )
                FROM    CHSStaging.dbo.FHN_Provider_Stage a;

    END;


GO
