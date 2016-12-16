SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	04/25/2016
-- Description:	Loads new providers into the provider reference table from the HEDIS staging table
-- Usage:			
--		  EXECUTE dbo.spUpdateHEDISProviderReference
-- =============================================

CREATE PROCEDURE [dbo].[spUpdateHEDISProviderReference]
AS
    BEGIN

        SET NOCOUNT ON;

        UPDATE  CHSStaging.hedis.RawImport
        SET     [PCP Name] = NULL
        WHERE   [PCP Name] = 'NULL';

        UPDATE  CHSStaging.hedis.RawImport
        SET     [PCP ID] = NULL
        WHERE   [PCP ID] = 'NULL';


        BEGIN TRY

            BEGIN TRANSACTION;

             --LOAD NEW PROVIDERS FROM HEDIS STAGING
            INSERT  INTO CHSDV.dbo.R_Provider
                    ( ClientID ,
                      ClientProviderID ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            c.Client_BK ,
                            i.[PCP ID] ,
                            i.LoadDate ,
                            i.RecordSource
                    FROM    CHSStaging.hedis.RawImport AS i
                            CROSS JOIN dbo.H_Client c
                            LEFT JOIN CHSDV.dbo.R_Provider r ON i.[PCP ID] = r.ClientProviderID
                                                                AND c.Client_BK = r.ClientID
                    WHERE   ISNULL(i.[PCP ID], '') <> ''
                            AND r.CentauriProviderID IS NULL;


            UPDATE  i
            SET     i.CentauriProviderID = r.CentauriProviderID
            FROM    CHSStaging.hedis.RawImport AS i
                    CROSS JOIN dbo.H_Client c
                    LEFT JOIN CHSDV.dbo.R_Provider r ON i.[PCP ID] = r.ClientProviderID
                                                        AND c.Client_BK = r.ClientID
            WHERE   ISNULL(i.[PCP ID], '') <> ''; 
		  

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;
GO
