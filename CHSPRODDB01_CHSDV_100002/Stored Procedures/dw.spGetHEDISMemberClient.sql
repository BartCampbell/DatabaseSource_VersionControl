SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




---- =============================================
---- Author:		Travis Parker
---- Create date:	08/01/2016
---- Description:	Gets the latest HEDIS MemberClient data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetHEDISMemberClient '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGetHEDISMemberClient]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            h.Member_BK AS CentauriMemberID ,
            c.Client_BK AS CentauriClientID ,
            h.ClientMemberID
    FROM    dbo.H_Member h
            INNER JOIN dbo.L_MemberHEDIS l ON l.H_Member_RK = h.H_Member_RK
            CROSS JOIN dbo.H_Client c
    WHERE   l.LoadDate > @LastLoadTime;





GO
