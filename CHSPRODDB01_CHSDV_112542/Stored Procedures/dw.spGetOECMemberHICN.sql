SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dw].[spGetOECMemberHICN]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            h.Member_BK AS CentauriMemberID ,
            s.HICNumber
    FROM    dbo.H_Member h
            INNER JOIN dbo.S_MemberHICN s ON s.H_Member_RK = h.H_Member_RK
            INNER JOIN dbo.L_MemberOEC l ON l.H_Member_RK = h.H_Member_RK
    WHERE   s.RecordEndDate IS NULL
            AND s.LoadDate > @LastLoadTime;

GO
