SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
    Author: Travis Parker
    Date:	  05/14/2016
    Name:	  advance.vwMemberEligibility
    Desc:	  view of Member Eligibility data for Advance ETL
*/

CREATE VIEW [advance].[vwMemberEligibility]
AS
     SELECT
          CentauriMemberID,
          me.GroupEffectiveDate,
          RTRIM(me.Payor) Payor,
          me.EffectiveStartDate,
          me.EffectiveEndDate
     FROM dim.Member AS m
          INNER JOIN fact.MemberEligibility AS me ON m.MemberID = me.MemberID
     WHERE Payor IN ('DSNP','MAPD') --MA only

GO
