SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[vwSubscriberDemographics]
AS
     SELECT
          d.InterchangeID,
		d.PositionInInterchange,
          d.TransactionSetID,
		d.LoopId,
          d.ParentLoopId,
          dx1.Definition AS DateFormat,
          CONVERT(VARCHAR(35),d.[02]) AS DOB,
          dx3.Definition AS Gender
     FROM dbo.DMG AS d 
          LEFT JOIN X12CodeList AS dx1 ON d.[01] = dx1.Code
                                          AND dx1.ElementId = 1250
          LEFT JOIN X12CodeList AS dx3 ON d.[03] = dx3.Code
                                          AND dx3.ElementId = 1068;
GO
