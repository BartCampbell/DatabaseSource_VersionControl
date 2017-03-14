SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	12/29/2016
-- Description:	truncates the staging tables used for the Apixio Return load
-- Usage:			
--		  EXECUTE dw.spGetApixioReturnMember '1/1/1900'
-- =============================================
CREATE PROC [dw].[spGetApixioReturnMember] @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Member_BK AS CentauriMemberID ,
            s.FirstName ,
            s.LastName ,
            s.Gender ,
            CONVERT(INT,CONVERT(VARCHAR(10),s.DOB,112)) AS DOB ,
		  s.RecordSource ,
		  s.LoadDate ,
		  c.Client_BK AS ClientID
    FROM    dbo.H_Member h
            INNER JOIN dbo.S_MemberDemo s ON s.H_Member_RK = h.H_Member_RK
            INNER JOIN dbo.L_MemberApixioReturn l ON l.H_Member_RK = h.H_Member_RK
		  CROSS JOIN dbo.H_Client c
    WHERE   s.RecordEndDate IS NULL AND s.LoadDate > @LastLoadTime;


GO
