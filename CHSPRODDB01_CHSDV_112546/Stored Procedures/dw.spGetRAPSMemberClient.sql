SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---- =============================================
---- Author:		Travis Parker
---- Create date:	06/11/2016
---- Description:	Gets the latest RAPS Response MemberClient data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetRAPSMemberClient '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGetRAPSMemberClient]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            h.Member_BK AS CentauriMemberID ,
            c.Client_BK AS CentauriClientID ,
            h.ClientMemberID ,
		  h.RecordSource ,
		  h.LoadDate
    FROM    dbo.H_Member h
            INNER JOIN dbo.L_MemberRAPSResponse l ON l.H_Member_RK = h.H_Member_RK
            CROSS JOIN dbo.H_Client c
    WHERE   l.LoadDate > @LastLoadTime;

GO
