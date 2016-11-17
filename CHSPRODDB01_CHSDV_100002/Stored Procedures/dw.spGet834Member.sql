SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =============================================
---- Author:		Travis Parker
---- Create date:	07/11/2016
---- Description:	Gets the latest 834 Response member data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGet834Member '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGet834Member] @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Member_BK AS CentauriMemberID ,
            s.FirstName ,
            s.LastName ,
            s.Gender ,
            CONVERT(INT,CONVERT(VARCHAR(10),s.DOB,112)) AS DOB
    FROM    dbo.H_Member h
            INNER JOIN dbo.S_MemberDemo s ON s.H_Member_RK = h.H_Member_RK
            INNER JOIN dbo.S_MemberEligibility l ON l.H_Member_RK = h.H_Member_RK
    WHERE   s.RecordEndDate IS NULL AND s.LoadDate > @LastLoadTime;

GO
