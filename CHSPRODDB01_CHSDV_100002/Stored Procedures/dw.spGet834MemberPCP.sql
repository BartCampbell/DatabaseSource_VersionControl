SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =============================================
---- Author:		Travis Parker
---- Create date:	07/21/2016
---- Description:	Gets the latest 834 Member PCP data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGet834MemberPCP '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGet834MemberPCP]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            m.Member_BK AS CentauriMemberID,
		  p.Provider_BK AS CentauriProviderID,
		  s.PCPEffectiveDate
    FROM    dbo.H_Member m 
		  INNER JOIN dbo.L_MemberProvider l ON l.H_Member_RK = m.H_Member_RK
		  INNER JOIN dbo.H_Provider p ON p.H_Provider_RK = l.H_Provider_RK
		  INNER JOIN dbo.LS_MemberProvider s ON s.L_MemberProvider_RK = l.L_MemberProvider_RK
    WHERE   s.RecordEndDate IS NULL 
            AND s.LoadDate > @LastLoadTime;


GO
