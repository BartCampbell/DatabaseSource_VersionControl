SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/20/2012
-- Description:	Returns the BatchStatusID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Batch].[ConvertBatchStatusIDFromAbbrev]
(
	@value char(1)
)
RETURNS smallint 
AS
BEGIN
	RETURN (SELECT TOP 1 BatchStatusID FROM Batch.[Status] WITH(NOLOCK) WHERE (Abbrev = @value));
END




GO
GRANT EXECUTE ON  [Batch].[ConvertBatchStatusIDFromAbbrev] TO [Processor]
GO
