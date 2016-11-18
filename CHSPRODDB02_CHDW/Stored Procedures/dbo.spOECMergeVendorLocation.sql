SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	06/01/2016
-- Description:	merges the stage to dim for VendorLocation
-- Usage:			
--		  EXECUTE dbo.spOECMergeVendorLocation
-- =============================================
CREATE PROC [dbo].[spOECMergeVendorLocation]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.VendorLocation AS t
        USING
            ( SELECT    v.VendorID ,
                        s.Addr1 ,
                        s.City ,
                        s.State ,
                        s.Zip
              FROM      stage.VendorLocation s
                        INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                        INNER JOIN dim.Vendor v ON c.ClientID = v.ClientID
                                                   AND v.ClientVendorID = s.VendorID
            ) AS s
        ON t.VendorID = s.VendorID
            AND t.Addr1 = s.Addr1
            AND t.City = s.City
            AND t.State = s.State
            AND t.Zip = s.Zip
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( VendorID ,
                     Addr1 ,
                     City ,
                     State ,
                     Zip
                   )
            VALUES ( VendorID ,
                     Addr1 ,
                     City ,
                     State ,
                     Zip
                   );

    END;     



GO
