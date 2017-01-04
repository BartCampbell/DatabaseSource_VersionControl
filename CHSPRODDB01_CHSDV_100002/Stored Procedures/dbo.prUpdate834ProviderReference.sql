SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	05/04/2016
-- Description:	Loads new providers into the provider reference table from the 834 staging table
-- Usage:			
--		  EXECUTE dbo.prUpdate834ProviderReference 'FileName'
-- =============================================

CREATE PROCEDURE [dbo].[prUpdate834ProviderReference]
    @RecordSource VARCHAR(255)
AS
    BEGIN

        SET NOCOUNT ON;


        BEGIN TRY

            BEGIN TRANSACTION;

             --LOAD NEW PROVIDERS FROM 834 STAGING
            IF OBJECT_ID('tempdb..#NewProviders') IS NOT NULL
                DROP TABLE #NewProviders;

            SELECT DISTINCT
                    c.CentauriClientID ,
                    dbo.ufn_parsefind(REPLACE(i.ProviderInfo_IdentificationCode_NM109, ' ', ':'), ':', 1) AS ClientProviderID
            INTO    #NewProviders
            FROM    CHSStaging.dbo.X12_834_RawImport i
                    INNER JOIN CHSStaging.dbo.TradingPartnerFile AS t ON i.FileLevelDetail_SenderID_GS02 = t.SenderID
                                                                         AND i.FileLevelDetail_ReceiverID_GS03 = t.ReceiverID
                    INNER JOIN CHSDV.dbo.R_Client AS c ON t.TradingPartner = c.ClientName
            WHERE   ISNULL(dbo.ufn_parsefind(REPLACE(i.ProviderInfo_IdentificationCode_NM109, ' ', ':'), ':', 1), '') NOT IN ( '', 'NULL' );


            INSERT  INTO CHSDV.dbo.R_Provider
                    ( ClientID ,
                      ClientProviderID ,
                      RecordSource ,
                      LoadDate
                    )
                    SELECT  p.CentauriClientID ,
                            p.ClientProviderID ,
                            @RecordSource ,
                            GETDATE()
                    FROM    #NewProviders AS p
                            LEFT JOIN CHSDV.dbo.R_Provider AS r ON p.CentauriClientID = r.ClientID
                                                                   AND p.ClientProviderID = r.ClientProviderID
                    WHERE   r.CentauriProviderID IS NULL;


            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;
GO
