SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/22/2013
-- Description:	Returns a random first name based on the specified gender.
--				*Set @Rand as RAND(CHECKSUM(NEWID())) to work in any scenario*
-- =============================================
CREATE FUNCTION [Random].[GetFirstName]
(
	@Gender tinyint = NULL,
	@Rand float
)
RETURNS varchar(16)
AS
BEGIN
	DECLARE @Lower smallint;
	DECLARE @Upper smallint;
	
	IF @Gender IS NULL
		SET @Gender = Random.GetNumber(0, 1, @Rand);
	
	IF @Gender = 1
		SELECT @Lower = 1, @Upper = 1000;
	ELSE IF @Gender = 0
		SELECT @Lower = 1001, @Upper = 2000;
		
	RETURN (SELECT TOP 1 FirstName FROM Random.FirstNames WITH(NOLOCK) WHERE ID = Random.GetNumber(@Lower, @Upper, @Rand));
	
END
GO
GRANT EXECUTE ON  [Random].[GetFirstName] TO [Processor]
GO
