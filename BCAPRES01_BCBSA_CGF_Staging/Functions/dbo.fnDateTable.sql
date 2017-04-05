SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Function [dbo].[fnDateTable]
(
  @StartDate datetime,
  @EndDate datetime,
  @DayPart char(5) -- support 'day','month','year','hour', default 'day'
)
Returns @Result Table
(
  [Date] datetime
)
As
Begin
  Declare @CurrentDate datetime
  Set @CurrentDate=@StartDate
  While @CurrentDate<=@EndDate
  Begin
    Insert Into @Result Values (@CurrentDate)
    Select @CurrentDate=
    Case
    When @DayPart='year' Then DateAdd(yy,1,@CurrentDate)
    When @DayPart='month' Then DateAdd(mm,1,@CurrentDate)
    When @DayPart='hour' Then DateAdd(hh,1,@CurrentDate)
    Else
      DateAdd(dd,1,@CurrentDate)
    End
  End
  Return
End

GO
