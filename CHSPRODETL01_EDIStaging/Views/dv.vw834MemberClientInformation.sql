SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dv].[vw834MemberClientInformation]
AS
     SELECT 
		RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS RecordSource,
		m.MemberHashKey AS H_Member_RK,
		h.ClientHashKey AS H_Client_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(h.CentauriClientID, '')))))), 2)) AS L_MemberClient_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(h.CentauriClientID, ''))), ':', RTRIM(LTRIM(COALESCE(n.[09], '')))))), 2)) AS LS_MemberClient_RK,
          m.CentauriMemberID AS Member_BK,
		CONVERT(VARCHAR(80),n.[09]) AS MemberID
     FROM  dbo.NM1 AS n
		 INNER JOIN dbo.Interchange i ON n.InterchangeId = i.Id
		 INNER JOIN cfg.TradingPartnerFile t ON i.SenderId = t.SenderID AND i.ReceiverId = t.ReceiverID
		 INNER JOIN CHSDV.dbo.R_Client h ON t.TradingPartner = h.ClientName
		 INNER JOIN CHSDV.dbo.R_Member m ON n.[09] = m.ClientMemberID
           LEFT JOIN X12CodeList AS nx1 ON n.[01] = nx1.Code
                                           AND nx1.ElementId = 98
     WHERE nx1.Definition = 'Insured or Subscriber'
     GROUP BY
          h.CentauriClientID,
		h.ClientHashKey,
		n.[09],
		m.CentauriMemberID,
		m.MemberHashKey,
		i.Filename



GO
