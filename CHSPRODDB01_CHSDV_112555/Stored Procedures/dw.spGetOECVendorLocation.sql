SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dw].[spGetOECVendorLocation]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Vendor_BK AS VendorID ,
		  c.Client_BK AS CentauriClientID ,
            sl.Address1 ,
            sl.Address2 ,
            sl.City ,
            sl.State ,
            sl.Zip ,
            sl.County
    FROM    dbo.H_Vendor h
            INNER JOIN dbo.L_OECVendorLocation l ON l.H_Vendor_RK = h.H_Vendor_RK
            INNER JOIN dbo.H_Location hl ON hl.H_Location_RK = l.H_Location_RK
            INNER JOIN dbo.S_Location sl ON sl.H_Location_RK = hl.H_Location_RK
		  CROSS JOIN dbo.H_Client c
    WHERE   sl.RecordEndDate IS NULL
            AND sl.LoadDate > @LastLoadTime;


GO
