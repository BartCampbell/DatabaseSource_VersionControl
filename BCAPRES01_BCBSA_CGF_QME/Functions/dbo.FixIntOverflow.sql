SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 12/6/2013
-- Description:	Converts a bigint into an int, returning the max int size instead of overflow.
-- =============================================
CREATE FUNCTION [dbo].[FixIntOverflow]
(
	@Value bigint
)
RETURNS int
WITH SCHEMABINDING
AS
BEGIN
	RETURN (SELECT CASE WHEN @Value > 2147483647 THEN 2147483647 WHEN @Value < -2147483648 THEN -2147483648 ELSE @Value END);
END
GO
GRANT EXECUTE ON  [dbo].[FixIntOverflow] TO [Processor]
GO
