SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






/*
    Author: Travis Parker
    Date:	  05/12/2016
    Name:	  advance.vwClaim
    Desc:	  view of Claim data for Advance ETL
*/

CREATE VIEW [advance].[vwClaim]
AS
     SELECT
          c.Claim_Number,
		m.CentauriMemberID,
		p1.CentauriProviderID,
		p2.CentauriProviderID AS PayeeCentauriProviderID,
		cl.CentauriClientID,
		c.ClientMemberID,
		c.ICDNumber,
		c.ICDType,
		c.ICDLineNumber,
		c.ServiceFromDate,
		c.ServiceToDate,
		c.ClaimStatus     
	FROM 
	   fact.Claim c 
	   INNER JOIN dim.Member m ON c.MemberID = m.MemberID
	   INNER JOIN dim.Provider p1 ON c.ProviderID = p1.ProviderID
	   INNER JOIN dim.Provider p2 ON c.PayProviderID = p2.ProviderID
	   INNER JOIN dim.Client cl ON c.ClientID = cl.ClientID
     WHERE 
	   c.Client IN ('MAPD','DSNP')




GO
