SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnDateTable]
(
  @StartDate DATETIME,
  @EndDate DATETIME,
  @DayPart CHAR(5) -- support 'day','month','year','hour', default 'day'
)
RETURNS @Result TABLE
(
  [Date] DATETIME
)
AS
BEGIN
  DECLARE @CurrentDate DATETIME
  SET @CurrentDate=@StartDate
  WHILE @CurrentDate<=@EndDate
  BEGIN
    INSERT INTO @Result VALUES (@CurrentDate)
    SELECT @CurrentDate=
    CASE
    WHEN @DayPart='year' THEN DATEADD(yy,1,@CurrentDate)
    WHEN @DayPart='month' THEN DATEADD(mm,1,@CurrentDate)
    WHEN @DayPart='hour' THEN DATEADD(hh,1,@CurrentDate)
    ELSE
      DATEADD(dd,1,@CurrentDate)
    END
  END
  RETURN
END

GO
