SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/23/2012
-- Description:	Returns the MMDDYYYY representation of the specified date
-- =============================================
CREATE FUNCTION [dbo].[ConvertDateToMMDDYYYY]
(
	@value datetime
)
RETURNS char(8)
WITH SCHEMABINDING
AS
BEGIN
	RETURN (RIGHT(CONVERT(char(8), @value, 112), 4) + LEFT(CONVERT(char(8), @value, 112), 4));
END

GO
GRANT EXECUTE ON  [dbo].[ConvertDateToMMDDYYYY] TO [Processor]
GO
