SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dw].[spGetOECMemberHCC]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            CONVERT(BIGINT,h.Member_BK) AS CentauriMemberID ,
            CONVERT(VARCHAR(10),s.HCC) AS HCC ,
		  CONVERT(INT,c.Client_BK) AS CentauriClientID
    FROM    dbo.H_Member h
            INNER JOIN dbo.L_MemberOECProject l ON l.H_Member_RK = h.H_Member_RK 
		  INNER JOIN dbo.LS_MemberOECProjectHCC s ON s.L_MemberOECProject_RK = l.L_MemberOECProject_RK
		  CROSS JOIN dbo.H_Client c
    WHERE   s.RecordEndDate IS NULL
            AND s.LoadDate > @LastLoadTime;


GO
