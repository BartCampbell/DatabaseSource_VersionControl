SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	08/18/2016
-- Description:	Loads all the Hubs from the HEDIS staging table
-- Usage:			
--		  EXECUTE dbo.spDV_HEDIS_LoadHubs
-- =============================================

CREATE PROCEDURE [dbo].[spDV_HEDIS_LoadHubs]
AS
    BEGIN

        SET NOCOUNT ON;

        BEGIN TRY

             --LOAD HEDIS HUB
            INSERT  INTO dbo.H_HEDIS
                    ( H_HEDIS_RK ,
                      HEDIS_BK ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            H_HEDIS_RK ,
                            HEDIS_BK ,
                            LoadDate ,
                            RecordSource
                    FROM    CHSStaging.hedis.RawImport
                    WHERE   H_HEDIS_RK NOT IN ( SELECT  H_HEDIS_RK
                                                FROM    dbo.H_HEDIS )
                            AND HEDIS_BK IS NOT NULL; 


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
                            p.[PCP ID] ,
                            p.RecordSource ,
                            p.LoadDate
                    FROM    CHSStaging.hedis.RawImport AS p
                    WHERE   p.H_Provider_RK NOT IN ( SELECT H_Provider_RK
                                                     FROM   dbo.H_Provider )
                            AND p.CentauriProviderID IS NOT NULL; 


		  --LOAD Network Hub
            INSERT  INTO dbo.H_Network
                    ( H_Network_RK ,
                      Network_BK ,
                      ClientNetworkID ,
                      RecordSource ,
                      LoadDate
			     )
                    SELECT DISTINCT
                            p.H_Network_RK ,
                            p.CentauriNetworkID ,
                            p.[PHO ID] ,
                            p.RecordSource ,
                            p.LoadDate
                    FROM    CHSStaging.hedis.RawImport AS p
                    WHERE   p.H_Network_RK NOT IN ( SELECT  H_Network_RK
                                                    FROM    dbo.H_Network )
                            AND p.CentauriNetworkID IS NOT NULL; 



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
                            MEM_NBR ,
                            LoadDate ,
                            RecordSource
                    FROM    CHSStaging.hedis.RawImport
                    WHERE   H_Member_RK NOT IN ( SELECT H_Member_RK
                                                 FROM   dbo.H_Member )
                            AND CentauriMemberID IS NOT NULL;

        END TRY
        BEGIN CATCH
             --IF @@TRANCOUNT > 0
             --    ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;
GO
