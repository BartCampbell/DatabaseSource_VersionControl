SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	12/29/2016
-- Description:	truncates the staging tables used for the Apixio Return load
-- Usage:			
--		  EXECUTE dw.spGetApixioReturnProviderClient '1/1/1900'
-- =============================================
CREATE PROC [dw].[spGetApixioReturnProviderClient]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            h.Provider_BK AS CentauriProviderID ,
            c.Client_BK AS CentauriClientID ,
            h.ClientProviderID ,
		  l.RecordSource ,
		  l.LoadDate ,
		  c.Client_BK AS ClientID
    FROM    dbo.H_Provider h
            INNER JOIN dbo.L_ProviderApixioReturn l ON l.H_Provider_RK = h.H_Provider_RK
		  CROSS JOIN dbo.H_Client c 
    WHERE   l.LoadDate > @LastLoadTime;


GO
