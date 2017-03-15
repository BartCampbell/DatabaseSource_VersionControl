SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dv].[vw834MemberInformation]
AS
     SELECT 
		h.CentauriClientID,
		RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS RecordSource,
		m.MemberHashKey AS H_Member_RK,
		h.ClientHashKey AS H_Client_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(h.CentauriClientID, '')))))), 2)) AS L_MemberClient_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))), ':', RTRIM(LTRIM(COALESCE(h.CentauriClientID, ''))), ':', RTRIM(LTRIM(COALESCE(n.[09], '')))))), 2)) AS LS_MemberClient_RK,
          m.CentauriMemberID AS Member_BK,
		CONVERT(VARCHAR(80),n.[09]) AS MemberID,
		CONVERT(VARCHAR(80),r.ReferenceValue) AS HICN,
          CONVERT(VARCHAR(80),n.[03])AS MemberLastName,
          CONVERT(VARCHAR(80),n.[04]) AS MemberFirstName,
          CONVERT(VARCHAR(80),n.[05]) AS MemberMiddleName,
          CONVERT(VARCHAR(10),n.[06]) AS MemberPrefix,
          CONVERT(VARCHAR(10),n.[07]) AS MemberSuffix,
          CONVERT(VARCHAR(35),d.[02]) AS DOB,
          dx3.Definition AS Gender,
		UPPER(CONVERT(CHAR(32), HashBytes('MD5',UPPER(CONCAT(RTRIM(LTRIM(COALESCE(n3.[01],''))),':',RTRIM(LTRIM(COALESCE(n3.[02] ,''))),':',RTRIM(LTRIM(COALESCE(n4.[01],''))),':',RTRIM(LTRIM(COALESCE(n4.[02],''))),':',RTRIM(LTRIM(COALESCE(n4.[03],'')))))),2)) AS H_Location_RK,
	     CONVERT(VARCHAR(157),CONCAT(n3.[01],n3.[02],n4.[01],n4.[02],n4.[03])) AS Location_BK,
          CONVERT(VARCHAR(80),n3.[01]) AS Addr1,
          CONVERT(VARCHAR(80),n3.[02]) AS Addr2,
          CONVERT(VARCHAR(80),n4.[01]) AS City,
          CONVERT(VARCHAR(2),n4.[02]) AS STATE,
          CONVERT(VARCHAR(15),n4.[03]) AS Zip,
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
           LEFT JOIN dbo.LOOP AS l ON n.LoopId = l.Id
           LEFT JOIN X12CodeList AS nx1 ON n.[01] = nx1.Code
                                           AND nx1.ElementId = 98
           LEFT JOIN dbo.DMG AS d ON d.InterchangeId = n.InterchangeId
                                     AND d.TransactionSetId = n.TransactionSetId
                                     AND d.ParentLoopId = n.LoopId
           LEFT JOIN X12CodeList AS dx3 ON d.[03] = dx3.Code
                                           AND dx3.ElementId = 1068
           LEFT JOIN dbo.N3 AS n3 ON n3.InterchangeId = n.InterchangeId
                                     AND n3.TransactionSetId = n.TransactionSetId
                                     AND n3.ParentLoopId = n.LoopId
           LEFT JOIN dbo.N4 AS n4 ON n4.InterchangeId = n.InterchangeId
                                     AND n4.TransactionSetId = n.TransactionSetId
                                     AND n4.ParentLoopId = n.LoopId
		 LEFT JOIN dv.vw834CommNumbers c ON c.ParentLoopID = l.ParentLoopId AND n.InterchangeId = c.InterchangeId AND n.TransactionSetId = c.TransactionSetId AND c.MemberContact = 'Insured Party'
		 LEFT JOIN dbo.vwReferenceInformation r ON r.ParentLoopID = n.ParentLoopID AND n.InterchangeId = r.InterchangeId AND n.TransactionSetId = r.TransactionSetId AND r.ReferenceType = 'Health Insurance Claim (HIC) Number' AND r.ReferenceValue <> 'NULL'
     WHERE nx1.Definition = 'Insured or Subscriber'
     GROUP BY
          h.CentauriClientID,
		h.ClientHashKey,
		n.[09],
		m.CentauriMemberID,
		m.MemberHashKey,
		r.ReferenceValue,
          n.[03],
          n.[04],
          n.[05],
          n.[06],
          n.[07],
          d.[02],
          dx3.Definition,
          n3.[01],
          n3.[02],
          n4.[01],
          n4.[02],
          n4.[03],
		i.Filename,
		c.Contact1,
		c.ContactType1,
		c.Contact2,
		c.ContactType2,
		c.Contact3,
		c.ContactType3;


GO
