SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


---- =============================================
---- Author:		Travis Parker
---- Create date:	10/06/2016
---- Description:	Gets the latest HEDIS data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetHEDISLinks '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGetHEDISLinks]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT 
            h.HEDIS_BK ,
		  c.Client_BK AS CentauriClientID ,
		  m.Member_BK AS CentauriMemberID ,
		  p.Provider_BK AS CentauriProviderID
    FROM    dbo.H_HEDIS h 
		  INNER JOIN dbo.S_HEDISDetail s ON s.H_HEDIS_RK = h.H_HEDIS_RK
		  LEFT JOIN dbo.L_MemberHEDIS lm ON lm.H_HEDIS_RK = h.H_HEDIS_RK 
		  LEFT JOIN dbo.H_Member m ON m.H_Member_RK = lm.H_Member_RK
		  LEFT JOIN dbo.L_ProviderHEDIS lp ON lp.H_HEDIS_RK = h.H_HEDIS_RK 
		  LEFT JOIN dbo.H_Provider p ON p.H_Provider_RK = lp.H_Provider_RK
		  CROSS JOIN dbo.H_Client c
    WHERE   s.RecordEndDate IS NULL
            AND s.LoadDate > @LastLoadTime;



GO
