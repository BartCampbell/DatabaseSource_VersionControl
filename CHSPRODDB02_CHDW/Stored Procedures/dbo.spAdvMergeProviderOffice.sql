SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
--Udpate 10/04/2016 Removing update PJ
-- Description:	merges the stage to dim for advance ProviderOffice based on spOECMergeProvider
-- Usage:			
--		  EXECUTE dbo.spAdvMergeProviderOffice
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeProviderOffice]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN

	
        MERGE INTO dim.ProviderOffice AS t
        USING
            ( SELECT    DISTINCT
                        m.ProviderID ,
                        a.CentauriProviderOfficeID ,
                        a.CentauriProviderID
				    FROM      stage.ProviderOffice_ADV a
                        INNER JOIN dim.Provider m ON m.CentauriProviderID = a.CentauriProviderID
            ) AS s
        ON t.CentauriProviderOfficeID = s.CentauriProviderOfficeID AND t.CentauriProviderID = s.CentauriProviderID
        --WHEN MATCHED  THEN
        --    UPDATE SET
        --            t.ProviderID = s.ProviderID ,
        --            t.CentauriProviderOfficeID = s.CentauriProviderOfficeID ,
        --            t.CentauriProviderID = s.CentauriProviderID ,
        --            t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ProviderID ,
                     CentauriProviderOfficeID ,
                     CentauriProviderID 
                   )
            VALUES ( ProviderID ,
                     CentauriProviderOfficeID ,
                     CentauriProviderID
                   );

    END;     
GO
