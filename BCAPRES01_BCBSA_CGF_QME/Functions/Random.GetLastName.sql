SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/22/2013
-- Description:	Retrieves a random last name.
--				*Set @Rand as RAND(CHECKSUM(NEWID())) to work in any scenario*
-- =============================================
CREATE FUNCTION [Random].[GetLastName]
(
	@Rand float
)
RETURNS varchar(16)
AS
BEGIN
	DECLARE @Lower smallint;
	DECLARE @Upper smallint;
	
	SELECT @Lower = 1, @Upper = 30000;

	RETURN (SELECT TOP 1 LastName FROM Random.LastNames WHERE ID = Random.GetNumber(@Lower, @Upper, @Rand));
END
GO
GRANT EXECUTE ON  [Random].[GetLastName] TO [Processor]
GO
