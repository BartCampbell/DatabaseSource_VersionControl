SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/29/2011
-- Description:	Returns a value indicating whether or not the specified event is associated with any claim attributes.
-- =============================================
CREATE FUNCTION [Measure].[IsEventToClaimAttribute] 
(
	@EventID int
)
RETURNS bit
AS
BEGIN
	DECLARE @Result bit;

	IF EXISTS(SELECT TOP (1) 1 FROM Measure.EventsToClaimAttributes WHERE EventID = @EventID)
		SET @Result = 1;
	ELSE
		SET @Result = 0;

	RETURN @Result;

END
GO
GRANT EXECUTE ON  [Measure].[IsEventToClaimAttribute] TO [Processor]
GO
