SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
-- Description:	merges the stage to dim for ProviderClient based on spOECMergeProviderClient
-- Usage:			
--		  EXECUTE dbo.spAdvMergeProviderClient
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeProviderClient]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.ProviderClient
                ( ProviderID ,
                  ClientID ,
                  ClientProviderID
	           )
                SELECT DISTINCT
                        m.ProviderID ,
                        c.ClientID ,
                        s.ClientProviderID
                 FROM    stage.ProviderClient_ADV s
                        INNER JOIN dim.Provider m ON m.CentauriProviderID = s.CentauriProviderID
                        INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                        LEFT JOIN dim.ProviderClient mc ON mc.ClientID = c.ClientID
                                                         AND mc.ProviderID = m.ProviderID
                                                         AND mc.ClientProviderID = s.ClientProviderID
                WHERE   mc.ProviderClientID IS NULL;



        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.ProviderClient_ADV s
                INNER JOIN dim.Provider m ON m.CentauriProviderID = s.CentauriProviderID
                INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                INNER JOIN dim.ProviderClient mc ON mc.ClientID = c.ClientID
                                                  AND mc.ProviderID = m.ProviderID
        WHERE   mc.ClientProviderID <> s.ClientProviderID;

    END;     


GO
