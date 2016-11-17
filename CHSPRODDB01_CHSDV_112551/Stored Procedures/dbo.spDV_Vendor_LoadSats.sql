SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/25/2016
-- Description:	Data Vault Vendor Load 
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Vendor_LoadSats]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

--**S_VendorDEMO LOAD
   INSERT INTO [dbo].[S_VendorDemo]
           ([S_VendorDemo_RK]
           ,[LoadDate]
           ,[H_Vendor_RK]
           ,[Vendor_ID]
           ,[FirstName]
           ,[LastName]
           ,[ContactPerson]
           ,[HashDiff]
           ,[RecordSource]
           )
    
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CVI,
                                                              ''))), ':',
															       RTRIM(LTRIM(COALESCE(rw.[Vendor_ID],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Firstname],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Lastname],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[ContactPerson],
                                                                                                                     '')))))), 2)) ,
                        LoadDate ,
                        VendorHashKey ,
                       RTRIM(LTRIM([Vendor_ID]))
           ,RTRIM(LTRIM([FirstName]))
           ,RTRIM(LTRIM([LastName]))
           ,RTRIM(LTRIM([ContactPerson])),
                     
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT( RTRIM(LTRIM(COALESCE(rw.[Vendor_ID],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Firstname],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Lastname],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[ContactPerson],
                                                              '')))))), 2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblVendorStage rw WITH ( NOLOCK )
                WHERE   UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT( RTRIM(LTRIM(COALESCE(rw.[Vendor_ID],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Firstname],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Lastname],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[ContactPerson],
                                                              '')))))), 2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_VendorDemo
                        WHERE   H_Vendor_RK = rw.VendorHashKey
                                AND RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(rw.CVI,
                                                              ''))), ':',
															       RTRIM(LTRIM(COALESCE(rw.[Vendor_ID],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Firstname],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Lastname],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[ContactPerson],
                                                                                                                     '')))))), 2)) ,
                        LoadDate ,
                        VendorHashKey ,
                       RTRIM(LTRIM([Vendor_ID]))
           ,RTRIM(LTRIM([FirstName]))
           ,RTRIM(LTRIM([LastName]))
           ,RTRIM(LTRIM([ContactPerson])),
                     
                        UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT( RTRIM(LTRIM(COALESCE(rw.[Vendor_ID],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Firstname],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[Lastname],
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(rw.[ContactPerson],
                                                              '')))))), 2)) ,
                        RecordSource;

	--RECORD END DATE CLEANUP
        UPDATE  dbo.S_VendorDemo
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_VendorDemo z
                                  WHERE     z.H_Vendor_RK = a.H_Vendor_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_VendorDemo a
        WHERE   RecordEndDate IS NULL; 
	

    

--*** Insert into S_LOCATION

INSERT INTO [dbo].[S_Location]
           ([S_Location_RK]
           ,[LoadDate]
           ,[H_Location_RK]
           ,[Address1]
           ,[City]
           ,[State]
           ,[ZIP]
           ,[HashDiff]
           ,[RecordSource]
)

                SELECT  upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
					))
				),2)),
                        LoadDate ,
                     upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
				))
				),2)) ,
                      
					RTRIM(LTRIM([Address])),
					RTRIM(LTRIM([City])),
					RTRIM(LTRIM([State])),
					[Zip],
                     upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
				))
				),2)) ,
                        RecordSource
                FROM    CHSStaging.adv.tblVendorStage rw WITH ( NOLOCK )
                WHERE UPPER(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
					))
				),2))
				
				 NOT IN (
                        SELECT  HashDiff
                        FROM    S_Location
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
						GROUP BY 
				    upper(convert(char(32), HashBytes('MD5',
					Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
					))
				),2)),
                        LoadDate ,
                     upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
				))
				),2)) ,
                      
					RTRIM(LTRIM([Address])),
					RTRIM(LTRIM([City])),
					RTRIM(LTRIM([State])),
					[Zip],
                     upper(convert(char(32), HashBytes('MD5',
			Upper(Concat(
					RTRIM(LTRIM(COALESCE([Address],''))),':',		
					RTRIM(LTRIM(COALESCE([City],''))),':',		
					RTRIM(LTRIM(COALESCE([State],''))),':',		
					RTRIM(LTRIM(COALESCE([Zip],'')))
				))
				),2)) ,
                        RecordSource;

--RECORD END DATE CLEANUP
        UPDATE  dbo.S_Location
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_Location z
                                  WHERE     z.H_Location_RK = a.H_Location_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_Location a
        WHERE   RecordEndDate IS NULL; 

	

	--*** INSERT INTO S_CONTACT
INSERT INTO [dbo].[S_Contact]
           ([S_Contact_RK]
           ,[LoadDate]
           ,[H_Contact_RK]
           ,[ContactNumber]
           ,[FaxNumber]
             ,[EmailAddress]
           ,[HashDiff]
           ,[RecordSource]
           ,[RecordEndDate])
   
                SELECT  upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)) ,
                        LoadDate,
                        upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)) ,
                        [ContactNumber] ,
                        [FaxNumber] ,
                        [Email_Address] ,
                        upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)) ,
                        RecordSource ,
                        NULL
                FROM    CHSStaging.adv.tblVendorStage rw
                WHERE  upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)) NOT IN (
                        SELECT  HashDiff
                        FROM    S_Contact
                        WHERE   RecordEndDate IS NULL )
                        AND rw.CCI = @CCI
                GROUP BY  upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)) ,
                        LoadDate,
                        upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)) ,
                        [ContactNumber] ,
                        [FaxNumber] ,
                        [Email_Address] ,
                        upper(convert(char(32), HashBytes('MD5',
		Upper(Concat(
				RTRIM(LTRIM(COALESCE(ContactNumber,''))),':',
				RTRIM(LTRIM(COALESCE(FaxNumber,''))),':',
				RTRIM(LTRIM(COALESCE(Email_Address,''))),':',
				RTRIM(LTRIM(COALESCE(null,''))))
		)),2)) ,
                        RecordSource;

		--RECORD END DATE CLEANUP
        UPDATE  dbo.S_Contact
        SET     RecordEndDate = ( SELECT    DATEADD(ss, -1, MIN(z.LoadDate))
                                  FROM      dbo.S_Contact z
                                  WHERE     z.H_Contact_RK = a.H_Contact_RK
                                            AND z.LoadDate > a.LoadDate
                                )
        FROM    dbo.S_Contact a
        WHERE   RecordEndDate IS NULL; 
    END;
    
	
GO
