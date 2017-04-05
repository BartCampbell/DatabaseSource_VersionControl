SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/9/2011
-- Description:	Returns a Y/N value based on the specified bit value.
-- =============================================
CREATE FUNCTION [dbo].[ConvertBitToYN]
(
	@value bit
)
RETURNS char(1)
WITH SCHEMABINDING
AS
BEGIN
	RETURN (SELECT CASE @value WHEN 1 THEN 'Y' WHEN 0 THEN 'N' END)
END
GO
GRANT EXECUTE ON  [dbo].[ConvertBitToYN] TO [Analyst]
GO
GRANT EXECUTE ON  [dbo].[ConvertBitToYN] TO [Processor]
GO
GRANT EXECUTE ON  [dbo].[ConvertBitToYN] TO [Submitter]
GO
