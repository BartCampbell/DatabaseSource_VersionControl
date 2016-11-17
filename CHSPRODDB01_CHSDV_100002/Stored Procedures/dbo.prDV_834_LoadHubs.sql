SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







---- =============================================
---- Author:		Travis Parker
---- Create date:	04/22/2016
---- Description:	Loads all the Hubs from the 834 staging table
---- Usage:			
----		  EXECUTE dbo.prDV_834_LoadHubs
---- =============================================

CREATE PROCEDURE [dbo].[prDV_834_LoadHubs]
AS
     BEGIN

         SET NOCOUNT ON;

         BEGIN TRY

             --LOAD PROVIDER HUB
             INSERT INTO dbo.H_Provider
                (
                  H_Provider_RK,
                  Provider_BK,
			   ClientProviderID,
                  RecordSource,
                  LoadDate
                )
                    SELECT DISTINCT
                         H_Provider_RK,
                         CentauriProviderID,
					ProviderID,
                         RecordSource,
                         LoadDate
                    FROM  CHSStaging.dbo.X12_834_RawImport 
                    WHERE H_Provider_RK NOT IN
                    (
                        SELECT
                             H_Provider_RK
                        FROM dbo.H_Provider
                    ) ;


		   --LOAD NETWORK HUB
             INSERT INTO dbo.H_Network
                (
                  H_Network_RK,
                  Network_BK,
                  RecordSource,
                  LoadDate
                )
                    SELECT DISTINCT
                         H_Network_RK,
                         CentauriNetworkID,
                         RecordSource,
                         LoadDate
                    FROM  CHSStaging.dbo.X12_834_RawImport 
                    WHERE H_Network_RK NOT IN
                    (
                        SELECT
                             H_Network_RK
                        FROM dbo.H_Network
                    );

             --LOAD Member HUB
             INSERT INTO dbo.H_Member
                (
                  H_Member_RK,
                  Member_BK,
                  ClientMemberID,
                  LoadDate,
                  RecordSource
                )
                    SELECT DISTINCT
                         H_Member_RK,
                         CentauriMemberID,
                         MemberLevelDetail_RefID1_REF02,
                         LoadDate,
                         RecordSource
                    FROM  CHSStaging.dbo.X12_834_RawImport
                    WHERE H_Member_RK NOT IN
                    (
                        SELECT
                             H_Member_RK
                        FROM dbo.H_Member
                    );

             --*** LOAD H_CONTACT
             INSERT INTO H_Contact
                (
                  H_Contact_RK,
                  Contact_BK,
                  LoadDate,
                  RecordSource
                )
                    SELECT DISTINCT
                         H_Contact_RK,
                         Contact_BK,
                         LoadDate,
                         RecordSource
                    FROM  CHSStaging.dbo.X12_834_RawImport
                    WHERE H_Contact_RK NOT IN
                    (
                        SELECT
                             H_Contact_RK
                        FROM H_Contact
                    );

             ---*** LOAD H_Location
             INSERT INTO H_Location
                (
                  H_Location_RK,
                  Location_BK,
                  LoadDate,
                  RecordSource
                )
                    SELECT DISTINCT
                         H_Location_RK,
                         Location_BK,
                         LoadDate,
                         RecordSource
                    FROM  CHSStaging.dbo.X12_834_RawImport
                    WHERE H_Location_RK NOT IN
                    (
                        SELECT
                             H_Location_RK
                        FROM H_Location
                    );

             --LOAD H_ResponsibileParty OR Satellite?  

         END TRY
         BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
             THROW;
         END CATCH;
     END;

GO
