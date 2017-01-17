SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dw].[spGetOECVendorContact]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Vendor_BK AS VendorID ,
		  c.Client_BK AS CentauriClientID ,
            sl.Phone,
		  sl.Fax
    FROM    dbo.H_Vendor h
            INNER JOIN dbo.L_OECVendorContact l ON l.H_Vendor_RK = h.H_Vendor_RK
            INNER JOIN dbo.H_Contact hl ON hl.H_Contact_RK = l.H_Contact_RK
            INNER JOIN dbo.S_Contact sl ON sl.H_Contact_RK = hl.H_Contact_RK
		  CROSS JOIN dbo.H_Client c
    WHERE   sl.RecordEndDate IS NULL
            AND sl.LoadDate > @LastLoadTime;



GO
