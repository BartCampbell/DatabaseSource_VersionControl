SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


---- =============================================
---- Author:		Travis Parker
---- Create date:	08/01/2016
---- Description:	Gets the latest MMR member data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetMMRMember '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGetMMRMember] @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Member_BK AS CentauriMemberID ,
		  s.First_Initial ,
            s.Last_Name ,
            CONVERT(VARCHAR(10),s.Gender) AS Gender ,
            CONVERT(INT,CONVERT(VARCHAR(10),s.Birth_Date,112)) AS DOB ,
		  MAX(s.RecordSource) AS RecordSource ,
		  c.Client_BK AS CentauriClientID ,
		  MAX(s.LoadDate) AS LoadDate
    FROM    dbo.H_Member h
            INNER JOIN dbo.L_Member_MMR l ON l.H_Member_RK = h.H_Member_RK
		  INNER JOIN dbo.S_MMRDetail s ON s.H_MMR_RK = l.H_MMR_RK
		  CROSS JOIN dbo.H_Client c
    WHERE   s.RecordEndDate IS NULL AND s.LoadDate > @LastLoadTime
    GROUP BY h.Member_BK, s.First_Initial, s.Last_Name, CONVERT(VARCHAR(10),s.Gender), CONVERT(INT,CONVERT(VARCHAR(10),s.Birth_Date,112)), c.Client_BK



GO
