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


         BEGIN TRY

             BEGIN TRANSACTION;

             --LOAD NEW PROVIDERS FROM HEDIS STAGING
             INSERT INTO CHSDV.dbo.R_Provider
                (
                  ClientID,
                  ClientProviderID,
			   LoadDate,
			   RecordSource
                )
                    SELECT DISTINCT                         
                         c.CentauriClientID,
					hp.[PCP ID],
					hp.LoadDate,
					hp.RecordSource
                    FROM  CHSStaging.hedis.RawImport AS hp
					 CROSS JOIN dbo.H_Client cl 
                          INNER JOIN CHSDV.dbo.R_Client AS c ON cl.Client_BK = c.CentauriClientID
					 LEFT JOIN CHSDV.dbo.R_Provider r ON hp.[PCP ID] = r.ClientProviderID AND c.CentauriClientID = r.ClientID
                    WHERE ISNULL(hp.[PCP ID], '') <> '' AND r.CentauriProviderID IS NULL

             COMMIT TRANSACTION;
         END TRY
         BEGIN CATCH
             IF @@TRANCOUNT > 0
                 ROLLBACK TRANSACTION;
             THROW;
         END CATCH;
     END;
GO
