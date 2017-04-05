SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/26/2011
-- Description:	Retrieves the current count of "Requires 1st Rank" criteria for the specified Event Option.
-- =============================================
CREATE FUNCTION [Measure].[GetEventOptionRequire1stRankCount] 
(
	@EventID int,
	@OptionNbr tinyint,
	@EventOptID int
)
RETURNS int
AS
BEGIN
	DECLARE @Result int

	SELECT	@Result = COUNT(*)
	FROM	Measure.EventOptions  WITH(READUNCOMMITTED)
	WHERE	(EventID = @EventID) AND
			(OptionNbr = @OptionNbr) AND
			(Require1stRank = 1) AND
			(EventOptID <> @EventOptID)

	IF @Result IS NULL
		SET @Result = 0

	RETURN @Result
END
GO
GRANT EXECUTE ON  [Measure].[GetEventOptionRequire1stRankCount] TO [Processor]
GO
