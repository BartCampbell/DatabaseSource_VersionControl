SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =============================================
---- Author:		Travis Parker
---- Create date:	07/21/2016
---- Description:	Gets the latest 834 Member Contact data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGet834MemberContact '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGet834MemberContact]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            m.Member_BK AS CentauriMemberID,
		  s.Contact1 AS Phone
    FROM    dbo.H_Member m 
		  INNER JOIN dbo.L_MemberContact l ON l.H_Member_RK = m.H_Member_RK
		  INNER JOIN dbo.S_Contact_834 s ON s.H_Contact_RK = l.H_Contact_RK
    WHERE   s.RecordEndDate IS NULL AND LEN(s.Contact1) > 1
            AND s.LoadDate > @LastLoadTime;


GO
