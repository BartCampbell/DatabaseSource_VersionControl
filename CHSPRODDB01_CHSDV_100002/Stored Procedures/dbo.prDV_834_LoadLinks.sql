SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		Travis Parker
-- Create date:	05/19/2016
-- Description:	Loads all the Links from the 834 staging table
-- Usage:			
--		  EXECUTE dbo.prDV_834_LoadLinks
-- =============================================

CREATE PROCEDURE [dbo].[prDV_834_LoadLinks]
AS
     BEGIN

         SET NOCOUNT ON;

         BEGIN TRY

             --LOAD MEMBER / PROVIDER LINKS

             INSERT INTO dbo.L_MemberProvider
                (
                  L_MemberProvider_RK,
                  H_Member_RK,
                  H_Provider_RK,
                  LoadDate,
                  RecordSource
                )
                    SELECT DISTINCT
                         L_MemberProvider_RK,
                         H_Member_RK,
                         H_Provider_RK,
                         LoadDate,
                         RecordSource
                    FROM  CHSStaging.dbo.X12_834_RawImport AS i
                    WHERE L_MemberProvider_RK NOT IN
                    (
                        SELECT
                             L_MemberProvider_RK
                        FROM dbo.L_MemberProvider
                    );

             --LOAD MEMBER / CONTACT LINKS

             INSERT INTO dbo.L_MemberContact
                (
                  L_MemberContact_RK,
                  H_Member_RK,
                  H_Contact_RK,
                  LoadDate,
                  RecordSource
                )
                    SELECT DISTINCT
                         L_MemberContact_RK,
                         H_Member_RK,
                         H_Contact_RK,
                         LoadDate,
                         RecordSource
                    FROM  CHSStaging.dbo.X12_834_RawImport AS i
                    WHERE L_MemberContact_RK NOT IN
                    (
                        SELECT
                             L_MemberContact_RK
                        FROM dbo.L_MemberContact
                    );
		  
             --LOAD MEMBER / LOCATION LINKS

             INSERT INTO dbo.L_MemberLocation
                (
                  L_MemberLocation_RK,
                  H_Member_RK,
                  H_Location_RK,
                  LoadDate,
                  RecordSource
                )
                    SELECT DISTINCT 
                         L_MemberLocation_RK,
                         H_Member_RK,
                         H_Location_RK,
                         LoadDate,
                         RecordSource
                    FROM  CHSStaging.dbo.X12_834_RawImport AS i
                    WHERE L_MemberLocation_RK NOT IN
                    (
                        SELECT
                             L_MemberLocation_RK
                        FROM dbo.L_MemberLocation
                    );

			 --LOAD PROVIDERNETWORK LINK
			 INSERT INTO dbo.L_ProviderNetwork
			         ( L_ProviderNetwork_RK ,
			           H_Provider_RK ,
			           H_Network_RK ,
			           RecordSource ,
			           LoadDate 
			         )
                SELECT DISTINCT
                        i.L_MemberProvider_RK ,
                        i.H_Provider_RK ,
                        i.H_Network_RK ,
                        i.RecordSource ,
                        i.LoadDate
                FROM    CHSStaging.dbo.X12_834_RawImport AS i
                WHERE   L_MemberProvider_RK NOT IN ( SELECT L_MemberProvider_RK
                                                     FROM   dbo.L_ProviderNetwork );


         END TRY
         BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
             THROW;
         END CATCH;
     END;

GO
