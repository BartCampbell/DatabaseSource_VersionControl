SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	04/22/2016
-- Description:	Loads all the Hubs from the HEDIS staging table
-- Usage:			
--		  EXECUTE dbo.prDV_HEDIS_LoadHubs
-- =============================================

CREATE PROCEDURE [dbo].[prDV_HEDIS_LoadHubs]
AS
     BEGIN

         SET NOCOUNT ON;

         BEGIN TRY

             --LOAD HEDIS HUB
             INSERT INTO dbo.H_HEDIS
                (
                  H_HEDIS_RK,
                  HEDIS_BK,
                  PRODUCT_ROLLUP_ID,
                  MEM_NBR,
                  LoadDate,
                  RecordSource
                )
                    SELECT DISTINCT
                         H_HEDIS_RK,
                         HEDIS_BK,
                         PRODUCT_ROLLUP_ID,
                         MEM_NBR,
                         LoadDate,
                         RecordSource
                    FROM  CHSStaging.dv.HEDIS_Import
                    WHERE H_HEDIS_RK NOT IN
                    (
                        SELECT
                             H_HEDIS_RK
                        FROM dbo.H_HEDIS
                    );


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
				    p.LoadDate
			    FROM  CHSStaging.dv.HEDIS_Provider AS p 
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
				    p.[PHO ID] AS Network_BK,
				    p.[PHO Name] AS NetworkName,
				    p.RecordSource,
				    p.LoadDate
			    FROM  CHSStaging.dv.HEDIS_Provider AS p
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
				    LoadDate,
				    RecordSource
			    FROM  CHSStaging.dv.HEDIS_Member
			    WHERE H_Member_RK NOT IN
			    (
				   SELECT
					   H_Member_RK
				   FROM dbo.H_Member
			    );

         END TRY
         BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
             THROW;
         END CATCH;
     END;
GO
