SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- =============================================
-- Author:		Travis Parker
-- Create date:	08/15/2016
-- Description:	Loads new Networks into the network reference table from the OEC staging tables
-- Usage:			
--		  EXECUTE oec.spUpdateOECNetworkReference_112550
-- =============================================

CREATE PROCEDURE [oec].[spUpdateOECNetworkReference_112550]
AS
    BEGIN

        SET NOCOUNT ON;


        BEGIN TRY

            BEGIN TRANSACTION;

            --LOAD NEW Networks FROM OEC STAGING
            UPDATE  s
            SET     s.CentauriNetworkID = r.CentauriNetworkID,
				s.H_Network_RK = r.NetworkHashKey
            FROM    oec.AdvanceOECRaw_112550 s
                    INNER JOIN CHSDV.dbo.R_Network AS r ON s.ProviderGroupID = r.ClientNetworkID
                                                          AND r.ClientID = s.ClientID;

            INSERT  INTO CHSDV.dbo.R_Network
                    ( ClientID ,
                      ClientNetworkID ,
                      LoadDate ,
                      RecordSource
                    )
                    SELECT DISTINCT  
					   s.ClientID ,
                            s.ProviderGroupID ,
                            s.LoadDate ,
                            s.FileName
                    FROM    oec.AdvanceOECRaw_112550 s
                            LEFT JOIN CHSDV.dbo.R_Network AS r ON s.ProviderGroupID = r.ClientNetworkID
                                                              AND r.ClientID = s.ClientID
                    WHERE   r.CentauriNetworkID IS NULL AND ISNULL(s.ProviderGroupID,'') <> '';


            UPDATE  s
            SET     s.CentauriNetworkID = r.CentauriNetworkID,
				s.H_Network_RK = r.NetworkHashKey
            FROM    oec.AdvanceOECRaw_112550 s
                    INNER JOIN CHSDV.dbo.R_Network AS r ON s.ProviderGroupID = r.ClientNetworkID
                                                          AND r.ClientID = s.ClientID;


            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;




GO
