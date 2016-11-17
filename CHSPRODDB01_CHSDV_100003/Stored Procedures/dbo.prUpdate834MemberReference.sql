SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	04/25/2016
-- Description:	Loads new members into the member reference table from the 834 staging tables
-- Usage:			
--		  EXECUTE dbo.prUpdate834MemberReference
-- =============================================

CREATE PROCEDURE [dbo].[prUpdate834MemberReference]
AS
     BEGIN

         SET NOCOUNT ON;


         BEGIN TRY

             BEGIN TRANSACTION;

             --LOAD NEW MEMBERS FROM 834 STAGING
		   IF OBJECT_ID('tempdb..#Results') IS NOT NULL
			 DROP TABLE #Results

             SELECT DISTINCT
                  c.CentauriClientID,
                  ISNULL(n.[09], '') AS ClientMemberID
             INTO
                  #NewMembers
             FROM  EDIStaging.dbo.NM1 AS n
                   INNER JOIN EDIStaging.dbo.Interchange AS i ON n.InterchangeId = i.Id
                   INNER JOIN EDIStaging.cfg.TradingPartnerFile AS t ON i.SenderId = t.SenderID
                                                                        AND i.ReceiverId = t.ReceiverID
                   INNER JOIN dbo.R_Client AS c ON t.TradingPartner = c.ClientName
                   INNER JOIN EDIStaging.dbo.X12CodeList AS nx1 ON n.[01] = nx1.Code
                                                                   AND nx1.ElementId = 98
                                                                   AND nx1.Definition = 'Insured or Subscriber'
                   LEFT JOIN dbo.R_Member AS r ON n.[09] = r.ClientMemberID
                                                  AND c.CentauriClientID = r.ClientID
             WHERE r.CentauriMemberID IS NULL;

             INSERT INTO dbo.R_Member
                (
                  ClientID,
                  ClientMemberID
                )
                    SELECT
                         CentauriClientID,
					ClientMemberID
                    FROM  #NewMembers
                    WHERE ClientMemberID <> '';


             COMMIT TRANSACTION;
         END TRY
         BEGIN CATCH
             IF @@TRANCOUNT > 0
                 ROLLBACK TRANSACTION;
             THROW;
         END CATCH;
     END;
GO
