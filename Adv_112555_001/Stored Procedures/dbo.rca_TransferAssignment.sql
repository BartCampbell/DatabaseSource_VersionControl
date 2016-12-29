SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- exec rca_TransferAssignment @level=1,@only_incomplete=0,@pages=1,@less_more='g',@priority='',@project=0,@group=0,@charts2Assign=5,@coders='47,40,53,55,39'
-- exec rca_TransferAssignment @level=1,@only_incomplete=0,@pages=1,@less_more='',@priority='',@project=0,@group=0,@charts2Assign=100,@coders=''
CREATE PROCEDURE [dbo].[rca_TransferAssignment]
	@level int,
	@coders varchar(1000),
	@IsBlindCoding tinyint,
	@to_coder int
AS
BEGIN
	DECLARE @SQL AS VARCHAR(MAX)
	IF @to_coder=0
		SET @SQL = 'DELETE tblCoderAssignment WHERE User_PK IN (' + @coders + ') AND CoderLevel = '+CAST(@level AS varchar);
	ELSE
		SET @SQL = 'UPDATE tblCoderAssignment SET User_PK='+CAST(@to_coder AS varchar)+' WHERE User_PK IN (' + @coders + ') AND CoderLevel = '+CAST(@level AS varchar);
	EXEC (@SQL);

	exec rca_getLists @level,1,@IsBlindCoding;
END
GO
