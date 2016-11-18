SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	06/01/2016
-- Description:	merges the stage to dim for Vendor
-- Usage:			
--		  EXECUTE dbo.spOECMergeVendor
-- =============================================
CREATE PROC [dbo].[spOECMergeVendor]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.Vendor AS t
        USING
            ( SELECT  DISTINCT  c.ClientID ,
                        v.VendorID ,
                        v.VendorName ,
				    v.VendorTIN ,
				    v.VendorTINName
              FROM      stage.Vendor v
                        INNER JOIN dim.Client c ON c.CentauriClientID = v.CentauriClientID
            ) AS s
        ON t.ClientID = s.ClientID
            AND t.ClientVendorID = s.VendorID
		  AND t.ClientVendorName = s.VendorName
        WHEN MATCHED AND ( ISNULL(t.TIN,'') <> ISNULL(s.VendorTIN,'') OR ISNULL(t.TINName, '') <> ISNULL(s.VendorTINName,'') ) THEN
            UPDATE SET
                    t.TIN = s.VendorTIN,
				t.TINName = s.VendorTINName,
                    t.LastUpdate = GETDATE()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( ClientID ,
                     ClientVendorID ,
                     ClientVendorName ,
				 TIN,
				 TINName
                   )
            VALUES ( s.ClientID ,
                     s.VendorID ,
                     s.VendorName,
				 s.VendorTIN,
				 s.VendorTINName
                   );

    END;     


GO
