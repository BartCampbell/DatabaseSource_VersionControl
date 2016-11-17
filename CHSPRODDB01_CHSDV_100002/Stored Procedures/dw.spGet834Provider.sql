SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =============================================
---- Author:		Travis Parker
---- Create date:	07/21/2016
---- Description:	Gets the latest 834 Provider data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGet834Provider '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGet834Provider]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            p.Provider_BK AS CentauriProviderID,
		  d.LastName,
		  d.FirstName
    FROM    dbo.H_Provider p 
		  INNER JOIN dbo.S_ProviderDemo d ON d.H_Provider_RK = p.H_Provider_RK
            INNER JOIN dbo.S_MemberEligibility s ON p.ClientProviderID = s.ProviderID
    WHERE   d.RecordEndDate IS NULL
            AND s.LoadDate > @LastLoadTime;


GO
