SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	05/04/2016
-- Description:	Loads new providers into the network reference table from the 834 staging tables
-- Usage:			
--		  EXECUTE dbo.prUpdate834NetworkReference
-- =============================================

CREATE PROCEDURE [dbo].[prUpdate834NetworkReference]
AS
     BEGIN

         SET NOCOUNT ON;


         BEGIN TRY

             BEGIN TRANSACTION;

             --LOAD NEW PROVIDERS FROM HEDIS STAGING
             INSERT INTO dbo.R_Network
                (
                  ClientID,
                  ClientNetworkID,
			   LoadDate,
			   RecordSource
                )
                    SELECT DISTINCT                         
                         c.CentauriClientID,
					RIGHT(RTRIM(n.[09]),LEN(RTRIM(n.[09])) - CHARINDEX(' ',RTRIM(n.[09]))) AS ClientNetworkID,
					i.CreatedDate AS LoadDate,
					RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS RecordSource
                    FROM  EDIStaging.dbo.NM1 AS n
				      INNER JOIN EDIStaging.dbo.Interchange i ON n.InterchangeId = i.Id
					 INNER JOIN EDIStaging.cfg.TradingPartnerFile t ON i.SenderId = t.SenderID and i.ReceiverId = t.ReceiverID
                          INNER JOIN dbo.R_Client AS c ON t.TradingPartner = c.ClientName
					 INNER JOIN EDIStaging.dbo.X12CodeList AS nx1 ON n.[01] = nx1.Code AND nx1.ElementId = 98 AND nx1.Definition = 'Primary Care Provider'
					 LEFT JOIN dbo.R_Network r ON RIGHT(RTRIM(n.[09]),LEN(RTRIM(n.[09])) - CHARINDEX(' ',RTRIM(n.[09]))) = r.ClientNetworkID AND c.CentauriClientID = r.ClientID
                    WHERE ISNULL(RIGHT(RTRIM(n.[09]),LEN(RTRIM(n.[09])) - CHARINDEX(' ',RTRIM(n.[09]))), '') <> '' AND r.CentauriNetworkID IS NULL

             COMMIT TRANSACTION;
         END TRY
         BEGIN CATCH
             IF @@TRANCOUNT > 0
                 ROLLBACK TRANSACTION;
             THROW;
         END CATCH;
     END;
GO
