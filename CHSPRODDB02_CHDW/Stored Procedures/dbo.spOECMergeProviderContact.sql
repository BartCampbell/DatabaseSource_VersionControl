SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	06/01/2016
-- Description:	merges the stage to dim for ProviderContact
-- Usage:			
--		  EXECUTE dbo.spOECMergeProviderContact
-- =============================================
CREATE PROC [dbo].[spOECMergeProviderContact]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.ProviderContact AS t
        USING
            ( SELECT    p.ProviderID ,
                        s.Phone ,
                        s.Fax
              FROM      stage.ProviderContact s
                        INNER JOIN dim.Provider p ON p.CentauriProviderID = s.CentauriProviderID
            ) AS s
        ON t.ProviderID = s.ProviderID
            AND t.Phone = s.Phone
            AND t.Fax = s.Fax
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ProviderID, Phone, Fax )
            VALUES ( ProviderID, Phone, Fax );

    END;     



GO
