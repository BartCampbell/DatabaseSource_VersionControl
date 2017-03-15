SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dv].[vw834MemberLocationInformation]
AS
     SELECT 
		RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS RecordSource,
		m.MemberHashKey AS H_Member_RK,
          m.CentauriMemberID AS Member_BK,
		UPPER(CONVERT(CHAR(32), HashBytes('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(n3.[01],''))),':',RTRIM(LTRIM(COALESCE(n3.[02] ,''))),':',RTRIM(LTRIM(COALESCE(n4.[01],''))),':',RTRIM(LTRIM(COALESCE(n4.[02],''))),':',RTRIM(LTRIM(COALESCE(n4.[03],'')))))),2)) AS H_Location_RK,
		UPPER(CONVERT(CHAR(32), HashBytes('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(n3.[01],''))),':',RTRIM(LTRIM(COALESCE(n3.[02] ,''))),':',RTRIM(LTRIM(COALESCE(n4.[01],''))),':',RTRIM(LTRIM(COALESCE(n4.[02],''))),':',RTRIM(LTRIM(COALESCE(n4.[03],'')))))),2)) AS L_MemberLocation_RK,
	     CONVERT(VARCHAR(157),CONCAT(n3.[01],n3.[02],n4.[01],n4.[02],n4.[03])) AS Location_BK,
          CONVERT(VARCHAR(80),n3.[01]) AS Addr1,
          CONVERT(VARCHAR(80),n3.[02]) AS Addr2,
          CONVERT(VARCHAR(80),n4.[01]) AS City,
          CONVERT(VARCHAR(2),n4.[02]) AS STATE,
          CONVERT(VARCHAR(15),n4.[03]) AS Zip
     FROM  dbo.NM1 AS n
		 INNER JOIN dbo.Interchange i ON n.InterchangeId = i.Id
		 INNER JOIN cfg.TradingPartnerFile t ON i.SenderId = t.SenderID AND i.ReceiverId = t.ReceiverID
		 INNER JOIN CHSDV.dbo.R_Client h ON t.TradingPartner = h.ClientName
		 INNER JOIN CHSDV.dbo.R_Member m ON n.[09] = m.ClientMemberID
           LEFT JOIN X12CodeList AS nx1 ON n.[01] = nx1.Code
                                           AND nx1.ElementId = 98
           LEFT JOIN dbo.N3 AS n3 ON n3.InterchangeId = n.InterchangeId
                                     AND n3.TransactionSetId = n.TransactionSetId
                                     AND n3.ParentLoopId = n.LoopId
           LEFT JOIN dbo.N4 AS n4 ON n4.InterchangeId = n.InterchangeId
                                     AND n4.TransactionSetId = n.TransactionSetId
                                     AND n4.ParentLoopId = n.LoopId
	WHERE nx1.Definition = 'Insured or Subscriber' 
	AND Concat(RTRIM(LTRIM(COALESCE(n3.[01],''))),':',RTRIM(LTRIM(COALESCE(n3.[02] ,''))),':',RTRIM(LTRIM(COALESCE(n4.[01],''))),':',RTRIM(LTRIM(COALESCE(n4.[02],''))),':',RTRIM(LTRIM(COALESCE(n4.[03],'')))) <> ''
     GROUP BY
          h.CentauriClientID,
		h.ClientHashKey,
		n.[09],
		m.CentauriMemberID,
		m.MemberHashKey,
          n3.[01],
          n3.[02],
          n4.[01],
          n4.[02],
          n4.[03],
		i.Filename;




GO
