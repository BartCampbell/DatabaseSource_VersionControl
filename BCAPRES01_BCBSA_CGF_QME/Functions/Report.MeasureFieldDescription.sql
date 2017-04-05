SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/6/2011
-- Description:	Retrieves the description for the specified measure and field combination.
-- =============================================
CREATE FUNCTION [Report].[MeasureFieldDescription]
(
	@FieldID tinyint,
	@MeasureID int
)
RETURNS varchar(64)
AS
BEGIN
	DECLARE @Result varchar(64);

	SELECT	@Result = ISNULL(RMF.Descr, RF.Descr)
	FROM	Report.MeasureFields AS RMF WITH(NOLOCK)
			INNER JOIN Report.Fields AS RF WITH(NOLOCK)
					ON RMF.FieldID = RF.FieldID 
	WHERE	(RMF.MeasureID = @MeasureID) AND
			(RMF.FieldID = @FieldID) AND
			(RF.FieldID = @FieldID)

	RETURN @Result;
END
GO
GRANT EXECUTE ON  [Report].[MeasureFieldDescription] TO [Processor]
GO
