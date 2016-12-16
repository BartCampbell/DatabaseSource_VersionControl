SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	08/18/2016
-- Description:	Loads all the Links from the HEDIS staging table
-- Usage:			
--		  EXECUTE dbo.spDV_HEDIS_LoadLinks
-- =============================================

CREATE PROCEDURE [dbo].[spDV_HEDIS_LoadLinks]
AS
     BEGIN

         SET NOCOUNT ON;

         BEGIN TRY

		  --LOAD PROVIDER / NETWORK / CLIENT LINKS
		  INSERT INTO dbo.L_ProviderNetwork
			(
			  L_ProviderNetwork_RK,
			  H_Provider_RK,
			  H_Network_RK,
			  RecordSource,
			  LoadDate
			)
			    SELECT DISTINCT
				    L_ProviderNetwork_RK,
				    H_Provider_RK,
				    H_Network_RK,
				    RecordSource,
				    LoadDate
			    FROM  CHSStaging.hedis.RawImport AS p
			    WHERE p.CentauriNetworkID IS NOT NULL AND p.CentauriProviderID IS NOT NULL AND L_ProviderNetwork_RK NOT IN
			    (
				   SELECT
					   L_ProviderNetwork_RK
				   FROM  L_ProviderNetwork
				   WHERE RecordEndDate IS NULL
			    ) 



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
			    FROM  CHSStaging.hedis.RawImport
			    WHERE CentauriProviderID IS NOT NULL AND L_ProviderHEDIS_RK NOT IN
			    (
				   SELECT
					   L_ProviderHEDIS_RK
				   FROM dbo.L_ProviderHEDIS
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
			    FROM  CHSStaging.hedis.RawImport AS m --257472
			    WHERE m.CentauriProviderID IS NOT NULL AND m.CentauriMemberID IS NOT NULL AND L_MemberProvider_RK NOT IN
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
			    FROM  CHSStaging.hedis.RawImport
			    WHERE CentauriMemberID IS NOT NULL AND L_MemberHEDIS_RK NOT IN
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
