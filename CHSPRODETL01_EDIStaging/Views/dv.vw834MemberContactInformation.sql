SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dv].[vw834MemberContactInformation]
AS
     SELECT 
		RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS RecordSource,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(c.ContactType1, ''))), ':', RTRIM(LTRIM(COALESCE(c.Contact1, ''))), ':', RTRIM(LTRIM(COALESCE(c.ContactType2, ''))), ':', RTRIM(LTRIM(COALESCE(c.Contact2, ''))), ':', RTRIM(LTRIM(COALESCE(c.ContactType3, ''))), ':', RTRIM(LTRIM(COALESCE(c.Contact3, '')))))), 2)) AS H_Contact_RK,
		CONVERT(VARCHAR(2268),CONCAT(c.ContactType1, c.Contact1, c.ContactType2, c.Contact2, c.ContactType3, c.Contact3)) AS Contact_BK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(c.ContactType1, ''))), ':', RTRIM(LTRIM(COALESCE(c.Contact1, ''))), ':', RTRIM(LTRIM(COALESCE(c.ContactType2, ''))), ':', RTRIM(LTRIM(COALESCE(c.Contact2, ''))), ':', RTRIM(LTRIM(COALESCE(c.ContactType3, ''))), ':', RTRIM(LTRIM(COALESCE(c.Contact3, '')))))), 2)) AS L_MemberContact_RK,
		m.MemberHashKey AS H_Member_RK,
		m.CentauriMemberID,
		CONVERT(VARCHAR(256),c.Contact1) Contact1,
		c.ContactType1,
		CONVERT(VARCHAR(256),c.Contact2) Contact2,
		c.ContactType2,
		CONVERT(VARCHAR(256),c.Contact3) Contact3,
		c.ContactType3
     FROM  dbo.NM1 AS n
		 INNER JOIN dbo.Interchange i ON n.InterchangeId = i.Id
		 INNER JOIN cfg.TradingPartnerFile t ON i.SenderId = t.SenderID AND i.ReceiverId = t.ReceiverID
		 INNER JOIN CHSDV.dbo.R_Client h ON t.TradingPartner = h.ClientName
		 INNER JOIN CHSDV.dbo.R_Member m ON n.[09] = m.ClientMemberID
           LEFT JOIN dbo.Loop AS l ON n.LoopId = l.Id
           LEFT JOIN X12CodeList AS nx1 ON n.[01] = nx1.Code
                                           AND nx1.ElementId = 98
		 LEFT JOIN dv.vw834CommNumbers c ON c.ParentLoopID = l.ParentLoopId AND n.InterchangeId = c.InterchangeId and n.TransactionSetId = c.TransactionSetId AND c.MemberContact = 'Insured Party'
     WHERE nx1.Definition = 'Insured or Subscriber' 
		 AND COALESCE(c.Contact1, c.Contact2, c.Contact3, 'EMPTY') <> 'EMPTY'
     GROUP BY
          h.CentauriClientID,
		h.ClientHashKey,
		m.CentauriMemberID,
		m.MemberHashKey,
		i.Filename,
		c.Contact1,
		c.ContactType1,
		c.Contact2,
		c.ContactType2,
		c.Contact3,
		c.ContactType3



GO
