SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	imv_fix_order '0,78,80,81,82,83'
CREATE PROCEDURE [dbo].[imv_fix_order] 
	@ids varchar(500)
AS
BEGIN
	DECLARE @table TABLE ( id VARCHAR(50) )
	DECLARE @x INT = 0
	DECLARE @firstcomma INT = 0
	DECLARE @nextcomma INT = 0

	SET @x = LEN(@ids) - LEN(REPLACE(@ids, ',', '')) + 1

	WHILE @x > 0
		BEGIN
			SET @nextcomma = CASE WHEN CHARINDEX(',', @ids, @firstcomma + 1) = 0
								  THEN LEN(@ids) + 1
								  ELSE CHARINDEX(',', @ids, @firstcomma + 1)
							 END
			INSERT  INTO @table
			VALUES  ( SUBSTRING(@ids, @firstcomma + 1, (@nextcomma - @firstcomma) - 1) )
			SET @firstcomma = CHARINDEX(',', @ids, @firstcomma + 1)
			SET @x = @x - 1
		END

	SELECT ROW_NUMBER() OVER (Order by ScannedData_PK) ROW_NUM, * INTO #tmp FROM tblScannedData WHERE ScannedData_PK IN (SELECT id FROM @table) ORDER BY ScannedData_PK
	
	SELECT * INTO #tmp2 FROM #tmp
	
	Update T1 SET [Filename] = T2.[Filename]
		FROM #tmp T1 INNER JOIN #tmp2 T2 ON T1.row_num = T2.row_num+1
		
	Update T1 SET [Filename] = T2.[Filename]
		FROM #tmp T1,(SELECT TOP 1 * FROM #tmp2 ORDER BY row_num DESC) T2 WHERE T1.row_num = 1
		
	SELECT * FROM #tmp
	SELECT * FROM #tmp2
	
	Update S SET [Filename] = T.[Filename]
		FROM tblScannedData S,#tmp T WHERE T.ScannedData_PK = S.ScannedData_PK
END

GO
