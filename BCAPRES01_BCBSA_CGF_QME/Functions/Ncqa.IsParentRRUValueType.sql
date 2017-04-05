SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/20/2014
-- Description:	Indicates whether or not the specified RRUValTypeID is a parent to another value type.
-- =============================================
CREATE FUNCTION [Ncqa].[IsParentRRUValueType]
(
	@RRUValTypeID tinyint
)
RETURNS bit
AS
BEGIN
	DECLARE @Result bit;

	IF EXISTS (SELECT TOP 1 1 FROM Ncqa.RRU_ValueTypes WITH(NOLOCK) WHERE ParentID = @RRUValTypeID)
		SET @Result = 1;
	ELSE
		SET @Result = 0;

	RETURN @Result;
END

GO
GRANT EXECUTE ON  [Ncqa].[IsParentRRUValueType] TO [Processor]
GO
