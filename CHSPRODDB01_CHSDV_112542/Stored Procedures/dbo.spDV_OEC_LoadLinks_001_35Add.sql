SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







-- =============================================
-- Author:		Travis Parker
-- Create date:	05/27/2016
-- Description:	Loads all the Links from the OEC staging table
-- Usage:			
--		  EXECUTE dbo.spDV_OEC_LoadLinks_001_35Add
-- =============================================

CREATE PROCEDURE [dbo].[spDV_OEC_LoadLinks_001_35Add]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY


		  --LOAD MemberOEC Link
            INSERT  INTO dbo.L_MemberOEC
                    ( L_MemberOEC_RK ,
                      H_Member_RK ,
                      H_OEC_RK ,
                      LoadDate ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            L_MemberOEC_RK ,
                            H_Member_RK ,
                            H_OEC_RK ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001_35Add
                    WHERE   L_MemberOEC_RK NOT IN ( SELECT  L_MemberOEC_RK
                                                    FROM    dbo.L_MemberOEC );

		  --LOAD MemberProvider Link
            INSERT  INTO dbo.L_MemberProvider
                    ( L_MemberProvider_RK ,
                      H_Member_RK ,
                      H_Provider_RK ,
                      LoadDate ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            L_MemberProvider_RK ,
                            H_Member_RK ,
                            H_Provider_RK ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001_35Add
                    WHERE   L_MemberProvider_RK NOT IN (
                            SELECT  L_MemberProvider_RK
                            FROM    dbo.L_MemberProvider );

		  
		  --LOAD L_OECProviderNetwork Link
            INSERT  INTO dbo.L_OECProviderNetwork
                    ( L_OECProviderNetwork_RK ,
                      H_OEC_RK ,
                      H_Provider_RK ,
                      H_Network_RK ,
                      RecordSource ,
                      LoadDate 
                    )
                    SELECT DISTINCT
                            L_OECProviderNetwork_RK ,
                            H_OEC_RK ,
                            H_Provider_RK ,
                            H_Network_RK ,
                            FileName ,
                            LoadDate
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001_35Add
                    WHERE   ISNULL(VendorID, '') <> ''
                            AND L_OECProviderNetwork_RK NOT IN (
                            SELECT  L_OECProviderNetwork_RK
                            FROM    dbo.L_OECProviderNetwork ); 

		  
		  --LOAD L_OECVendorContact Link
            INSERT  INTO dbo.L_OECVendorContact
                    ( L_OECVendorContact_RK ,
                      H_OEC_RK ,
                      H_Vendor_RK ,
                      H_Contact_RK ,
                      LoadDate ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            L_OECVendorContact_RK ,
                            H_OEC_RK ,
                            H_Vendor_RK ,
                            H_Contact_RK_Vendor ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001_35Add
                    WHERE   Contact_BK_Vendor <> ''
                            AND L_OECVendorContact_RK NOT IN (
                            SELECT  L_OECVendorContact_RK
                            FROM    dbo.L_OECVendorContact ); 
		  
		  --LOAD L_OECProviderContact Link
            INSERT  INTO dbo.L_OECProviderContact
                    ( L_OECProviderContact_RK ,
                      H_OEC_RK ,
                      H_Provider_RK ,
                      H_Contact_RK ,
                      LoadDate ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            L_OECProviderContact_RK ,
                            H_OEC_RK ,
                            H_Provider_RK ,
                            H_Contact_RK_Provider ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001_35Add
                    WHERE   L_OECProviderContact_RK IS NOT NULL
                            AND L_OECProviderContact_RK NOT IN (
                            SELECT  L_OECProviderContact_RK
                            FROM    dbo.L_OECProviderContact ); 
		  
		  
		  --LOAD L_OECVendorLocation Link
            INSERT  INTO dbo.L_OECVendorLocation
                    ( L_OECVendorLocation_RK ,
                      H_OEC_RK ,
                      H_Vendor_RK ,
                      H_Location_RK ,
                      LoadDate ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            L_OECVendorLocation_RK ,
                            H_OEC_RK ,
                            H_Vendor_RK ,
                            H_Location_RK_Vendor ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001_35Add
                    WHERE   Location_BK_Vendor <> ''
                            AND L_OECVendorLocation_RK NOT IN (
                            SELECT  L_OECVendorLocation_RK
                            FROM    dbo.L_OECVendorLocation ); 
		  
		  --LOAD L_OECProviderLocation Link
            INSERT  INTO dbo.L_OECProviderLocation
                    ( L_OECProviderLocation_RK ,
                      H_OEC_RK ,
                      H_Provider_RK ,
                      H_Location_RK ,
                      LoadDate ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            L_OECProviderLocation_RK ,
                            H_OEC_RK ,
                            H_Provider_RK ,
                            H_Location_RK_Provider ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001_35Add
                    WHERE   L_OECProviderLocation_RK IS NOT NULL
                            AND L_OECProviderLocation_RK NOT IN (
                            SELECT  L_OECProviderLocation_RK
                            FROM    dbo.L_OECProviderLocation ); 


		  --LOAD ProviderSpecialty Link
            INSERT  INTO dbo.L_ProviderSpecialty
                    ( L_ProviderSpecialty_RK ,
                      H_Provider_RK ,
                      H_Specialty_RK ,
                      LoadDate ,
                      RecordSource 
		          )
                    SELECT DISTINCT
                            L_ProviderSpecialty_RK ,
                            H_Provider_RK ,
                            H_Specialty_RK ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001_35Add
                    WHERE   L_ProviderSpecialty_RK NOT IN (
                            SELECT  L_ProviderSpecialty_RK
                            FROM    dbo.L_ProviderSpecialty );


		  --LOAD OECProjectOEC Link
            INSERT  INTO dbo.L_OECProjectOEC
                    ( L_OECProjectOEC_RK ,
                      H_OECProject_RK ,
                      H_OEC_RK ,
                      LoadDate ,
                      RecordSource
		          )
                    SELECT DISTINCT
                            L_OECProjectOEC_RK ,
                            H_OECProject_RK ,
                            H_OEC_RK ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112542_001_35Add
                    WHERE   L_OECProjectOEC_RK NOT IN (
                            SELECT  L_OECProjectOEC_RK
                            FROM    dbo.L_OECProjectOEC );



        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;



GO
