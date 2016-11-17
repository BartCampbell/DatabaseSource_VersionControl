SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



---- =============================================
---- Author:		Travis Parker
---- Create date:	08/24/2016
---- Description:	Loads all the Hubs from the OEC staging table
---- Usage:			
----		  EXECUTE dbo.spDV_OEC_LoadHubs
---- =============================================

CREATE PROCEDURE [dbo].[spDV_OEC_LoadHubs]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY

             --LOAD PROVIDER HUB
            INSERT  INTO dbo.H_Provider
                    ( H_Provider_RK ,
                      Provider_BK ,
                      ClientProviderID ,
                      RecordSource ,
                      LoadDate
                    )
                    SELECT DISTINCT
                            p.H_Provider_RK ,
                            p.CentauriProviderID ,
                            p.ProviderID ,
                            p.FileName ,
                            p.LoadDate
                    FROM    CHSStaging.oec.AdvanceOECRaw_112549 AS p
                    WHERE   p.H_Provider_RK IS NOT NULL
                            AND p.H_Provider_RK NOT IN ( SELECT
                                                              H_Provider_RK
                                                         FROM dbo.H_Provider );

             --LOAD Member HUB
            INSERT  INTO dbo.H_Member
                    ( H_Member_RK ,
                      Member_BK ,
                      ClientMemberID ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            H_Member_RK ,
                            CentauriMemberID ,
                            MemberID ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112549
                    WHERE   H_Member_RK IS NOT NULL
                            AND H_Member_RK NOT IN ( SELECT H_Member_RK
                                                     FROM   dbo.H_Member );

		  --LOAD Client HUB
            INSERT  INTO dbo.H_Client
                    ( H_Client_RK ,
                      Client_BK ,
                      ClientName ,
                      RecordSource ,
                      LoadDate
		          )
                    SELECT DISTINCT
                            H_Client_RK ,
                            ClientID ,
                            ClientName ,
                            FileName ,
                            LoadDate
                    FROM    CHSStaging.oec.AdvanceOECRaw_112549
                    WHERE   H_Client_RK NOT IN ( SELECT H_Client_RK
                                                 FROM   dbo.H_Client );



		  --LOAD Network HUB
            INSERT  INTO dbo.H_Network
                    ( H_Network_RK ,
                      Network_BK ,
                      ClientNetworkID ,
                      RecordSource ,
                      LoadDate
		          )
                    SELECT DISTINCT
                            H_Network_RK ,
                            CentauriNetworkID ,
                            ProviderGroupID ,
                            FileName ,
                            LoadDate
                    FROM    CHSStaging.oec.AdvanceOECRaw_112549
                    WHERE   ISNULL(CentauriNetworkID, '') <> ''
                            AND H_Network_RK NOT IN ( SELECT  H_Network_RK
                                                      FROM    dbo.H_Network );
		  
		  
		  --LOAD Vendor HUB
            INSERT  INTO dbo.H_Vendor
                    ( H_Vendor_RK ,
                      Vendor_BK ,
                      RecordSource ,
                      LoadDate
		          )
                    SELECT DISTINCT
                            H_Vendor_RK ,
                            VendorID ,
                            FileName ,
                            LoadDate
                    FROM    CHSStaging.oec.AdvanceOECRaw_112549
                    WHERE   VendorID <> ''
                            AND H_Vendor_RK NOT IN ( SELECT H_Vendor_RK
                                                     FROM   dbo.H_Vendor );

		  
		  --LOAD Contact HUB - Provider
            INSERT  INTO dbo.H_Contact
                    ( H_Contact_RK ,
                      Contact_BK ,
                      LoadDate ,
                      RecordSource
		          )
                    SELECT  DISTINCT
                            H_Contact_RK_Provider ,
                            Contact_BK_Provider ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112549
                    WHERE   H_Contact_RK_Provider NOT IN ( SELECT
                                                              H_Contact_RK
                                                           FROM
                                                              dbo.H_Contact );


		  --LOAD Contact HUB - Vendor
            INSERT  INTO dbo.H_Contact
                    ( H_Contact_RK ,
                      Contact_BK ,
                      LoadDate ,
                      RecordSource
		          )
                    SELECT  DISTINCT
                            H_Contact_RK_Vendor ,
                            Contact_BK_Vendor ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112549
                    WHERE   Contact_BK_Vendor <> ''
                            AND H_Contact_RK_Vendor NOT IN ( SELECT
                                                              H_Contact_RK
                                                             FROM
                                                              dbo.H_Contact );


		  --LOAD Location HUB - Provider
            INSERT  INTO dbo.H_Location
                    ( H_Location_RK ,
                      Location_BK ,
                      LoadDate ,
                      RecordSource
		          )
                    SELECT  DISTINCT
                            H_Location_RK_Provider ,
                            Location_BK_Provider ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112549
                    WHERE   H_Location_RK_Provider NOT IN ( SELECT
                                                              H_Location_RK
                                                            FROM
                                                              dbo.H_Location );


		  --LOAD Location HUB - Vendor
            INSERT  INTO dbo.H_Location
                    ( H_Location_RK ,
                      Location_BK ,
                      LoadDate ,
                      RecordSource
		          )
                    SELECT  DISTINCT
                            H_Location_RK_Vendor ,
                            Location_BK_Vendor ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112549
                    WHERE   Location_BK_Vendor <> ''
                            AND H_Location_RK_Vendor NOT IN ( SELECT
                                                              H_Location_RK
                                                              FROM
                                                              dbo.H_Location );

		  
		  --LOAD OECProject HUB
            INSERT  INTO dbo.H_OECProject
                    ( H_OECProject_RK ,
                      OECProject_BK ,
                      RecordSource ,
                      LoadDate
                    )
                    SELECT DISTINCT
                            H_OECProject_RK ,
                            OECProject_BK ,
                            FileName ,
                            LoadDate
                    FROM    CHSStaging.oec.AdvanceOECRaw_112549
                    WHERE   H_OECProject_RK NOT IN ( SELECT H_OECProject_RK
                                                     FROM   dbo.H_OECProject );


		  --LOAD OEC HUB
            INSERT  INTO dbo.H_OEC
                    ( H_OEC_RK ,
                      OEC_BK ,
                      LoadDate ,
                      RecordSource
		          )
                    SELECT DISTINCT
                            H_OEC_RK ,
                            OEC_BK ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112549
                    WHERE   H_OEC_RK NOT IN ( SELECT    H_OEC_RK
                                              FROM      dbo.H_OEC );


		  --LOAD Specialty HUB
            INSERT  INTO dbo.H_Specialty
                    ( H_Specialty_RK ,
                      Specialty ,
                      LoadDate ,
                      RecordSource
		          )
                    SELECT DISTINCT
                            H_Specialty_RK ,
                            ProviderSpecialty ,
                            LoadDate ,
                            FileName
                    FROM    CHSStaging.oec.AdvanceOECRaw_112549
                    WHERE   H_Specialty_RK NOT IN ( SELECT  H_Specialty_RK
                                                    FROM    dbo.H_Specialty );



        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;


GO
