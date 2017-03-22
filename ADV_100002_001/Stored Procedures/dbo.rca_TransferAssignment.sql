SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- exec rca_TransferAssignment @level=1,@coders='28,42',@IsBlindCoding=0,@to_coder=41,@complete_status=101
CREATE PROCEDURE [dbo].[rca_TransferAssignment]
	@level int,
	@coders varchar(1000),
	@IsBlindCoding tinyint,
	@to_coder int,
	@complete_status tinyint
AS
BEGIN
	DECLARE @SQL AS VARCHAR(MAX)

	SET @SQL = ' FROM tblCoderAssignment CA'
	IF @complete_status=101
		SET @SQL = @SQL + '	INNER JOIN tblSuspect S ON CA.Suspect_PK=S.Suspect_PK'
	IF @complete_status<>0
		SET @SQL = @SQL + '	LEFT JOIN tblSuspectLevelCoded SLC ON CA.Suspect_PK=SLC.Suspect_PK' -- AND CA.User_PK = SLC.User_PK 
	SET @SQL = @SQL + '	WHERE CA.User_PK IN (' + @coders + ') AND CA.CoderLevel='+CAST(@level AS varchar)
	IF @complete_status=101
		SET @SQL = @SQL + '	AND S.IsScanned=1 AND IsNull(SLC.IsCompleted,0)=0'
	ELSE IF @complete_status=102
		SET @SQL = @SQL + '	AND IsNull(SLC.IsCompleted,0)=0'
	ELSE IF @complete_status<>0
		SET @SQL = @SQL + '	AND SLC.CompletionStatus_PK=' + CAST(@complete_status AS VARCHAR)

	IF @to_coder=0
		SET @SQL = 'DELETE CA ' + @SQL;
	ELSE
		SET @SQL = 'UPDATE CA SET User_PK='+CAST(@to_coder AS varchar) + @SQL;
	EXEC (@SQL);
	--PRINT @SQL
	exec rca_getLists @level,1,@IsBlindCoding;
END
GO
