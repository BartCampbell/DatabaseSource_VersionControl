SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	05/04/2016
-- Description:	Loads new providers into the provider reference table from the 834 staging tables
-- Usage:			
--		  EXECUTE dbo.prUpdate834ProviderReference
-- =============================================

CREATE PROCEDURE [dbo].[prUpdate834ProviderReference]
AS
     BEGIN

         SET NOCOUNT ON;


         BEGIN TRY

             BEGIN TRANSACTION;

             --LOAD NEW PROVIDERS FROM HEDIS STAGING
             INSERT INTO dbo.R_Provider
                (
                  ClientID,
                  ClientProviderID
                )
				SELECT DISTINCT                         
                         c.CentauriClientID,
					LEFT(LTRIM(n.[09]),CHARINDEX(' ',LTRIM(n.[09]))-1) AS ClientProviderID
                    FROM  EDIStaging.dbo.NM1 AS n
				      INNER JOIN EDIStaging.dbo.Interchange i ON n.InterchangeId = i.Id
					 INNER JOIN EDIStaging.cfg.TradingPartnerFile t ON i.SenderId = t.SenderID and i.ReceiverId = t.ReceiverID
                          INNER JOIN dbo.R_Client AS c ON t.TradingPartner = c.ClientName
					 INNER JOIN EDIStaging.dbo.X12CodeList AS nx1 ON n.[01] = nx1.Code AND nx1.ElementId = 98 AND nx1.Definition = 'Primary Care Provider'
					 LEFT JOIN dbo.R_Provider r ON LEFT(LTRIM(n.[09]),CHARINDEX(' ',LTRIM(n.[09]))-1)= r.ClientProviderID AND c.CentauriClientID = r.ClientID
                    WHERE ISNULL(LEFT(LTRIM(n.[09]),CHARINDEX(' ',LTRIM(n.[09]))-1), '') <> '' AND n.[03] <> '' AND r.CentauriProviderID IS NULL

             COMMIT TRANSACTION;
         END TRY
         BEGIN CATCH
             IF @@TRANCOUNT > 0
                 ROLLBACK TRANSACTION;
             THROW;
         END CATCH;
     END;
GO
