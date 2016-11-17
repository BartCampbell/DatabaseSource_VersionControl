SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- =============================================
-- Author:		Travis Parker
-- Create date:	05/27/2016
-- Description:	Loads all the Satellites from the OEC staging table
-- Usage:			
--		  EXECUTE dbo.spDV_OEC_LoadSats_001
-- =============================================

CREATE PROCEDURE [dbo].[spDV_OEC_LoadSats_001]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY

		  --LOAD Contact satellite - Provider
            INSERT  INTO dbo.S_Contact
                    ( S_Contact_RK ,
                      LoadDate ,
                      H_Contact_RK ,
                      Phone,
				  Fax,
                      HashDiff ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            o.S_Contact_RK_Provider ,
                            o.LoadDate ,
                            o.H_Contact_RK_Provider ,
                            o.ProviderPhone,
					   o.ProviderFax,
                            o.S_ContactHashDiff_Provider ,
                            o.FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001 o
                            LEFT JOIN dbo.S_Contact s ON o.H_Contact_RK_Provider = s.H_Contact_RK
                                                          AND s.RecordEndDate IS NULL
                                                          AND o.S_ContactHashDiff_Provider = s.HashDiff
                    WHERE   s.S_Contact_RK IS NULL; 
		  
		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_Contact
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_Contact AS z
                                      WHERE     z.H_Contact_RK = a.H_Contact_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_Contact a
            WHERE   a.RecordEndDate IS NULL;
		  
		  --LOAD Contact satellite - Vendor
            INSERT  INTO dbo.S_Contact
                    ( S_Contact_RK ,
                      LoadDate ,
                      H_Contact_RK ,
                      Phone,
				  Fax,
                      HashDiff ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            o.S_Contact_RK_Vendor ,
                            o.LoadDate ,
                            o.H_Contact_RK_Vendor ,
                            o.VendorPhone,
					   o.VendorFax,
                            o.S_ContactHashDiff_Vendor ,
                            o.FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001 o
                            LEFT JOIN dbo.S_Contact s ON o.H_Contact_RK_Vendor = s.H_Contact_RK
                                                          AND s.RecordEndDate IS NULL
                                                          AND o.S_ContactHashDiff_Vendor = s.HashDiff
                    WHERE   s.S_Contact_RK IS NULL AND Contact_BK_Vendor <> ''; 


		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_Contact
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_Contact AS z
                                      WHERE     z.H_Contact_RK = a.H_Contact_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_Contact a
            WHERE   a.RecordEndDate IS NULL;
		  

		  --LOAD Location satellite - Provider
            INSERT  INTO dbo.S_Location
                    ( S_Location_RK ,
                      LoadDate ,
                      H_Location_RK ,
                      Address1 ,
                      City ,
                      State ,
                      Zip ,
                      HashDiff ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            o.S_Location_RK_Provider ,
                            o.LoadDate ,
                            o.H_Location_RK_Provider ,
                            RTRIM(o.ProviderAddress) ProviderAddress ,
                            RTRIM(o.ProviderCity) ProviderCity ,
                            RTRIM(o.ProviderState) ProviderState ,
                            LEFT(o.ProviderZip,5) ProviderZip ,
                            o.S_LocationHashDiff_Provider ,
                            o.FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001 o
                            LEFT JOIN dbo.S_Location s ON o.H_Location_RK_Provider = s.H_Location_RK
                                                          AND s.RecordEndDate IS NULL
                                                          AND o.S_LocationHashDiff_Provider = s.HashDiff
                    WHERE   s.S_Location_RK IS NULL; 

		  
		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_Location
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_Location AS z
                                      WHERE     z.H_Location_RK = a.H_Location_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_Location a
            WHERE   a.RecordEndDate IS NULL;

		  
		  --LOAD Location satellite - Vendor
            INSERT  INTO dbo.S_Location
                    ( S_Location_RK ,
                      LoadDate ,
                      H_Location_RK ,
                      Address1 ,
                      City ,
                      State ,
                      Zip ,
                      HashDiff ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            o.S_Location_RK_Vendor ,
                            o.LoadDate ,
                            o.H_Location_RK_Vendor ,
                            o.VendorAddress ,
                            o.VendorCity ,
                            o.VendorState ,
                            o.VendorZip ,
                            o.S_LocationHashDiff_Vendor ,
                            o.FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001 o
                            LEFT JOIN dbo.S_Location s ON o.H_Location_RK_Vendor = s.H_Location_RK
                                                          AND s.RecordEndDate IS NULL
                                                          AND o.S_LocationHashDiff_Vendor = s.HashDiff
                    WHERE   s.S_Location_RK IS NULL AND Location_BK_Vendor <> ''; 


		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_Location
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_Location AS z
                                      WHERE     z.H_Location_RK = a.H_Location_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_Location a
            WHERE   a.RecordEndDate IS NULL;

		  --LOAD MemberDemo satellite
            INSERT  INTO dbo.S_MemberDemo
                    ( S_MemberDemo_RK ,
                      LoadDate ,
                      H_Member_RK ,
                      FirstName ,
                      LastName ,
                      Gender ,
                      DOB ,
                      HashDiff ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            o.S_MemberDemo_RK ,
                            o.LoadDate ,
                            o.H_Member_RK ,
                            o.MemberFirstName ,
                            o.MemberLastName ,
                            o.MemberGender ,
                            o.MemberDOB ,
                            o.S_MemberDemoHashDiff ,
                            o.FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001 o
                            LEFT JOIN dbo.S_MemberDemo s ON s.H_Member_RK = o.H_Member_RK
                                                            AND s.RecordEndDate IS NULL
                                                            AND o.S_MemberDemoHashDiff = s.HashDiff
                    WHERE   s.S_MemberDemo_RK IS NULL;

		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_MemberDemo
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_MemberDemo AS z
                                      WHERE     z.H_Member_RK = a.H_Member_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_MemberDemo a
            WHERE   a.RecordEndDate IS NULL;


		  --LOAD MemberHICN satellite
            INSERT  INTO dbo.S_MemberHICN
                    ( S_MemberHICN_RK ,
                      LoadDate ,
                      H_Member_RK ,
                      HICNumber ,
                      HashDiff ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            o.S_MemberHICN_RK ,
                            o.LoadDate ,
                            o.H_Member_RK ,
                            o.MemberHICN ,
                            o.S_MemberHICN_HashDiff ,
                            o.FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001 o
                            LEFT JOIN dbo.S_MemberHICN s ON s.H_Member_RK = o.H_Member_RK
                                                            AND s.RecordEndDate IS NULL
                                                            AND o.S_MemberHICN_HashDiff = s.HashDiff
                    WHERE   s.S_MemberHICN_RK IS NULL AND ISNULL(o.MemberHICN,'') <> ''; 

		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_MemberHICN
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_MemberHICN AS z
                                      WHERE     z.H_Member_RK = a.H_Member_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_MemberHICN a
            WHERE   a.RecordEndDate IS NULL;


		  --LOAD OECDetail satellite
            INSERT  INTO dbo.S_OECDetail
                    ( S_OECDetail_RK ,
                      H_OEC_RK ,
				  MemberHICN ,
                      DiagnosisCode ,
                      ICD_Indicator ,
                      DOS_FromDate ,
                      DOS_ToDate ,
				  ClaimID,
				  ChaseID,
				  MedicalRecordID,
				  ProviderSpecialty, 
				  PricingID,
				  SVCTaxID,
				  MHFacilityFlag,
				  NetworkIndicator,
                      HashDiff ,
                      RecordSource ,
                      LoadDate 
		          )
                    SELECT DISTINCT
                            o.S_OECDetail_RK ,
                            o.H_OEC_RK ,
					   o.MemberHICN ,
                            o.DiagnosisCode ,
                            o.ICD9_ICD10_Ind ,
                            o.DOS_FromDate ,
                            o.DOS_ToDate ,
					   o.ClaimID ,
					   o.ChaseID ,
					   o.MedicalRecordID,
					   o.ProviderSpecialty,
					   o.PRICING_ID,
					   o.SVC_TAX_ID,
					   o.MHFacilityFlag,
					   o.NetworkIndicator,
                            o.S_OECDetail_HashDiff ,
                            o.FileName ,
                            o.LoadDate
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001 o
                            LEFT JOIN dbo.S_OECDetail s ON s.H_OEC_RK = o.H_OEC_RK
                                                           AND s.RecordEndDate IS NULL
                                                           AND o.S_OECDetail_HashDiff = s.HashDiff
                    WHERE   s.S_OECDetail_RK IS NULL; 

		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_OECDetail
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_OECDetail AS z
                                      WHERE     z.H_OEC_RK = a.H_OEC_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_OECDetail a
            WHERE   a.RecordEndDate IS NULL;


		  --LOAD ProviderDemo satellite
            INSERT  INTO dbo.S_ProviderDemo
                    ( S_ProviderDemo_RK ,
                      LoadDate ,
                      H_Provider_RK ,
                      NPI ,
				  FullName ,
                      LastName ,
                      FirstName ,
                      HashDiff ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            o.S_ProviderDemo_RK ,
                            o.LoadDate ,
                            o.H_Provider_RK ,
                            o.ProviderNPI ,
					   o.ProviderFullName ,
                            o.ProviderLastName ,
                            o.ProviderFirstName ,
                            o.S_ProviderDemoHashDiff ,
                            o.FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001 o
                            LEFT JOIN dbo.S_ProviderDemo s ON s.H_Provider_RK = o.H_Provider_RK
                                                              AND s.RecordEndDate IS NULL
                                                              AND o.S_ProviderDemoHashDiff = s.HashDiff
                    WHERE   s.S_ProviderDemo_RK IS NULL; 

		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_ProviderDemo
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_ProviderDemo AS z
                                      WHERE     z.H_Provider_RK = a.H_Provider_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_ProviderDemo a
            WHERE   a.RecordEndDate IS NULL;

		  
		  --LOAD OECProject Satellite
            INSERT  INTO dbo.S_OECProject
                    ( S_OECProject_RK ,
                      H_OECProject_RK ,
                      ProjectID ,
                      ProjectName ,
                      HashDiff ,
                      LoadDate ,
                      RecordSource 
		          )
                    SELECT  DISTINCT
                            o.S_OECProject_RK ,
                            o.H_OECProject_RK ,
                            o.OEC_ProjectID ,
                            o.OEC_ProjectName ,
                            o.S_OECProject_HashDiff ,
                            o.LoadDate ,
                            o.FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001 o
                            LEFT JOIN dbo.S_OECProject s ON s.H_OECProject_RK = o.H_OECProject_RK
                                                            AND s.RecordEndDate IS NULL
                                                            AND o.S_OECDetail_HashDiff = s.HashDiff
                    WHERE   s.S_OECProject_RK IS NULL; 


		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_OECProject
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_OECProject AS z
                                      WHERE     z.H_OECProject_RK = a.H_OECProject_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_OECProject a
            WHERE   a.RecordEndDate IS NULL;



		  --LOAD Vendor satellite
            INSERT  INTO dbo.S_Vendor
                    ( S_Vendor_RK ,
                      LoadDate ,
                      H_Vendor_RK ,
                      Name ,
                      HashDiff ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            o.S_Vendor_RK ,
                            o.LoadDate ,
                            o.H_Vendor_RK ,
                            o.VendorName ,
                            o.S_VendorHashDiff ,
                            o.FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001 o
                            LEFT JOIN dbo.S_Vendor s ON s.H_Vendor_RK = o.H_Vendor_RK
                                                            AND s.RecordEndDate IS NULL
                                                            AND o.S_VendorHashDiff = s.HashDiff
                    WHERE   s.S_Vendor_RK IS NULL AND ISNULL(o.VendorID,'') <> ''; 

		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_Vendor
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_Vendor AS z
                                      WHERE     z.H_Vendor_RK = a.H_Vendor_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_Vendor a
            WHERE   a.RecordEndDate IS NULL;


		  --LOAD Network satellite
            INSERT  INTO dbo.S_Network
                    ( S_Network_RK ,
                      LoadDate ,
                      H_Network_RK ,
                      Name ,
                      HashDiff ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            o.S_Network_RK ,
                            o.LoadDate ,
                            o.H_Network_RK ,
                            o.ProviderGroupName ,
                            o.S_NetworkHashDiff ,
                            o.FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001 o
                            LEFT JOIN dbo.S_Network s ON s.H_Network_RK = o.H_Network_RK
                                                            AND s.RecordEndDate IS NULL
                                                            AND o.S_NetworkHashDiff = s.HashDiff
                    WHERE   s.S_Network_RK IS NULL AND ISNULL(o.ProviderGroupID,'') <> ''; 

		  --RECORD END DATE CLEANUP
            UPDATE  dbo.S_Network
            SET     RecordEndDate = ( SELECT    DATEADD(ss, -1,
                                                        MIN(z.LoadDate))
                                      FROM      dbo.S_Network AS z
                                      WHERE     z.H_Network_RK = a.H_Network_RK
                                                AND z.LoadDate > a.LoadDate
                                    )
            FROM    dbo.S_Network a
            WHERE   a.RecordEndDate IS NULL;


        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;



GO
