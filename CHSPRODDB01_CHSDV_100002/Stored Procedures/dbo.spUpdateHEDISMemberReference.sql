SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		Travis Parker
-- Create date:	04/25/2016
-- Description:	Loads new members into the member reference table from the HEDIS staging table
-- Usage:			
--		  EXECUTE dbo.spUpdateHEDISMemberReference
-- =============================================

CREATE PROCEDURE [dbo].[spUpdateHEDISMemberReference]
AS
     BEGIN

         SET NOCOUNT ON;


         BEGIN TRY

             BEGIN TRANSACTION;

             --LOAD NEW PROVIDERS FROM HEDIS STAGING
             INSERT INTO CHSDV.dbo.R_Member
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
                    FROM  CHSStaging.hedis.RawImport AS m
					 CROSS JOIN dbo.H_Client cl 
                          INNER JOIN CHSDV.dbo.R_Client AS c ON cl.Client_BK = c.CentauriClientID
					 LEFT JOIN CHSDV.dbo.R_Member r ON m.MEM_NBR = r.ClientMemberID AND c.CentauriClientID = r.ClientID
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
