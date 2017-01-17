SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dw].[spGetOECVendor]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Vendor_BK AS VendorID ,
		  c.Client_BK AS CentauriClientID ,
            s.Name AS VendorName
    FROM    dbo.H_Vendor h
            INNER JOIN dbo.L_OECVendorLocation l ON l.H_Vendor_RK = h.H_Vendor_RK
		  INNER JOIN dbo.S_Vendor s ON h.H_Vendor_RK = s.H_Vendor_RK
		  CROSS JOIN dbo.H_Client c
    WHERE   s.RecordEndDate IS NULL
            AND s.LoadDate > @LastLoadTime;




GO
