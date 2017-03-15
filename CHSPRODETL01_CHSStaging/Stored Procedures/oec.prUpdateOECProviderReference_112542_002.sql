SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	09/17/2016
-- Description:	Loads new Providers into the Provider reference table from the OEC staging tables
-- Usage:			
--		  EXECUTE oec.prUpdateOECProviderReference_112542_002
-- =============================================

CREATE PROCEDURE [oec].[prUpdateOECProviderReference_112542_002]
AS
    BEGIN

        SET NOCOUNT ON;


        BEGIN TRY

            BEGIN TRANSACTION;

            --LOAD NEW ProviderS FROM 834 STAGING
            UPDATE  s
            SET     s.CentauriProviderID = r.CentauriProviderID ,
                    s.H_Provider_RK = r.ProviderHashKey
            FROM    oec.AdvanceOECRaw_112542_002 s
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
                    FROM    oec.AdvanceOECRaw_112542_002 s
                            LEFT JOIN CHSDV.dbo.R_Provider AS r ON r.ClientID = s.ClientID
                                                                   AND s.CentauriChaseID = ISNULL(r.ChaseID, '')
                    WHERE   r.CentauriProviderID IS NULL;--3990


            UPDATE  s
            SET     s.CentauriProviderID = r.CentauriProviderID ,
                    s.H_Provider_RK = r.ProviderHashKey
            FROM    oec.AdvanceOECRaw_112542_002 s
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
