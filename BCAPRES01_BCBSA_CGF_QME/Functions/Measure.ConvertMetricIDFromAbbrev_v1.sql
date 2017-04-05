SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/24/2011
-- Description:	Returns the MetricID associated with the specified character abbreviation.
-- =============================================
CREATE FUNCTION [Measure].[ConvertMetricIDFromAbbrev_v1]
(
	@value varchar(16)
)
RETURNS int 
AS
BEGIN
	RETURN (SELECT TOP 1 MetricID FROM Measure.Metrics WITH(NOLOCK) WHERE (Abbrev = @value));
END


GO
GRANT EXECUTE ON  [Measure].[ConvertMetricIDFromAbbrev_v1] TO [Processor]
GO
