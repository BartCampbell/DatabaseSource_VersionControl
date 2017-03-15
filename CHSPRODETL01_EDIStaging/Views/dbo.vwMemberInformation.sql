SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwMemberInformation]
AS
     SELECT 
          i.SenderId,
		i.ReceiverId,
		i.Date AS FileCreateDate,
		RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS Filename,
		t.IdentifierCode AS FileType,
		n.[09] AS MemberID,
          n.[03] AS MemberLastName,
          n.[04] AS MemberFirstName,
          n.[05] AS MemberMiddleName,
          n.[06] AS MemberPrefix,
          n.[07] AS MemberSuffix,
          nx8.Definition AS MemberIDType,
          d.[02] AS DOB,
          dx3.Definition AS Gender,
          n3.[01] AS Addr1,
          n3.[02] AS Addr2,
          n4.[01] AS City,
          n4.[02] AS State,
          n4.[03] AS Zip
     FROM  dbo.NM1 AS n
		 INNER JOIN dbo.Interchange i ON n.InterchangeId = i.Id
		 INNER JOIN dbo.TransactionSet t ON i.Id = t.InterchangeId
           LEFT JOIN dbo.Loop AS l ON n.LoopId = l.Id
           LEFT JOIN X12CodeList AS nx1 ON n.[01] = nx1.Code
                                           AND nx1.ElementId = 98
           LEFT JOIN X12CodeList AS nx2 ON n.[02] = nx2.Code
                                           AND nx2.ElementId = 1065
           LEFT JOIN X12CodeList AS nx8 ON n.[08] = nx8.Code
                                           AND nx8.ElementId = 66
           LEFT JOIN X12CodeList AS nx10 ON n.[10] = nx10.Code
                                            AND nx10.ElementId = 706
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
     WHERE nx1.Definition = 'Insured or Subscriber'
     GROUP BY
          n.[09],
          n.[03],
          n.[04],
          n.[05],
          n.[06],
          n.[07],
          nx8.Definition,
          d.[02],
          dx3.Definition,
          n3.[01],
          n3.[02],
          n4.[01],
          n4.[02],
          n4.[03],
		t.IdentifierCode,
		i.Filename,
		i.SenderId,
		i.ReceiverId,
		i.Date
GO
