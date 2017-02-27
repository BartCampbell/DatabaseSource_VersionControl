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
CREATE PROC [dw].[spGetRAPSMember] 
    @LastLoadTime DATETIME 
AS 
    SET NOCOUNT ON;  
 
    SELECT DISTINCT 
            h.Member_BK AS CentauriMemberID , 
            s.LastName , 
            s.FirstName , 
            CONVERT(VARCHAR(10),CASE s.Gender WHEN '1' THEN 'M' WHEN '2' THEN 'F' ELSE s.Gender END) AS Gender , 
            CONVERT(VARCHAR(8),s.DOB,112) AS DOB , 
            c.Client_BK AS CentauriClientID , 
            h.RecordSource , 
            ISNULL(s.LoadDate, h.LoadDate) AS LoadDate 
    FROM    dbo.H_Member h 
            INNER JOIN dbo.L_MemberRAPSResponse l ON l.H_Member_RK = h.H_Member_RK 
            LEFT JOIN dbo.S_MemberDemo s ON s.H_Member_RK = h.H_Member_RK 
            CROSS JOIN dbo.H_Client c 
    WHERE   s.RecordEndDate IS NULL 
            AND ISNULL(s.LoadDate, h.LoadDate) > @LastLoadTime; 
 
 
    
GO
