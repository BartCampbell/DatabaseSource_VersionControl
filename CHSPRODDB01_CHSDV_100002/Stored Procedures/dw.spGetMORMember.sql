SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- =============================================
---- Author:		Travis Parker
---- Create date:	07/27/2016
---- Description:	Gets the latest MOR member data for loading into the DW
---- Usage:			
----		  EXECUTE dw.spGetMORMember '06/10/2016'
---- =============================================
CREATE PROC [dw].[spGetMORMember] @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            h.Member_BK AS CentauriMemberID ,
		  s.FirstName ,
            s.LastName ,
		  s.MiddleInitial ,
            CONVERT(VARCHAR(10),CASE s.Gender WHEN '1' THEN 'M' WHEN '2' THEN 'F' ELSE s.Gender END) AS Gender ,
            YEAR(CONVERT(DATETIME,LTRIM(RTRIM(s.DOB)))) * 10000 + MONTH(CONVERT(DATETIME,LTRIM(RTRIM(s.DOB)))) * 100 + DAY(CONVERT(DATETIME,LTRIM(RTRIM(s.DOB)))) AS DOB,
		  s.RecordSource ,
		  c.Client_BK AS CentauriClientID ,
		  s.LoadDate
    FROM    dbo.H_Member h
            INNER JOIN dbo.L_Member_MOR l ON l.H_Member_RK = h.H_Member_RK
		  INNER JOIN dbo.S_MemberDemo s ON s.H_Member_RK = h.H_Member_RK
		  CROSS JOIN dbo.H_Client c
    WHERE   s.RecordEndDate IS NULL  AND s.LoadDate > @LastLoadTime



GO
