SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


---- =============================================
---- Author:		Travis Parker
---- Create date:	07/11/2016
---- Description:	Gets the latest HEDIS member data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetHEDISMember '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGetHEDISMember] @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Member_BK AS CentauriMemberID ,
            s.FirstName ,
            s.LastName ,
            s.Gender ,
            CONVERT(INT,CONVERT(VARCHAR(10),s.DOB,112)) AS DOB ,
		  s.RecordSource ,
		  c.Client_BK AS CentauriClientID ,
		  s.LoadDate
    FROM    dbo.H_Member h
            INNER JOIN dbo.S_MemberDemo s ON s.H_Member_RK = h.H_Member_RK
            INNER JOIN dbo.L_MemberHEDIS l ON l.H_Member_RK = h.H_Member_RK
		  CROSS JOIN dbo.H_Client c
    WHERE   s.RecordEndDate IS NULL AND s.LoadDate > @LastLoadTime;


GO
