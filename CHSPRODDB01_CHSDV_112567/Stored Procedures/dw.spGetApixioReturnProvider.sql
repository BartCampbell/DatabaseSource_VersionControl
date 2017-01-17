SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	12/29/2016
-- Description:	truncates the staging tables used for the Apixio Return load
-- Usage:			
--		  EXECUTE dw.spGetApixioReturnProvider '1/1/1900'
-- =============================================
CREATE PROC [dw].[spGetApixioReturnProvider]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            h.Provider_BK AS CentauriProviderID ,
            s.NPI ,
            s.LastName ,
            s.FirstName ,
		  s.RecordSource ,
		  s.LoadDate ,
		  c.Client_BK AS ClientID
    FROM    dbo.H_Provider h
            INNER JOIN dbo.S_ProviderDemo s ON s.H_Provider_RK = h.H_Provider_RK
            INNER JOIN dbo.L_ProviderApixioReturn l ON l.H_Provider_RK = h.H_Provider_RK
            CROSS JOIN dbo.H_Client c
    WHERE   ISNULL(h.Provider_BK,'') <> ''
            AND s.RecordEndDate IS NULL
            AND s.LoadDate > @LastLoadTime;



GO
