SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns a bit value based on the supplied Y/N char value.
-- =============================================
CREATE FUNCTION [dbo].[ConvertBitFromYN]
(
	@value char(1)
)
RETURNS bit
WITH SCHEMABINDING
AS
BEGIN
	RETURN (SELECT CASE @value WHEN 'Y' THEN 1 WHEN 'N' THEN 0 END);
END
GO
GRANT EXECUTE ON  [dbo].[ConvertBitFromYN] TO [Processor]
GO
GRANT EXECUTE ON  [dbo].[ConvertBitFromYN] TO [Submitter]
GO
