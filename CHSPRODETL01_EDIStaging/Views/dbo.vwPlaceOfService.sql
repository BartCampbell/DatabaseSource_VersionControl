SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vwPlaceOfService]
AS
SELECT POSCode, POSName, POSDescription, POSID
FROM  Submissions.dbo.PlaceOfService
GO
