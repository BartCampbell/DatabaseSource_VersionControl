SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	08/15/2016
-- Description:	Loads new Providers into the Provider reference table from the OEC staging tables
-- Usage:			
--		  EXECUTE oec.spUpdateOECProviderReference_112550
-- =============================================

CREATE PROCEDURE [oec].[spUpdateOECProviderReference_112550]
AS
    BEGIN

        SET NOCOUNT ON;


        BEGIN TRY

            BEGIN TRANSACTION;

            --LOAD NEW ProviderS FROM 834 STAGING
            UPDATE  s
            SET     s.CentauriProviderID = r.CentauriProviderID ,
                    s.H_Provider_RK = r.ProviderHashKey
            FROM    oec.AdvanceOECRaw_112550 s
                    INNER JOIN CHSDV.dbo.R_Provider AS r ON s.ProviderID = r.ClientProviderID
                                                            AND r.ClientID = s.ClientID

	   
            INSERT  INTO CHSDV.dbo.R_Provider
                    ( ClientID ,
                      ClientProviderID ,
                      NPI ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            s.ClientID ,
                            s.ProviderID ,
                            s.ProviderNPI ,
                            s.LoadDate ,
                            s.FileName
                    FROM    oec.AdvanceOECRaw_112550 s
                            LEFT JOIN CHSDV.dbo.R_Provider AS r ON s.ProviderID = r.ClientProviderID
                                                                   AND r.ClientID = s.ClientID
                    WHERE   r.CentauriProviderID IS NULL;


            UPDATE  s
            SET     s.CentauriProviderID = r.CentauriProviderID ,
                    s.H_Provider_RK = r.ProviderHashKey
            FROM    oec.AdvanceOECRaw_112550 s
                    INNER JOIN CHSDV.dbo.R_Provider AS r ON s.ProviderID = r.ClientProviderID
                                                            AND r.ClientID = s.ClientID


            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;




GO
