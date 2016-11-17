SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*

Copyright © 2009 - John Burnette -- All Rights Reserved
--Modified 04/18/2016 - Travis Parker (return NULL when fewer occurences of delimiter are found than passed in)
*/

CREATE FUNCTION [dbo].[ufn_parsefind]
(
     @EntString  VARCHAR(MAX),
     @Delimiter  VARCHAR(10),
     @Occurrence BIGINT
)
RETURNS VARCHAR(MAX)
AS
     BEGIN

         DECLARE @CurString VARCHAR(MAX);
         DECLARE @Pos BIGINT;
         DECLARE @Loop BIGINT;
	    DECLARE @DelOrig VARCHAR(10); --TP

         -- REQUIRE DELIMITER AT END OF STRING

         IF RIGHT(@EntString, 1) <> @Delimiter
             SET @EntString = @EntString + @Delimiter;

         -- ESTABLISH CORRECT SYNTAX FOR DELIMITER IN PATINDEX FUNCTION
	    SET @DelOrig = @Delimiter --TP
         SET @Delimiter = '%'+@Delimiter+'%';

         SET @Loop = 1;
         SET @Pos = PATINDEX(@Delimiter, @EntString);

	    SET @Pos = (SELECT CASE WHEN LEN(@EntString) - LEN(REPLACE(@EntString,@DelOrig,'')) < @Occurrence THEN 0 ELSE @Pos END ) --TP

         -- LOOP THROUGH IF DELIMTERS FOUND

         IF @Pos = 0
             BEGIN
                 SET @CurString = NULL;
             END;
         ELSE
             BEGIN
                 WHILE @Loop <= @Occurrence
                       AND @Pos <> 0
                     BEGIN
                         SET @Pos = PATINDEX(@Delimiter, @EntString);
                         SET @CurString = LEFT(@EntString, @Pos - 1);
                         SET @EntString = RIGHT(@EntString, LEN(@EntString) - LEN(@CurString) - 1);
                         SET @Loop = @Loop + 1;
                     END;
             END;

         -- DEFAULT A NULL FOR BLANK VALUES

         IF ISNULL(@CurString, '') = ''
            OR LEN(@CurString) < 1
             SET @CurString = NULL;
    
         -- RETURN VALUE

         RETURN @CurString;
     END;





GO
