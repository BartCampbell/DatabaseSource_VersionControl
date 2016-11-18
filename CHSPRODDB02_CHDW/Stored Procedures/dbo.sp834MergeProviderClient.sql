SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	07/21/2016
-- Description:	merges the stage to dim for ProviderClient
-- Usage:			
--		  EXECUTE dbo.sp834MergeProviderClient
-- =============================================
CREATE PROC [dbo].[sp834MergeProviderClient]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.ProviderClient
                ( ProviderID ,
                  ClientID ,
                  ClientProviderID,
			   RecordStartDate,
			   RecordEndDate
	           )
                SELECT DISTINCT
                        m.ProviderID ,
                        c.ClientID ,
                        s.ClientProviderID,
				    @CurrentDate,
				    '2999-12-31 00:00:00.000'
                FROM    stage.ProviderClient s
                        INNER JOIN dim.Provider m ON m.CentauriProviderID = s.CentauriProviderID
                        INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                        LEFT JOIN dim.ProviderClient mc ON mc.ClientID = c.ClientID
                                                         AND mc.ProviderID = m.ProviderID
                                                         AND mc.ClientProviderID = s.ClientProviderID
                WHERE   mc.ProviderClientID IS NULL;

			 

        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.ProviderClient s
                INNER JOIN dim.Provider m ON m.CentauriProviderID = s.CentauriProviderID
                INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                INNER JOIN dim.ProviderClient mc ON mc.ClientID = c.ClientID
                                                  AND mc.ProviderID = m.ProviderID
        WHERE   mc.ClientProviderID <> s.ClientProviderID AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     



GO
