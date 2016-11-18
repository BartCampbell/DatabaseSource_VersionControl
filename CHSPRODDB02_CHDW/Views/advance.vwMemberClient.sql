SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*
    Author: Travis Parker
    Date:	  05/15/2016
    Name:	  advance.vwMemberClient
    Desc:	  view of ClientMemberIDs data for Advance ETL
*/

CREATE VIEW [advance].[vwMemberClient]
AS
     SELECT DISTINCT
          m.CentauriMemberID,
		c.CentauriClientID,
		mc.ClientMemberID
     FROM dim.Member AS m
          INNER JOIN dim.MemberClient mc ON m.MemberID = mc.MemberID 
		INNER JOIN dim.Client c ON mc.ClientID = c.ClientID

GO
