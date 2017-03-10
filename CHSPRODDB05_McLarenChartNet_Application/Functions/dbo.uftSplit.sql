SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*************************************************************************************
Function:	uftSplit
Author:		Dennis Deming
Copyright:	© 2002
Date:		2002.04.29
Purpose:	To parse a delimited list
Parameters:	@vcList		varchar( 8000 )............Delimited list to parse
		@vcDelimiter	varchar( 10 )..............Delimiter
		@iItem		int........................Item to return
Depends On:	dbo.utilSequence...........................Sequence table with values 1-64000
Calls:		None
Called By:	This is a function that can be called from anywhere
Returns:	Table
Notes:		It may be necessary to increase the size of the Sequence table when 
		slicing varchar( max ) values.
Process:	1.	
Test Script:	SELECT * FROM dbo.uftSplit ( '1,2,3,apple, banana, cherry', ',', 0 )
		SELECT * FROM dbo.uftSplit ( '1 2 3 apple banana cherry a bc e', ' ', 0 )
		SELECT * FROM dbo.uftSplit ( '1 2  3 apple banana cherry  a bc e', '  ', 0 )
		SELECT * FROM dbo.uftSplit ( 'Moe, Larry, Shemp,,, Curly, Joe,,, Curly-Joe', ',', 0 )
		SELECT * FROM dbo.uftSplit ( 'Moe Larry Shemp Curly Joe Curly-Joe', ' ', 3 )
		SELECT * FROM dbo.uftSplit ( 'Moe,, Larry, Shemp, Curly, Joe, Curly-Joe', ',', 5 )
ToDo:		
*************************************************************************************/
CREATE FUNCTION [dbo].[uftSplit]  
( 
	@vcList		varchar( max ), 		-- Delimited list to parse
	@vcDelimiter	varchar( 10 ),			-- Delimiter
	@iItem		int				-- Item to return
)
RETURNS @tblOutput TABLE ( ID int IDENTITY( 1, 1 ), Value varchar( 1000 ) )
AS
BEGIN
	-- Need leading delimiter
	IF LEFT( @vcList, DATALENGTH( @vcDelimiter )) <> @vcDelimiter
	BEGIN
		SET @vcList = @vcDelimiter + @vcList
	END

	-- Need trailing delimiter
	IF RIGHT( @vcList, DATALENGTH( @vcDelimiter )) <> @vcDelimiter
	BEGIN
		SET @vcList = @vcList + @vcDelimiter
	END

	-- Populate the output table.
	INSERT INTO @tblOutput( Value )
	SELECT 	LTRIM( RTRIM( SUBSTRING( Value, ID + DATALENGTH( @vcDelimiter ), 
		CHARINDEX( @vcDelimiter, Value, ID + DATALENGTH( @vcDelimiter )) - ID - DATALENGTH( @vcDelimiter ))))
	FROM	( SELECT @vcList AS Value ) AS StringToSlice
		JOIN dbo.utilSequence n ON n.ID < DATALENGTH( StringToSlice.Value ) - DATALENGTH( @vcDelimiter )
	WHERE 	SUBSTRING( Value, ID, DATALENGTH( @vcDelimiter )) = @vcDelimiter

	-- If only one item was requested, delete the others before returning.
	IF @iItem > 0
	BEGIN
		DELETE FROM @tblOutput 
		WHERE ID <> @iItem
	END

	RETURN
END






GO
