SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =============================================
---- Author:		Travis Parker
---- Create date:	07/21/2016
---- Description:	Gets the latest 834 Member Location data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGet834MemberLocation '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGet834MemberLocation]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            m.Member_BK AS CentauriMemberID,
		  s.Address1 AS Addr1,
		  s.City,
		  s.State,
		  s.Zip
    FROM    dbo.H_Member m 
		  INNER JOIN dbo.L_MemberLocation l ON l.H_Member_RK = m.H_Member_RK
		  INNER JOIN dbo.S_Location s ON s.H_Location_RK = l.H_Location_RK
    WHERE   s.RecordEndDate IS NULL 
            AND s.LoadDate > @LastLoadTime;


GO
