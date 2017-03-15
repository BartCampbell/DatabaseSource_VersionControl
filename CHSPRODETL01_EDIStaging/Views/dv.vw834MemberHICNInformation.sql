SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dv].[vw834MemberHICNInformation]
AS
     SELECT 
		RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS RecordSource,
		i.CreatedDate AS LoadDate,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(r.ReferenceValue, ''))))), 2)) AS HashDiff,
		UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1),''))),':',RTRIM(LTRIM(COALESCE(i.CreatedDate,''))),':',RTRIM(LTRIM(COALESCE(m.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(r.ReferenceValue,'')))))),2)) AS S_MemberHICN_RK,
		m.MemberHashKey AS H_Member_RK,
		m.CentauriMemberID AS Member_BK,
		CONVERT(VARCHAR(80),r.ReferenceValue) AS HICN
     FROM  dbo.NM1 AS n
		 INNER JOIN dbo.Interchange i ON n.InterchangeId = i.Id
		 INNER JOIN cfg.TradingPartnerFile t ON i.SenderId = t.SenderID AND i.ReceiverId = t.ReceiverID
		 INNER JOIN CHSDV.dbo.R_Client h ON t.TradingPartner = h.ClientName
		 INNER JOIN CHSDV.dbo.R_Member m ON n.[09] = m.ClientMemberID
           LEFT JOIN X12CodeList AS nx1 ON n.[01] = nx1.Code
                                           AND nx1.ElementId = 98
           LEFT JOIN dbo.vwReferenceInformation r ON r.ParentLoopID = n.ParentLoopID AND n.InterchangeId = r.InterchangeId and n.TransactionSetId = r.TransactionSetId AND r.ReferenceType = 'Health Insurance Claim (HIC) Number' AND r.ReferenceValue <> 'NULL'
     WHERE nx1.Definition = 'Insured or Subscriber' AND r.ReferenceValue IS NOT NULL
     GROUP BY
		m.CentauriMemberID,
		m.MemberHashKey,
		r.ReferenceValue,
		i.Filename,
		i.CreatedDate



GO
