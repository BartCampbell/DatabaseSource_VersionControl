SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dw].[spGetOECProviderContact]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Provider_BK AS CentauriProviderID ,
            sl.Phone,
		  sl.Fax
    FROM    dbo.H_Provider h
            INNER JOIN dbo.L_OECProviderContact l ON l.H_Provider_RK = h.H_Provider_RK
            INNER JOIN dbo.H_Contact hl ON hl.H_Contact_RK = l.H_Contact_RK
            INNER JOIN dbo.S_Contact sl ON sl.H_Contact_RK = hl.H_Contact_RK
    WHERE   sl.RecordEndDate IS NULL
            AND sl.LoadDate > @LastLoadTime;


GO
