SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/6/2011
-- Description:	Indicates whether or not the specified metric is a parent to another metric.
-- =============================================
CREATE FUNCTION [Measure].[IsParentMetric]
(
	@MetricID int
)
RETURNS bit
AS
BEGIN
	DECLARE @Result bit;

	IF EXISTS (SELECT TOP 1 1 FROM Measure.Metrics WITH(NOLOCK) WHERE ParentID = @MetricID)
		SET @Result = 1;
	ELSE
		SET @Result = 0;

	RETURN @Result;
END
GO
GRANT EXECUTE ON  [Measure].[IsParentMetric] TO [Processor]
GO
