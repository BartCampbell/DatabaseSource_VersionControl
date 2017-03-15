SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwTransactionBeginning_BGN]
AS
SELECT
     InterchangeId,
     PositionInInterchange,
     TransactionSetId,
     bx1.Definition AS TransactionPurpose,
     CONVERT(VARCHAR(80),b.[02]) AS ReferenceID,
     b.[03] AS FileCreationDate,
     CONVERT(VARCHAR(8),b.[04]) AS FileCreationTime,
     CONVERT(VARCHAR(80),b.[06]) AS PreviousReferenceID,
     bx7.Definition AS TransactionType,
     bx8.Definition AS ACTION
FROM dbo.BGN AS b
     LEFT JOIN dbo.X12CodeList AS bx1 ON b.[01] = bx1.Code
                                         AND bx1.ElementId = 353
     LEFT JOIN dbo.X12CodeList AS bx7 ON b.[07] = bx7.Code
                                         AND bx7.ElementId = 640
     LEFT JOIN dbo.X12CodeList AS bx8 ON b.[08] = bx8.Code
                                         AND bx8.ElementId = 306;

GO
