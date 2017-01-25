SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/31/2016
-- Description:	Outputs a resultset of the totals of the numeric columns of a PLD file stored in a temporary table (e.g. a table in the "Temp" schema).
-- =============================================
CREATE PROCEDURE [Ncqa].[PLD_GetTotalsFromTemp]
(
	@OutputSql bit = 0,
	@TableName nvarchar(128)	
)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @SqlCmd nvarchar(max);
	DECLARE @SqlCmdFrom nvarchar(max);
	DECLARE @SqlCmdGroupBy nvarchar(max);

	SELECT	@SqlCmd =	ISNULL(@SqlCmd + ', ', '') +
						CASE WHEN COLUMN_NAME LIKE '%Numerator' OR 
								  COLUMN_NAME LIKE '%Denominator' OR
								  COLUMN_NAME IN ('MM')
							 THEN 'SUM(CONVERT(bigint, ' + QUOTENAME(COLUMN_NAME) + ')) AS ' + QUOTENAME(COLUMN_NAME)
							 WHEN COLUMN_NAME IN ('RecordID', 'MemberID', 'DOB', 'Gender', 'DSMemberID', 'IhdsMemberID')
							 THEN ''''' AS ' + QUOTENAME(COLUMN_NAME)
							 ELSE QUOTENAME(COLUMN_NAME)
							 END,
			@SqlCmdFrom = QUOTENAME(TABLE_CATALOG) + '.' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME),
			@SqlCmdGroupBy  =	REPLACE(ISNULL(@SqlCmdGroupBy + ', ', '') +
								CASE WHEN COLUMN_NAME LIKE '%Numerator' OR 
										  COLUMN_NAME LIKE '%Denominator' OR
										  COLUMN_NAME IN ('MM') OR
										  COLUMN_NAME IN ('RecordID', 'MemberID', 'DOB', 'Gender', 'DSMemberID', 'IhdsMemberID')
									 THEN '<<BLANK>>'
									 ELSE QUOTENAME(COLUMN_NAME)
									 END, ', <<BLANK>>', '')
	FROM	INFORMATION_SCHEMA.COLUMNS
	WHERE	TABLE_SCHEMA = 'Temp' AND
			TABLE_NAME = @TableName
	ORDER BY ORDINAL_POSITION;

	SET @SqlCmd = 'SELECT ' + @SqlCmd + ' FROM ' + @SqlCmdFrom + ' GROUP BY ' + @SqlCmdGroupBy + ';'

	IF @OutputSql = 1
		SELECT @SqlCmd;

	EXEC (@SqlCmd);
END
GO
