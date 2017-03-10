SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[dba_parseString_udf]
(
          @stringToParse VARCHAR(8000)  
        , @delimiter     CHAR(1)
)
RETURNS @parsedString TABLE (stringValue VARCHAR(128))
AS

BEGIN

    /* Declare variables */
    DECLARE @trimmedString  VARCHAR(8000);

    /* We need to trim our string input in case the user entered extra spaces */
    SET @trimmedString = LTRIM(RTRIM(@stringToParse));

    /* Let's create a recursive CTE to break down our string for us */
    WITH parseCTE (StartPos, EndPos)
    AS
    (
        SELECT 1 AS StartPos
            , CHARINDEX(@delimiter, @trimmedString + @delimiter) AS EndPos
        UNION ALL
        SELECT EndPos + 1 AS StartPos
            , CharIndex(@delimiter, @trimmedString + @delimiter , EndPos + 1) AS EndPos
        FROM parseCTE
        WHERE CHARINDEX(@delimiter, @trimmedString + @delimiter, EndPos + 1) <> 0
    )

    /* Let's take the results and stick it in a table */  
    INSERT INTO @parsedString
    SELECT SUBSTRING(@trimmedString, StartPos, EndPos - StartPos)
    FROM parseCTE
    WHERE LEN(LTRIM(RTRIM(SUBSTRING(@trimmedString, StartPos, EndPos - StartPos)))) > 0
    OPTION (MaxRecursion 8000);

    RETURN;   
END

GO
