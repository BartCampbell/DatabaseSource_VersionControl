SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	05/04/2016
-- Description:	Loads new providers into the network reference table from the 834 staging table
-- Usage:			
--		  EXECUTE dbo.prUpdate834NetworkReference 'FileName'
-- =============================================

CREATE PROCEDURE [dbo].[prUpdate834NetworkReference]
    @RecordSource VARCHAR(255)
AS
    BEGIN

        SET NOCOUNT ON;


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
                            c.CentauriClientID ,
                            RIGHT(RTRIM(i.ProviderInfo_IdentificationCode_NM109),
                                  LEN(RTRIM(i.ProviderInfo_IdentificationCode_NM109)) - CHARINDEX(' ', RTRIM(i.ProviderInfo_IdentificationCode_NM109))) AS ClientNetworkID ,
                            GETDATE() AS LoadDate ,
                            @RecordSource
                    FROM    CHSStaging.dbo.X12_834_RawImport i
                            INNER JOIN CHSStaging.dbo.TradingPartnerFile t ON i.FileLevelDetail_SenderID_GS02 = t.SenderID
                                                                              AND i.FileLevelDetail_ReceiverID_GS03 = t.ReceiverID
                            INNER JOIN CHSDV.dbo.R_Client AS c ON t.TradingPartner = c.ClientName
                            LEFT JOIN CHSDV.dbo.R_Network r ON RIGHT(RTRIM(i.ProviderInfo_IdentificationCode_NM109),
                                                                     LEN(RTRIM(i.ProviderInfo_IdentificationCode_NM109)) - CHARINDEX(' ',
                                                                                                                                     RTRIM(i.ProviderInfo_IdentificationCode_NM109))) = r.ClientNetworkID
                                                               AND c.CentauriClientID = r.ClientID
                    WHERE   ISNULL(RIGHT(RTRIM(i.ProviderInfo_IdentificationCode_NM109),
                                         LEN(RTRIM(i.ProviderInfo_IdentificationCode_NM109)) - CHARINDEX(' ', RTRIM(i.ProviderInfo_IdentificationCode_NM109))),
                                   '') NOT IN  ('','NULL')
                            AND r.CentauriNetworkID IS NULL;

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;
GO
