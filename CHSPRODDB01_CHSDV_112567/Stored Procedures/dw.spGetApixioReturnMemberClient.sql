SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	12/29/2016
-- Description:	truncates the staging tables used for the Apixio Return load
-- Usage:			
--		  EXECUTE dw.spGetApixioReturnMemberClient '1/1/1900'
-- =============================================
CREATE PROC [dw].[spGetApixioReturnMemberClient]
    @LastLoadTime DATETIME
AS
    SET NOCOUNT ON; 

    SELECT  DISTINCT
            h.Member_BK AS CentauriMemberID ,
            c.Client_BK AS CentauriClientID ,
            h.ClientMemberID ,
		  l.RecordSource ,
		  l.LoadDate ,
		  c.Client_BK AS ClientID
    FROM    dbo.H_Member h
            INNER JOIN dbo.L_MemberApixioReturn l ON l.H_Member_RK = h.H_Member_RK
            CROSS JOIN dbo.H_Client c
    WHERE   l.LoadDate > @LastLoadTime;




GO
