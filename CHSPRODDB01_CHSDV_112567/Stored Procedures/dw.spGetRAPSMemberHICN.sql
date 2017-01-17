SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---- =============================================
---- Author:		Travis Parker
---- Create date:	06/11/2016
---- Description:	Gets the latest RAPS Response member HICN data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetRAPSMemberHICN '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGetRAPSMemberHICN] @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Member_BK AS CentauriMemberID ,
		  s.HICNumber
    FROM    dbo.H_Member h
            INNER JOIN dbo.L_MemberRAPSResponse l ON l.H_Member_RK = h.H_Member_RK
		  INNER JOIN dbo.S_MemberHICN s ON s.H_Member_RK = h.H_Member_RK
    WHERE   s.RecordEndDate IS NULL AND s.LoadDate > @LastLoadTime;


GO
