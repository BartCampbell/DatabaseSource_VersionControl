SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/24/2013
-- Description:	Returns the MetricXrefID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Measure].[ConvertMetricXrefIDFromAbbrev]
(
	@value varchar(16)
)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 MetricXrefID FROM Measure.MetricXrefs WITH(NOLOCK) WHERE (Abbrev = @value));
END



GO
GRANT EXECUTE ON  [Measure].[ConvertMetricXrefIDFromAbbrev] TO [Processor]
GO
GRANT EXECUTE ON  [Measure].[ConvertMetricXrefIDFromAbbrev] TO [Submitter]
GO
