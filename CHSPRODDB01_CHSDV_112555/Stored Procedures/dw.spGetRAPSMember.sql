SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---- =============================================
---- Author:		Travis Parker
---- Create date:	06/11/2016
---- Description:	Gets the latest RAPS Response member data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetRAPSMember '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGetRAPSMember] @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Member_BK AS CentauriMemberID 
    FROM    dbo.H_Member h
            INNER JOIN dbo.L_MemberRAPSResponse l ON l.H_Member_RK = h.H_Member_RK
    WHERE   l.RecordEndDate IS NULL AND h.LoadDate > @LastLoadTime;


GO
