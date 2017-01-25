SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/22/2013
-- Description:	Retrieves a random street address.
--				*Set @Rand as RAND(CHECKSUM(NEWID())) to work in any scenario*
-- =============================================
CREATE FUNCTION [Random].[GetStreetAddress]
(
	@AllowApt bit = 1,
	@Rand float
)
RETURNS varchar(64)
AS
BEGIN
	DECLARE @Lower smallint;
	DECLARE @Upper smallint;
	
	SELECT @Lower = MIN(ID), @Upper = MAX(ID) FROM Random.StreetNames WITH(NOLOCK);

	RETURN	(
				SELECT TOP 1 
						REPLACE(
						CONVERT(varchar(64), Random.GetNumber(100, 2000, @Rand)) + ' ' + 
						CONVERT(varchar(64), StreetName) + ' ' + 
						CASE Random.GetNumber(1, 3, @Rand) 
							 WHEN 1 
							 THEN 'St' 
							 WHEN 2 
							 THEN 'Ave' 
							 WHEN 3 
							 THEN 'Blvd' 
							 END + '.' +
						ISNULL(
						CASE Random.GetNumber(1, 12, @Rand) 
							 WHEN 12
							 THEN CASE WHEN ISNULL(@AllowApt, 1) = 1 THEN '' END +  
									',  Apt ' + CONVERT(varchar(64), Random.GetNumber(1, 25, @Rand)) + CHAR(Random.GetNumber(65, 75, @Rand))
							 WHEN 11
							 THEN CASE WHEN ISNULL(@AllowApt, 1) = 1 THEN '' END +  
									',  Apt ' + CONVERT(varchar(64), Random.GetNumber(100, 500, @Rand))
							 WHEN 10
							 THEN ',  Ste ' + CONVERT(varchar(64), Random.GetNumber(1000, 5000, @Rand))
							 WHEN 9
							 THEN ',  Ste ' + CONVERT(varchar(64), Random.GetNumber(10, 50, @Rand))
							 WHEN 8
							 THEN ',  #' + CONVERT(varchar(64), Random.GetNumber(10, 500, @Rand))
							 END, ''),
							 'Avenue Ave',
							 'Ave')
				FROM	Random.StreetNames WITH(NOLOCK)
				WHERE	(ID = Random.GetNumber(@Lower, @Upper, @Rand))
			);
END

GO
GRANT EXECUTE ON  [Random].[GetStreetAddress] TO [Processor]
GO
