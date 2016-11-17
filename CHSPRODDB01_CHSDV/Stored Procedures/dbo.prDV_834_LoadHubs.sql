SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	04/22/2016
-- Description:	Loads all the Hubs from the 834 staging tables
-- Usage:			
--		  EXECUTE dbo.prDV_834_LoadHubs
-- =============================================

CREATE PROCEDURE [dbo].[prDV_834_LoadHubs]
AS
     BEGIN

         SET NOCOUNT ON;

	    DECLARE @CurrentDate AS DateTime = GETDATE()

         BEGIN TRY

		  --LOAD PROVIDER HUB
		  INSERT INTO dbo.H_Provider
			(
			  H_Provider_RK,
			  Provider_BK,
			  RecordSource,
			  LoadDate
			)
			    SELECT DISTINCT
				    p.H_Provider_RK,
				    p.Provider_BK,
				    p.RecordSource,
				    @CurrentDate
			    FROM  EDIStaging.dv.vw834ProviderInformation AS p 
			    WHERE p.H_Provider_RK NOT IN (SELECT H_Provider_RK FROM dbo.H_Provider)


		  --LOAD Network Hub
		  INSERT INTO dbo.H_Network
			(
			  H_Network_RK,
			  Network_BK,
			  NetworkName,
			  RecordSource,
			  LoadDate
			)
			    SELECT DISTINCT
				    p.H_Network_RK,
				    p.NetworkID AS Network_BK,
				    p.NetworkName AS NetworkName,
				    p.RecordSource,
				    @CurrentDate
			    FROM  EDIStaging.dv.vw834ProviderInformation AS p
			    WHERE p.H_Network_RK NOT IN
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
			  LoadDate,
			  RecordSource
			)
			    SELECT DISTINCT
				    H_Member_RK,
				    Member_BK,
				    @CurrentDate,
				    RecordSource
			    FROM  EDIStaging.dv.vw834MemberInformation
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
				    @CurrentDAte,
				    RecordSource
			    FROM  EDIStaging.dv.vw834CommNumbers
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
				    @CurrentDate,
				    RecordSource
			    FROM  EDIStaging.dv.vw834Location --5108
			    WHERE ISNULL(Addr1, '') <> ''
					AND H_Location_RK NOT IN
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
