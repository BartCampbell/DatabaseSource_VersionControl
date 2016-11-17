SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	04/22/2016
-- Description:	Loads all the Links from the HEDIS staging table
-- Usage:			
--		  EXECUTE dbo.prDV_HEDIS_LoadLinks
-- =============================================

CREATE PROCEDURE [dbo].[prDV_HEDIS_LoadLinks]
AS
     BEGIN

         SET NOCOUNT ON;

         BEGIN TRY

		  --LOAD PROVIDER / NETWORK / CLIENT LINKS
		  INSERT INTO dbo.L_ProviderNetworkClient
			(
			  L_ProviderNetworkClient_RK,
			  H_Provider_RK,
			  H_Client_RK,
			  H_Network_RK,
			  RecordSource,
			  LoadDate
			)
			    SELECT DISTINCT
				    L_ProviderNetworkClient_RK,
				    H_Provider_RK,
				    H_Client_RK,
				    H_Network_RK,
				    RecordSource,
				    LoadDate
			    FROM  CHSStaging.dv.HEDIS_Provider AS p
			    WHERE L_ProviderNetworkClient_RK NOT IN
			    (
				   SELECT
					   L_ProviderNetworkClient_RK
				   FROM  L_ProviderNetworkClient
				   WHERE RecordEndDate IS NULL
			    );

		  --LOAD PROVIDER / HEDIS LINKS
		  INSERT INTO dbo.L_ProviderHEDIS
			(
			  L_ProviderHEDIS_RK,
			  H_Provider_RK,
			  H_HEDIS_RK,
			  LoadDate,
			  RecordSource
			)
			    SELECT DISTINCT
				    L_ProviderHEDIS_RK,
				    H_Provider_RK,
				    H_HEDIS_RK,
				    LoadDate,
				    RecordSource
			    FROM  CHSStaging.dv.HEDIS_Provider
			    WHERE L_ProviderHEDIS_RK NOT IN
			    (
				   SELECT
					   L_ProviderHEDIS_RK
				   FROM dbo.L_ProviderHEDIS
			    );

		  --LOAD MEMBER / CLIENT LINKS 
		  INSERT INTO dbo.L_MemberClient
			(
			  L_MemberClient_RK,
			  H_Member_RK,
			  H_Client_RK,
			  LoadDate,
			  RecordSource
			)
			    SELECT DISTINCT
				    L_MemberClient_RK,
				    H_Member_RK,
				    H_Client_RK,
				    LoadDate,
				    RecordSource
			    FROM  CHSStaging.dv.HEDIS_Member AS m
			    WHERE L_MemberClient_RK NOT IN
			    (
				   SELECT
					   L_MemberClient_RK
				   FROM dbo.L_MemberClient
			    );


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
				    m.L_MemberProvider_RK,
				    m.H_Member_RK,
				    m.H_Provider_RK,
				    m.LoadDate,
				    m.RecordSource
			    FROM  CHSStaging.dv.HEDIS_Member AS m --257472
			    WHERE m.Provider_BK IS NOT NULL AND L_MemberProvider_RK NOT IN
			    (
				   SELECT
					   L_MemberProvider_RK
				   FROM dbo.L_MemberProvider
			    );

		  --LOAD MEMBER / HEDIS LINKS
		  INSERT INTO dbo.L_MemberHEDIS
			(
			  L_MemberHEDIS_RK,
			  H_Member_RK,
			  H_HEDIS_RK,
			  LoadDate,
			  RecordSource
			)
			    SELECT DISTINCT
				    L_MemberHEDIS_RK,
				    H_Member_RK,
				    H_HEDIS_RK,
				    LoadDate,
				    RecordSource
			    FROM  CHSStaging.dv.HEDIS_Member
			    WHERE L_MemberHEDIS_RK NOT IN
			    (
				   SELECT
					   L_MemberHEDIS_RK
				   FROM dbo.L_MemberHEDIS
			    );


         END TRY
         BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
             THROW;
         END CATCH;
     END;
GO
