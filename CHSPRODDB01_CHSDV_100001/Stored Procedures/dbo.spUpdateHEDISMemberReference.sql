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
            INSERT  INTO CHSDV.dbo.R_Member
                    ( ClientID ,
                      ClientMemberID ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            c.Client_BK ,
                            i.MEM_NBR ,
                            i.LoadDate ,
                            i.RecordSource
                    FROM    CHSStaging.hedis.RawImport AS i
                            CROSS JOIN dbo.H_Client c
                            LEFT JOIN CHSDV.dbo.R_Member r ON i.MEM_NBR = r.ClientMemberID
                                                              AND c.Client_BK = r.ClientID
                    WHERE   ISNULL(i.MEM_NBR, '') <> ''
                            AND r.CentauriMemberID IS NULL;

            UPDATE  i
            SET     i.CentauriMemberID = r.CentauriMemberID
            FROM    CHSStaging.hedis.RawImport AS i
                    CROSS JOIN dbo.H_Client c
                    INNER JOIN CHSDV.dbo.R_Member r ON i.MEM_NBR = r.ClientMemberID
                                                      AND c.Client_BK = r.ClientID
            WHERE   ISNULL(i.MEM_NBR, '') <> '';

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;
GO
