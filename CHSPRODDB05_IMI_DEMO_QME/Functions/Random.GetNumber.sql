SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/22/2013
-- Description:	Returns a random number between the supplied "lower" and "upper" values.
--				*Set @Rand as RAND(CHECKSUM(NEWID())) to work in any scenario*
-- =============================================
CREATE FUNCTION [Random].[GetNumber] 
(
	@Lower bigint,
	@Upper bigint,
	@Rand float
)
RETURNS bigint
WITH SCHEMABINDING
AS
BEGIN
	RETURN (SELECT ROUND(((@Upper - @Lower) * @Rand + @Lower), 0));
END
GO
GRANT EXECUTE ON  [Random].[GetNumber] TO [Processor]
GO
