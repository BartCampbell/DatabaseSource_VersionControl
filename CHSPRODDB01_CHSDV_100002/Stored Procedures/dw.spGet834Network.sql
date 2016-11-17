SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =============================================
---- Author:		Travis Parker
---- Create date:	07/21/2016
---- Description:	Gets the latest 834 Network data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGet834Network '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGet834Network]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            r.CentauriNetworkID ,
            r.ClientNetworkID 
    FROM    CHSDV.dbo.R_Network r
            INNER JOIN dbo.H_Client c ON r.ClientID = c.Client_BK
            INNER JOIN dbo.S_MemberEligibility s ON r.ClientNetworkID = s.NetworkID
    WHERE   s.RecordEndDate IS NULL
            AND s.LoadDate > @LastLoadTime;


GO
