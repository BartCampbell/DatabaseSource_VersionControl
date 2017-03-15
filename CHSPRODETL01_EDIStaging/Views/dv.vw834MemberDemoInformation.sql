SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dv].[vw834MemberDemoInformation]
AS
     SELECT 
		RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS RecordSource,
		i.CreatedDate AS LoadDate,
		m.MemberHashKey AS H_Member_RK,
          m.CentauriMemberID AS Member_BK,
		UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(n.[03],''))),':',RTRIM(LTRIM(COALESCE(n.[04],''))),':',RTRIM(LTRIM(COALESCE(dx3.Definition,''))),':',RTRIM(LTRIM(COALESCE(d.[02],'')))  ))),2)) AS HashDiff,
		UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1),''))),':',RTRIM(LTRIM(COALESCE(i.CreatedDate,''))),':',RTRIM(LTRIM(COALESCE(m.CentauriMemberID,''))),':',RTRIM(LTRIM(COALESCE(n.[03],''))),':',RTRIM(LTRIM(COALESCE(n.[04],''))),':',RTRIM(LTRIM(COALESCE(dx3.Definition,''))),':',RTRIM(LTRIM(COALESCE(d.[02],'')))  ))),2)) AS S_MemberDemo_RK,
		CONVERT(VARCHAR(80),n.[09]) AS MemberID,
          CONVERT(VARCHAR(80),n.[03]) AS MemberLastName,
          CONVERT(VARCHAR(80),n.[04]) AS MemberFirstName,
          CONVERT(VARCHAR(80),n.[05]) AS MemberMiddleName,
          CONVERT(VARCHAR(10),n.[06]) AS MemberPrefix,
          CONVERT(VARCHAR(10),n.[07]) AS MemberSuffix,
          CONVERT(VARCHAR(35),d.[02]) AS DOB,
          dx3.Definition AS Gender
     FROM  dbo.NM1 AS n
		 INNER JOIN dbo.Interchange i ON n.InterchangeId = i.Id
		 INNER JOIN cfg.TradingPartnerFile t ON i.SenderId = t.SenderID AND i.ReceiverId = t.ReceiverID
		 INNER JOIN CHSDV.dbo.R_Client h ON t.TradingPartner = h.ClientName
		 INNER JOIN CHSDV.dbo.R_Member m ON n.[09] = m.ClientMemberID
           LEFT JOIN X12CodeList AS nx1 ON n.[01] = nx1.Code
                                           AND nx1.ElementId = 98
           LEFT JOIN dbo.DMG AS d ON d.InterchangeId = n.InterchangeId
                                     AND d.TransactionSetId = n.TransactionSetId
                                     AND d.ParentLoopId = n.LoopId
           LEFT JOIN X12CodeList AS dx3 ON d.[03] = dx3.Code
                                           AND dx3.ElementId = 1068
     WHERE nx1.Definition = 'Insured or Subscriber'
     GROUP BY
          n.[09],
		m.CentauriMemberID,
		m.MemberHashKey,
          n.[03],
          n.[04],
          n.[05],
          n.[06],
          n.[07],
          d.[02],
          dx3.Definition,
		i.Filename,
		i.CreatedDate



GO
