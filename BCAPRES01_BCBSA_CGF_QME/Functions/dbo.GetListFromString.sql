SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/29/2015
-- Description:	Returns a table containing the values of string, split into individual rows by the specified delimiter
--				(Altered from http://stackoverflow.com/questions/11018076/splitting-delimited-values-in-a-sql-column-into-multiple-rows)
-- =============================================
CREATE FUNCTION [dbo].[GetListFromString]
(
    @List       nvarchar(MAX),	--Current max of 65536 characters
    @Delimiter  nvarchar(64)	
)
RETURNS table
WITH SCHEMABINDING
AS
RETURN	
(
	WITH PseudoTallyBase1(N) AS
	(
		SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
	),
	PseudoTallyBase2(N) AS
	(
		SELECT 1 FROM PseudoTallyBase1 AS t1, PseudoTallyBase1 AS t2, PseudoTallyBase1 AS t3, PseudoTallyBase1 AS t4
	),
	PseudoTallyBase3(N) AS
	(
		SELECT 1 FROM PseudoTallyBase2 AS t1, PseudoTallyBase2 AS t2
	)
	SELECT	Position = ROW_NUMBER() OVER (ORDER BY N),
			Value 
	FROM	(
				SELECT	N, 
						LTRIM(RTRIM(SUBSTRING(@List, N, CHARINDEX(@Delimiter, @List + @Delimiter, N) - N))) AS Value
				FROM	(
							SELECT	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
							FROM	PseudoTallyBase3
						) AS PseudoTally
				WHERE	N <= CONVERT(INT, LEN(@List)) AND 
						SUBSTRING(@Delimiter + @List, N, 1) = @Delimiter
			) AS y
);
GO
