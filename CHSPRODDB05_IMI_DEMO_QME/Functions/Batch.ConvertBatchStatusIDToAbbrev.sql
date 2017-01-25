SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/20/2012
-- Description:	Returns the abbreviation associated with the specified batch status.
-- =============================================
CREATE FUNCTION [Batch].[ConvertBatchStatusIDToAbbrev]
(
	@value smallint
)
RETURNS char(1)
AS
BEGIN
	RETURN (SELECT TOP 1 Abbrev FROM Batch.[Status] WITH(NOLOCK) WHERE (BatchStatusID = @value));
END



GO
GRANT EXECUTE ON  [Batch].[ConvertBatchStatusIDToAbbrev] TO [Processor]
GO
