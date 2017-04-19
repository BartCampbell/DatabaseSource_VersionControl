SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
-- ============================================= 
-- Author:		Paul Johnson 
-- Create date: 04/03/2017
-- Description:	Load all Link Tables from the Provider tables
-- ============================================= 
CREATE  PROCEDURE [dbo].[spDV_FHN_LoadLinks] 
	-- Add the parameters for the stored procedure here 
AS
    BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from 
	-- interfering with SELECT statements. 
        SET NOCOUNT ON; 
 				 
 
--*** INSERT INTO L_ProviderLOCATION 
        INSERT  INTO [dbo].[L_ProviderLocation]
                ( [L_ProviderLocation_RK] ,
                  [H_Provider_RK] ,
                  [H_Location_RK] ,
                  [LoadDate] ,
                  [RecordSource] ,
                  [RecordEndDate]
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE([City], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE([State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], '')))))), 2)) ,
                        a.HashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE([City], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE([State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], '')))))), 2)) ,
                        a.LoadDate ,
                        a.FileName ,
                        NULL
                FROM    CHSStaging.dbo.FHN_Provider_Stage a
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE([City], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE([State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], '')))))), 2)) NOT IN (
                        SELECT  L_ProviderLocation_RK
                        FROM    L_ProviderLocation
                        WHERE   RecordEndDate IS NULL )
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                           UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE([City], ''))), ':',
                                                                        RTRIM(LTRIM(COALESCE([State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], '')))))), 2)) ,
                        a.HashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE([City], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE([State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], '')))))), 2)) ,
                        a.LoadDate ,
                        a.FileName;   



							--History Table
        IF ( SELECT COUNT(*)
             FROM   dbo.TableNames
             WHERE  TableName = 'L_ProviderLocation'
           ) = 0
            INSERT  INTO dbo.TableNames
                    ( TableName, CreateDate )
            VALUES  ( 'L_ProviderLocation', GETDATE() );


--Load History Table for L_ProviderLocation

        INSERT  INTO LoadHistory2
                ( TableName_PK ,
                  HashKey ,
                  RecordSource_PK
                )
                SELECT	DISTINCT
                        ( SELECT    TableName_PK
                          FROM      TableNames
                          WHERE     TableName = 'L_ProviderLocation'
                        ) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Address], ''))), ':', RTRIM(LTRIM(COALESCE([City], ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE([State], ''))), ':', RTRIM(LTRIM(COALESCE(a.[Zip Code], '')))))), 2)) ,
                        ( SELECT    RecordSource_PK
                          FROM      RecordSources
                          WHERE     RecordSource = a.FileName
                        )
                FROM    CHSStaging.dbo.FHN_Provider_Stage a;
		


 --Load L_ProviderContact

		INSERT INTO dbo.L_ProviderContact
		        ( L_ProviderContact_RK ,
		          H_Provider_RK ,
		          H_Contact_RK ,
		          LoadDate ,
		          RecordSource ,
		          RecordEndDate
		        )
		SELECT UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Phone], ''))), ':', RTRIM(LTRIM(COALESCE([a].[Fax], '')))
																	   ))), 2)) ,
                        a.HashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Phone], ''))), ':', RTRIM(LTRIM(COALESCE([a].[Fax], '')))
																	   ))), 2))  ,
                        a.LoadDate ,
                        a.FileName ,
                        NULL
                FROM    CHSStaging.dbo.FHN_Provider_Stage a
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Phone], ''))), ':', RTRIM(LTRIM(COALESCE([a].[Fax], '')))
																	   ))), 2))  NOT IN (
                        SELECT  L_ProviderContact_RK
							FROM    dbo.L_ProviderContact
                        WHERE   RecordEndDate IS NULL )
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Phone], ''))), ':', RTRIM(LTRIM(COALESCE([a].[Fax], '')))
																	   ))), 2)) ,
                        a.HashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.[Phone], ''))), ':', RTRIM(LTRIM(COALESCE([a].[Fax], '')))
																	   ))), 2))  ,
                        a.LoadDate ,
                        a.FileName;

											--History Table
        IF ( SELECT COUNT(*)
             FROM   dbo.TableNames
             WHERE  TableName = 'L_ProviderContact'
           ) = 0
            INSERT  INTO dbo.TableNames
                    ( TableName, CreateDate )
            VALUES  ( 'L_ProviderContact', GETDATE() );


--Load History Table for L_ProviderContact

        INSERT  INTO LoadHistory2
                ( TableName_PK ,
                  HashKey ,
                  RecordSource_PK
                )
                SELECT	DISTINCT
                        ( SELECT    TableName_PK
                          FROM      TableNames
                          WHERE     TableName = 'L_ProviderContact'
                        ) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Phone], ''))), ':', RTRIM(LTRIM(COALESCE([a].[Fax], '')))
																	   ))), 2)) ,
                        ( SELECT    RecordSource_PK
                          FROM      RecordSources
                          WHERE     RecordSource = a.FileName
                        )
                FROM    CHSStaging.dbo.FHN_Provider_Stage a;
		

		
 --Load L_ProviderNetwork

		INSERT INTO dbo.L_ProviderNetwork
		        ( L_ProviderNetwork_RK ,
		          H_Provider_RK ,
		          H_Network_RK ,
		          RecordSource ,
		          LoadDate
		        )
		SELECT UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.CentauriNetworkID, '')))
																	   ))), 2)) ,
                        a.HashKey ,
                        b.NetworkHashKey ,
                        a.FileName ,
                        a.LoadDate
                FROM CHSStaging.dbo.FHN_Provider_Stage a 
						INNER JOIN CHSDV.dbo.R_Network b ON a.CentauriNetworkID=b.CentauriNetworkID AND b.ClientID=100002
			    WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.CentauriNetworkID, '')))
																	   ))), 2))  NOT IN (
                        SELECT  L_ProviderNetwork_RK
							FROM    dbo.L_ProviderNetwork
                        WHERE   RecordEndDate IS NULL )
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.CentauriNetworkID, '')))
																	   ))), 2)) ,
                        a.HashKey ,
                        b.NetworkHashKey ,
                        a.FileName ,
                        a.LoadDate;

											--History Table
        IF ( SELECT COUNT(*)
             FROM   dbo.TableNames
             WHERE  TableName = 'L_ProviderNetwork'
           ) = 0
            INSERT  INTO dbo.TableNames
                    ( TableName, CreateDate )
            VALUES  ( 'L_ProviderNetwork', GETDATE() );


--Load History Table for L_ProviderNetwork

        INSERT  INTO LoadHistory2
                ( TableName_PK ,
                  HashKey ,
                  RecordSource_PK
                )
                SELECT	DISTINCT
                        ( SELECT    TableName_PK
                          FROM      TableNames
                          WHERE     TableName = 'L_ProviderNetwork'
                        ) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.CentauriNetworkID, '')))
																	   ))), 2)) ,
                        ( SELECT    RecordSource_PK
                          FROM      RecordSources
                          WHERE     RecordSource = a.FileName
                        )
                FROM    CHSStaging.dbo.FHN_Provider_Stage a;


	
 --Load L_ProviderSpecialty

		INSERT INTO dbo.L_ProviderSpecialty
		        ( L_ProviderSpecialty_RK ,
		          H_Provider_RK ,
		          H_Specialty_RK ,
		          LoadDate ,
		          RecordSource	         
		        )
		SELECT UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Specialty Type Code], '')))
																	   ))), 2)) ,
                        a.HashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Specialty Type Code]	, ''))))),2)) ,
                        a.LoadDate,
						a.FileName 
                FROM CHSStaging.dbo.FHN_Provider_Stage a 
				WHERE  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Specialty Type Code], '')))
																	   ))), 2))   NOT IN (
                        SELECT  L_ProviderSpecialty_RK
							FROM    dbo.L_ProviderSpecialty
                        WHERE   RecordEndDate IS NULL )
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Specialty Type Code], '')))
																	   ))), 2)) ,
                        a.HashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Specialty Type Code]	, ''))))),2)) ,
                        a.LoadDate,
						a.FileName ;

											--History Table
        IF ( SELECT COUNT(*)
             FROM   dbo.TableNames
             WHERE  TableName = 'L_ProviderSpecialty'
           ) = 0
            INSERT  INTO dbo.TableNames
                    ( TableName, CreateDate )
            VALUES  ( 'L_ProviderSpecialty', GETDATE() );


--Load History Table for L_ProviderSpecialty

        INSERT  INTO LoadHistory2
                ( TableName_PK ,
                  HashKey ,
                  RecordSource_PK
                )
                SELECT	DISTINCT
                        ( SELECT    TableName_PK
                          FROM      TableNames
                          WHERE     TableName = 'L_ProviderSpecialty'
                        ) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Specialty Type Code], '')))
																	   ))), 2)) ,
                        ( SELECT    RecordSource_PK
                          FROM      RecordSources
                          WHERE     RecordSource = a.FileName
                        )
                FROM    CHSStaging.dbo.FHN_Provider_Stage a;


				
 --Load L_ProviderType

		INSERT INTO dbo.L_ProviderType
		        ( L_ProviderType_RK ,
		          H_Provider_RK ,
		          H_Type_RK ,
		          LoadDate ,
		          RecordSource  )
		SELECT UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Provider Type Code], '')))
																	   ))), 2)) ,
                        a.HashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Provider Type Code]	, ''))))),2)) ,
                        a.LoadDate,
						a.FileName 
                FROM CHSStaging.dbo.FHN_Provider_Stage a 
				WHERE  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Provider Type Code], '')))
																	   ))), 2))  NOT IN (
                        SELECT  L_ProviderType_RK
							FROM    dbo.L_ProviderType
                        WHERE   RecordEndDate IS NULL )
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Provider Type Code], '')))
																	   ))), 2)) ,
                        a.HashKey ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(a.[Provider Type Code]	, ''))))),2)) ,
                        a.LoadDate,
						a.FileName  ;

											--History Table
        IF ( SELECT COUNT(*)
             FROM   dbo.TableNames
             WHERE  TableName = 'L_ProviderType'
           ) = 0
            INSERT  INTO dbo.TableNames
                    ( TableName, CreateDate )
            VALUES  ( 'L_ProviderType', GETDATE() );


--Load History Table for L_ProviderType

        INSERT  INTO LoadHistory2
                ( TableName_PK ,
                  HashKey ,
                  RecordSource_PK
                )
                SELECT	DISTINCT
                        ( SELECT    TableName_PK
                          FROM      TableNames
                          WHERE     TableName = 'L_ProviderType'
                        ) ,
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.CentauriProviderID, ''))), ':',
                                                                       RTRIM(LTRIM(COALESCE(a.[Provider Type Code], '')))
																	   ))), 2)) ,
                        ( SELECT    RecordSource_PK
                          FROM      RecordSources
                          WHERE     RecordSource = a.FileName
                        )
                FROM    CHSStaging.dbo.FHN_Provider_Stage a;

    END; 
 
 
GO
