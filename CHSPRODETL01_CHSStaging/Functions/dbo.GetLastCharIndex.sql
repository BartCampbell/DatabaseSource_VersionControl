SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create function [dbo].[GetLastCharIndex](@s varchar(max), @char varchar(200)) returns int
as
begin
 
 DECLARE  @lastIndex int
 DECLARE  @nOccurance int
 DECLARE @searchExpression varchar(max)
 SET @nOccurance = len(@s)
 SET @lastIndex = 0
 SET @searchExpression = @s
 
 while @nOccurance > 0
 BEGIN 
	SELECT @nOccurance = charIndex(@char, @searchExpression)
	IF (@nOccurance > 0)
	BEGIN
		SET @lastIndex = @lastIndex + @nOccurance
		SET @searchExpression = substring(@searchExpression, @nOccurance + 1, len(@searchExpression))
	END
 END
 
	
 return @lastIndex
 
end
GO
