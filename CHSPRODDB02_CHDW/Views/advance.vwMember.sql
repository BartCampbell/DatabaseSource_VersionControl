SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






/*
    Author: Travis Parker
    Date:	  05/12/2016
    Name:	  advance.vwMember
    Desc:	  view of Member data for Advance ETL
*/

CREATE VIEW [advance].[vwMember]
AS
     SELECT
          m.CentauriMemberID,
          m.LastName,
          m.FirstName,
          m.Gender,
          m.DOB
     FROM dim.Member AS m
	WHERE m.MemberID > 0;





GO
