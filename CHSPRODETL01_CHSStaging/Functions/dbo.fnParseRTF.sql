SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--drop FUNCTION	dbo.fnParseRTF
--go
CREATE FUNCTION	[dbo].[fnParseRTF]
(
@rtf VARCHAR(max)
)
RETURNS VARCHAR(max)
AS
BEGIN


DECLARE @Stage TABLE
(
Chr CHAR(1),
Pos INT
)

INSERT @Stage
(
Chr,
Pos
)
SELECT SUBSTRING(@rtf, Number, 1),
Number
FROM master..spt_values
WHERE Type = 'p'
AND SUBSTRING(@rtf, Number, 1) IN ('{', '}')

DECLARE @Pos1 INT,
@Pos2 INT

SELECT @Pos1 = MIN(Pos),
@Pos2 = MAX(Pos)
FROM @Stage

DELETE
FROM @Stage
WHERE Pos IN (@Pos1, @Pos2)

WHILE 1 = 1
BEGIN
SELECT TOP 1 @Pos1 = s1.Pos, @Pos2 = s2.Pos
FROM @Stage AS s1
INNER JOIN @Stage AS s2 ON s2.Pos > s1.Pos
WHERE s1.Chr = '{'
AND s2.Chr = '}'
ORDER BY s2.Pos - s1.Pos

IF @@ROWCOUNT = 0
BREAK

DELETE
FROM @Stage
WHERE Pos IN (@Pos1, @Pos2)

UPDATE @Stage
SET Pos = Pos - @Pos2 + @Pos1 - 1
WHERE Pos > @Pos2

SET @rtf = STUFF(@rtf, @Pos1, @Pos2 - @Pos1 + 1, '')
END

SET @Pos1 = PATINDEX('%\cf[0123456789][0123456789 ]%', @rtf)

WHILE @Pos1 > 0
SELECT @Pos2 = CHARINDEX(' ', @rtf, @Pos1 + 1), @rtf = STUFF(@rtf, @Pos1, @Pos2 - @Pos1 + 1, ''), @Pos1 = PATINDEX('%\cf[0123456789][0123456789 ]%', @rtf)

SELECT @rtf = REPLACE(@rtf, '\pard', ''), @rtf = REPLACE(@rtf, '\par', ''), @rtf = case when LEN(@rtf)>0 then LEFT(@rtf, LEN(@rtf) - 1) else @rtf end

SELECT @rtf = REPLACE(@rtf, '\b0 ', ''), @rtf = REPLACE(@rtf, '\b ', '')

SELECT @rtf = REPLACE(@rtf, '\li240','')
Select @rtf = REPLACE(@rtf, '\tx239','')
Select @rtf = REPLACE(@rtf, '\tx480','')
Select @rtf = REPLACE(@rtf, '\tx720','')
Select @rtf = REPLACE(@rtf, '\tx960','')
Select @rtf = REPLACE(@rtf, '\tx1200','')
Select @rtf = REPLACE(@rtf, '\tx1440','')
Select @rtf = REPLACE(@rtf, '\tx1680','')
Select @rtf = REPLACE(@rtf, '\tx1920','')
Select @rtf = REPLACE(@rtf, '\tx2160','')
Select @rtf = REPLACE(@rtf, '\tx2400','')
Select @rtf = REPLACE(@rtf, '\tx2640','')
Select @rtf = REPLACE(@rtf, '\tx2880','')
Select @rtf = REPLACE(@rtf, '\tx3120','')
Select @rtf = REPLACE(@rtf, '\tx3360','')
Select @rtf = REPLACE(@rtf, '\tx3600','')
Select @rtf = REPLACE(@rtf, '\tx3840','')
Select @rtf = REPLACE(@rtf, '\tx4080','')
Select @rtf = REPLACE(@rtf, '\tx4320','')
Select @rtf = REPLACE(@rtf, '\tx4560','')
Select @rtf = REPLACE(@rtf, '\tx4800','')
Select @rtf = REPLACE(@rtf, '\tx5040','')
Select @rtf = REPLACE(@rtf, '\tx5520','')
Select @rtf = REPLACE(@rtf, '\tx5280','')
Select @rtf = REPLACE(@rtf, '\tx5760','')
Select @rtf = REPLACE(@rtf, '\tx6240','')
Select @rtf = REPLACE(@rtf, '\tx6480','')
Select @rtf = REPLACE(@rtf, '\tx6720','')
Select @rtf = REPLACE(@rtf, '\tx6960','')
Select @rtf = REPLACE(@rtf, '\tx7200','')
Select @rtf = REPLACE(@rtf, '\tx7440','')
Select @rtf = REPLACE(@rtf, '\tx7680','')
Select @rtf = REPLACE(@rtf, '\tx3600','')

SELECT @rtf = STUFF(@rtf, 1, CHARINDEX(' ', @rtf), '')


RETURN @rtf
end
GO
