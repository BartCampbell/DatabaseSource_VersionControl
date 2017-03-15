SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	05/25/2016
-- Description:	Loads new Providers into the Provider reference table from the OEC staging tables
-- Usage:			
--		  EXECUTE oec.prUpdateOECProviderReference_112547
-- =============================================

CREATE PROCEDURE [oec].[prUpdateOECProviderReference_112547]
AS
    BEGIN

        SET NOCOUNT ON;


        BEGIN TRY

            BEGIN TRANSACTION;

            --LOAD NEW ProviderS FROM 834 STAGING
            UPDATE  s
            SET     s.CentauriProviderID = r.CentauriProviderID ,
                    s.H_Provider_RK = r.ProviderHashKey
            FROM    oec.AdvanceOECRaw_112547 s
                    INNER JOIN CHSDV.dbo.R_Provider AS r ON s.ProviderID = r.ClientProviderID
                                                            AND r.ClientID = s.ClientID
												AND ISNULL(s.ChaseID,'') = ISNULL(r.ChaseID,'');

            --UPDATE  s
            --SET     s.CentauriProviderID = r.CentauriProviderID
            --FROM    oec.AdvanceOECRaw_112547 s
            --        INNER JOIN CHSDV.dbo.R_Provider AS r ON s.ProviderNPI = r.NPI
            --WHERE   s.CentauriProviderID IS NULL;
		   
            INSERT  INTO CHSDV.dbo.R_Provider
                    ( ClientID ,
                      ClientProviderID ,
                      NPI ,
				  ChaseID ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            s.ClientID ,
                            s.ProviderID ,
                            s.ProviderNPI ,
					   s.ChaseID ,
                            s.LoadDate ,
                            s.FileName
                    FROM    oec.AdvanceOECRaw_112547 s
                            LEFT JOIN CHSDV.dbo.R_Provider AS r ON s.ProviderID = r.ClientProviderID
                                                                   AND r.ClientID = s.ClientID
													  AND ISNULL(s.ChaseID,'') = ISNULL(r.ChaseID,'')
                    WHERE   r.CentauriProviderID IS NULL;


            UPDATE  s
            SET     s.CentauriProviderID = r.CentauriProviderID ,
                    s.H_Provider_RK = r.ProviderHashKey
            FROM    oec.AdvanceOECRaw_112547 s
                    INNER JOIN CHSDV.dbo.R_Provider AS r ON s.ProviderID = r.ClientProviderID
                                                            AND r.ClientID = s.ClientID
												AND ISNULL(s.ChaseID,'') = ISNULL(r.ChaseID,'');


            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;


GO
