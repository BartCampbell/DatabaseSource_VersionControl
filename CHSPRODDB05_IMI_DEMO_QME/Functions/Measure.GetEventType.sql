SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/28/2011
-- Description:	Retrieves the event type of the specified event.
-- =============================================
CREATE FUNCTION [Measure].[GetEventType]
(
	@EventID int
)
RETURNS tinyint
AS
BEGIN
	DECLARE @Result tinyint

	SELECT	@Result = EventTypeID
	FROM	Measure.[Events]
	WHERE	(EventID = @EventID);

	RETURN @Result
END
GO
GRANT EXECUTE ON  [Measure].[GetEventType] TO [Processor]
GO
