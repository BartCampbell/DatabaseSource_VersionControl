SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
-- =============================================
-- Author:        <Amjad Ali Awan>
-- Alter date: <17 Dec 2014>
-- Description:   <Date wise Coder progress report>
-- =============================================
-- c_DateWise '01/01/2015','03/03/2015','0'
 
CREATE PROCEDURE [dbo].[c_DateWise]
      @Start date,
      @End date,
	  @h_id varchar(1),
	  @dateType int
AS
BEGIN
 
SET NOCOUNT ON;
DECLARE @DynamicPivotQuery AS VARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)
DECLARE @AllDates table
        (NewDate Date)
 
 
/* COLUMNS HEADERS */
DECLARE @dCounter datetime
SELECT @dCounter = @Start
WHILE @dCounter <= @End
BEGIN
INSERT INTO @AllDates VALUES (@dCounter)
SELECT @dCounter=@dCounter+1
END
 
SELECT @ColumnName= ISNULL(@ColumnName + ',','')
+ QUOTENAME(NewDate)
FROM (SELECT NewDate FROM @AllDates  ) AS q
 
/* GRAND TOTAL COLUMN */
DECLARE @GrandTotalCol  NVARCHAR (MAX)
SELECT @GrandTotalCol = COALESCE (@GrandTotalCol + '+ISNULL([' + CAST(NewDate AS VARCHAR) + '],0)','ISNULL([' + CAST(NewDate AS VARCHAR) + '],0)')
FROM  (SELECT NewDate FROM @AllDates  ) AS s
--SET @GrandTotalCol = LEFT (@GrandTotalCol, LEN (@GrandTotalCol)-1)
 
/* GRAND TOTAL ROW */
DECLARE @GrandTotalRow  NVARCHAR(MAX)
SELECT @GrandTotalRow = COALESCE(@GrandTotalRow + ',ISNULL(SUM([' + CAST(NewDate AS VARCHAR)+']),0)', 'ISNULL(SUM([' + CAST(NewDate AS VARCHAR)+']),0)')
FROM  (SELECT NewDate FROM @AllDates  ) AS t
 
 
 
 
--Prepare the PIVOT query using the dynamic

if(@dateType=0)
BEGIN 
SET @DynamicPivotQuery =
'SELECT '' ''+Lastname As Coder, ' + @ColumnName + ', '+ @GrandTotalCol + ' AS [Grand Total] INTO #temp_MatchesTotal
FROM (SELECT Lastname,inserted_user_pk
        ,left(CONVERT(VARCHAR, inserted_date, 121),10) as updated_date
  FROM [MCH-Portal].[dbo].[tblEncounter] E with (nolock)
  inner join [MCH-Portal].[dbo].[tblUser] u with (nolock) on E.inserted_user_pk =u.User_PK where E.h_id='+@h_id+'
  
   )p pivot
  (count([inserted_user_pk]) for [updated_date] IN (' + @ColumnName + ')) AS PVTTable  order by coder
  
  SELECT * FROM #temp_MatchesTotal UNION ALL
SELECT ''Grand Total'',' +@GrandTotalRow +',ISNULL (SUM([Grand Total]),0) FROM #temp_MatchesTotal
DROP TABLE #temp_MatchesTotal'
END
ELSE
BEGIN
SET @DynamicPivotQuery =
'SELECT '' ''+Lastname As Coder, ' + @ColumnName + ', '+ @GrandTotalCol + ' AS [Grand Total] INTO #temp_MatchesTotal
FROM (SELECT Lastname,inserted_user_pk
        ,left(CONVERT(VARCHAR, inserted_date, 121),10) as updated_date
  FROM [MCH-Portal].[dbo].[tblEncounter] E with (nolock)
  inner join [MCH-Portal].[dbo].[tblUser] u with (nolock) on E.inserted_user_pk =u.User_PK where E.h_id='+@h_id+'
  
   )p pivot
  (count([inserted_user_pk]) for [updated_date] IN (' + @ColumnName + ')) AS PVTTable  order by coder
  
  SELECT * FROM #temp_MatchesTotal UNION ALL
SELECT ''Grand Total'',' +@GrandTotalRow +',ISNULL (SUM([Grand Total]),0) FROM #temp_MatchesTotal
DROP TABLE #temp_MatchesTotal'
END
--Execute the Dynamic Pivot Query
--PRINT @DynamicPivotQuery
EXEC (@DynamicPivotQuery)
   
END
 
 

GO
