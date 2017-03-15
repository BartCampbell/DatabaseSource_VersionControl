SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dv].[vw834MemberProviderInformation]
AS
     SELECT 
		h.CentauriClientID,
		RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS RecordSource,
		m.MemberHashKey AS H_Member_RK,
		h.ClientHashKey AS H_Client_RK,
		p.CentauriProviderID AS Provider_BK, 
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(h.CentauriClientID, '')))))), 2)) AS L_MemberClient_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(h.CentauriClientID, ''))), ':', RTRIM(LTRIM(COALESCE(n.[09], '')))))), 2)) AS LS_MemberClient_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(p.CentauriProviderID, ''))))), 2)) AS H_Provider_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(p.CentauriProviderID, '')))))), 2)) AS L_MemberProvider_RK,
          CONVERT(VARCHAR(80),RIGHT(RTRIM(n2.[09]),LEN(RTRIM(n2.[09])) - CHARINDEX(' ',RTRIM(n2.[09])))) AS NetworkID,
		dbo.ufn_parsefind(REPLACE(n2.[09], ' ', ':'), ':', 1) AS ProviderID,
		m.CentauriMemberID AS Member_BK,
		l.ParentLoopID
     FROM  dbo.NM1 AS n
		 INNER JOIN dbo.Interchange i ON n.InterchangeId = i.Id
		 INNER JOIN cfg.TradingPartnerFile t ON i.SenderId = t.SenderID AND i.ReceiverId = t.ReceiverID
		 INNER JOIN CHSDV.dbo.R_Client h ON t.TradingPartner = h.ClientName
		 INNER JOIN CHSDV.dbo.R_Member m ON n.[09] = m.ClientMemberID
           INNER JOIN dbo.LoopParent AS l ON n.LoopId = l.LoopID
           INNER JOIN X12CodeList AS nx1 ON n.[01] = nx1.Code AND nx1.ElementId = 98
		 INNER JOIN dbo.NM1 AS n2 ON n.InterchangeId = n2.InterchangeId AND n.TransactionSetId = n2.TransactionSetId
		 INNER JOIN dbo.LoopParent AS l2 ON n2.ParentLoopId = l2.LoopID AND l2.ParentLoopId = l.ParentLoopId
		 INNER JOIN X12CodeList AS nx2 ON n2.[01] = nx2.Code AND nx2.ElementId = 98
		 INNER JOIN CHSDV.dbo.R_Provider p ON h.CentauriClientID = p.ClientID AND dbo.ufn_parsefind(REPLACE(n2.[09], ' ', ':'), ':', 1) = p.ClientProviderID
	WHERE nx1.Definition = 'Insured or Subscriber' AND nx2.Definition = 'Primary Care Provider' AND n2.[03] <> ''
     GROUP BY
          h.CentauriClientID,
		h.ClientHashKey,
		n.[09],
		n2.[09],
		m.CentauriMemberID,
		p.CentauriProviderID,
		m.MemberHashKey,
		i.Filename,
		l.ParentLoopID




GO
