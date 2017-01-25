SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetMostRecentAbstractionReviewSet]
(
)
RETURNS int
AS
BEGIN
	RETURN (SELECT TOP 1 AbstractionReviewSetID FROM dbo.AbstractionReviewSet WHERE Finalized = 1 ORDER BY EndDate DESC, StartDate DESC, ISNULL(LastChangedDate, CreatedDate) DESC);
END
GO
