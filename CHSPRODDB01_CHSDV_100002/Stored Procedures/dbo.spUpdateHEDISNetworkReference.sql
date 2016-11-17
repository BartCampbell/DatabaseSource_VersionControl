SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	05/04/2016
-- Description:	Loads new providers into the network reference table from the 834 staging table
-- Usage:			
--		  EXECUTE dbo.spUpdateHEDISNetworkReference
-- =============================================

CREATE PROCEDURE [dbo].[spUpdateHEDISNetworkReference]
AS
    BEGIN

        SET NOCOUNT ON;


        BEGIN TRY

            BEGIN TRANSACTION;

             --LOAD NEW PROVIDERS FROM HEDIS STAGING
            INSERT  INTO CHSDV.dbo.R_Network
                    ( ClientID ,
                      ClientNetworkID ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            c.CentauriClientID ,
                            i.[PHO ID] AS ClientNetworkID ,
                            i.LoadDate ,
                            i.RecordSource
                    FROM    CHSStaging.stage.HEDIS_Import i
                            CROSS JOIN dbo.H_Client cl
                            INNER JOIN CHSDV.dbo.R_Client AS c ON cl.Client_BK = c.CentauriClientID
                            LEFT JOIN CHSDV.dbo.R_Network r ON i.[PHO ID] = r.ClientNetworkID
                                                               AND c.CentauriClientID = r.ClientID
                    WHERE   ISNULL(i.[PHO ID],'') <> ''
                            AND r.CentauriNetworkID IS NULL;

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;
GO
