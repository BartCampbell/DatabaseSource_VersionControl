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

        UPDATE  CHSStaging.hedis.RawImport
        SET     [PHO ID] = NULL
        WHERE   [PHO ID] = 'NULL';

        UPDATE  CHSStaging.hedis.RawImport
        SET     [PHO Name] = NULL
        WHERE   [PHO Name] = 'NULL';


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
                            c.Client_BK ,
                            i.[PHO ID] AS ClientNetworkID ,
                            i.LoadDate ,
                            i.RecordSource
                    FROM    CHSStaging.hedis.RawImport i
                            CROSS JOIN dbo.H_Client c
                            LEFT JOIN CHSDV.dbo.R_Network r ON i.[PHO ID] = r.ClientNetworkID
                                                               AND c.Client_BK = r.ClientID
                    WHERE   ISNULL(i.[PHO ID], '') <> ''
                            AND r.CentauriNetworkID IS NULL;


            UPDATE  i
            SET     i.CentauriNetworkID = r.CentauriNetworkID
            FROM    CHSStaging.hedis.RawImport i
                    CROSS JOIN dbo.H_Client c
                    INNER JOIN CHSDV.dbo.R_Network r ON i.[PHO ID] = r.ClientNetworkID
                                                       AND c.Client_BK = r.ClientID;



            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;
GO
