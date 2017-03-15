SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dv].[vw834MemberEligibilityDates]
AS
     SELECT
          CentauriClientID,
		H_Member_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(RecordSource, ''))), ':', RTRIM(LTRIM(COALESCE(LoadDate, ''))), ':', RTRIM(LTRIM(COALESCE(Member_BK, ''))), ':', RTRIM(LTRIM(COALESCE([Medicaid Begin], ''))), ':', RTRIM(LTRIM(COALESCE([Medicaid End], ''))), ':', RTRIM(LTRIM(COALESCE(NULL, ''))), ':', RTRIM(LTRIM(COALESCE(Payor, '')))   ))), 2)) AS S_MemberElig_RK,
		UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(Member_BK, ''))), ':', RTRIM(LTRIM(COALESCE([Medicaid Begin], ''))), ':', RTRIM(LTRIM(COALESCE([Medicaid End], ''))), ':', RTRIM(LTRIM(COALESCE(NULL, ''))), ':', RTRIM(LTRIM(COALESCE(Payor, '')))   ))), 2)) AS MemberEligHashDiff,
		Member_BK,
		RecordSource,
		LoadDate,
		Payor,
          CONVERT(VARCHAR(35),[Medicaid Begin]) AS EffDate,
          CONVERT(VARCHAR(35),[Medicaid End]) AS TermDate,
		ParentLoopID
     FROM
     (
         
	    SELECT 
		    dx1.Definition AS DateType,
              d.[03] AS Dates,
		    h.CentauriClientID,
		    RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS RecordSource,
		    i.CreatedDate AS LoadDate,
		    RIGHT(i.Filename, CHARINDEX('_', REVERSE(i.Filename)) - 1) AS Payor,
		    UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(RTRIM(LTRIM(COALESCE(m.CentauriMemberID, ''))))), 2)) AS H_Member_RK,
		    m.CentauriMemberID AS Member_BK,
		    n.[09] AS MemberID,
		    l.ParentLoopID
         FROM  dbo.DTP AS d
               INNER JOIN dbo.LoopParent AS l ON d.ParentLoopId = l.LoopID
               INNER JOIN X12CodeList AS dx1 ON d.[01] = dx1.Code AND dx1.ElementId = 374 
			INNER JOIN dbo.NM1 AS n ON n.InterchangeId = d.InterchangeId AND d.TransactionSetId = d.TransactionSetId AND l.ParentLoopID = n.ParentLoopId
			INNER JOIN X12CodeList AS nx1 ON n.[01] = nx1.Code AND nx1.ElementId = 98
			INNER JOIN dbo.Interchange i ON n.InterchangeId = i.Id
			INNER JOIN cfg.TradingPartnerFile t ON i.SenderId = t.SenderID AND i.ReceiverId = t.ReceiverID
			INNER JOIN CHSDV.dbo.R_Client h ON t.TradingPartner = h.ClientName
			INNER JOIN CHSDV.dbo.R_Member m ON n.[09] = m.ClientMemberID
         WHERE dx1.Definition IN('Medicaid Begin', 'Medicaid End') AND d.[03] <> '' AND nx1.Definition = 'Insured or Subscriber'

     ) AS src PIVOT(MIN(Dates) FOR DateType IN(
          [Medicaid Begin],
          [Medicaid End])) AS PivotTable;





GO
