SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	10/04/2016
--Update 10/19/2016 based on oec.prUpdateOECProviderReference_112542_001_20Add PJ
-- Description:	Loads new Providers into the Provider reference table from the OEC staging tables
-- Usage:			
--		  EXECUTE oec.prUpdateOECProviderReference_112542_001_13Add
-- =============================================

Create PROCEDURE [oec].[prUpdateOECProviderReference_112542_001_13Add]
AS
    BEGIN

        SET NOCOUNT ON;


        BEGIN TRY

            BEGIN TRANSACTION;

            --LOAD NEW ProviderS FROM 834 STAGING
		  UPDATE  s
            SET     s.CentauriProviderID = r.CentauriProviderID ,
                    s.H_Provider_RK = r.ProviderHashKey
            FROM    oec.AdvanceOECRaw_112542_001_13Add s
                    INNER JOIN CHSDV.dbo.R_Provider AS r ON r.ClientID = s.ClientID
                                                            AND s.CentauriChaseID = ISNULL(r.ChaseID, '');

		   
            INSERT  INTO CHSDV.dbo.R_Provider
                    ( ClientID ,
                      ChaseID ,
				  NPI ,
				  --TIN ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT
                            s.ClientID ,
                            s.CentauriChaseID ,
					   s.ProviderNPI ,
					   --s.ProviderTIN ,
                            s.LoadDate ,
                            s.FileName
                    FROM    oec.AdvanceOECRaw_112542_001_13Add s
                            LEFT JOIN CHSDV.dbo.R_Provider AS r ON r.ClientID = s.ClientID
                                                                   AND s.CentauriChaseID = ISNULL(r.ChaseID, '')
                    WHERE   r.CentauriProviderID IS NULL;--482


            UPDATE  s
            SET     s.CentauriProviderID = r.CentauriProviderID ,
                    s.H_Provider_RK = r.ProviderHashKey
            FROM    oec.AdvanceOECRaw_112542_001_13Add s
                    INNER JOIN CHSDV.dbo.R_Provider AS r ON r.ClientID = s.ClientID
                                                            AND s.CentauriChaseID = ISNULL(r.ChaseID, '');

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;





GO
