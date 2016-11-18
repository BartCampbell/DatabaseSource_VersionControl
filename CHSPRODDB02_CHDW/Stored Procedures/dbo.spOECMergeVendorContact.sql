SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	06/01/2016
-- Description:	merges the stage to dim for VendorContact
-- Usage:			
--		  EXECUTE dbo.spOECMergeVendorContact
-- =============================================
CREATE PROC [dbo].[spOECMergeVendorContact]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.VendorContact AS t
        USING
            ( SELECT    v.VendorID ,
                        s.Phone ,
                        s.Fax
              FROM      stage.VendorContact s
                        INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                        INNER JOIN dim.Vendor v ON c.ClientID = v.ClientID
                                                   AND v.ClientVendorID = s.VendorID
            ) AS s
        ON t.VendorID = s.VendorID
            AND t.Phone = s.Phone
            AND t.Fax = s.Fax
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( VendorID, Phone, Fax )
            VALUES ( VendorID, Phone, Fax );

    END;     



GO
