SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	04/25/2016
-- Description:	Loads new members into the member reference table from the HEDIS staging table
-- Usage:			
--		  EXECUTE dbo.prUpdateHEDISMemberReference
-- =============================================

CREATE PROCEDURE [dbo].[prUpdateHEDISMemberReference]
AS
     BEGIN

         SET NOCOUNT ON;


         BEGIN TRY

             BEGIN TRANSACTION;

             --LOAD NEW PROVIDERS FROM HEDIS STAGING
             INSERT INTO dbo.R_Member
                (
                  ClientID,
                  ClientMemberID,
			   LoadDate,
			   RecordSource
                )
                    SELECT DISTINCT                         
                         c.CentauriClientID,
					m.MEM_NBR,
					m.LoadDate,
					m.RecordSource
                    FROM  CHSStaging.dv.HEDIS_ClientMember AS m
                          INNER JOIN dbo.R_Client AS c ON m.CLIENT = c.ClientName
					 LEFT JOIN dbo.R_Member r ON m.MEM_NBR = r.ClientMemberID AND c.CentauriClientID = r.ClientID
                    WHERE ISNULL(m.MEM_NBR, '') <> '' AND r.CentauriMemberID IS NULL

             COMMIT TRANSACTION;
         END TRY
         BEGIN CATCH
             IF @@TRANCOUNT > 0
                 ROLLBACK TRANSACTION;
             THROW;
         END CATCH;
     END;
GO
