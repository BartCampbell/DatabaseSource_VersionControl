SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns the YYYYMMDD representation of the specified date
-- =============================================
CREATE FUNCTION [dbo].[ConvertDateToYYYYMMDD]
(
	@value datetime
)
RETURNS char(8)
WITH SCHEMABINDING
AS
BEGIN
	RETURN (SELECT CONVERT(char(8), @value, 112));
END

GO
GRANT EXECUTE ON  [dbo].[ConvertDateToYYYYMMDD] TO [Support]
GO
