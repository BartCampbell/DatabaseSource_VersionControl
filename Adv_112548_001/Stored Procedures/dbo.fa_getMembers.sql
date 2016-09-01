SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To get Finance Report List
-- =============================================
/* Sample Executions
fa_getMembers 	@Page=2,	@PageSize=25 ,	@Alpha='A' ,@Member = '',@Sort='Name' ,@Order = 'ASC', @AmountView = 0
*/
CREATE PROCEDURE [dbo].[fa_getMembers]
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Member Varchar(150),
	@Sort Varchar(150),
	@Order Varchar(4),
	@AmountView bit
AS
BEGIN
	SET @SORT = CASE @SORT
		WHEN 'MID' THEN 'M.Member_ID'
		WHEN 'Y1'  THEN 'CF1.RAF'
		WHEN 'Y2'  THEN 'CF2.RAF'
		WHEN 'Y3'  THEN 'CF3.RAF'
		WHEN 'Y4'  THEN 'CF4.RAF'
		WHEN 'Y5'  THEN 'CF5.RAF'
		WHEN 'MYR'  THEN 'MYR.RAF'
		WHEN 'FR'  THEN 'FR.RAF'
		WHEN 'DOB' THEN 'M.DOB'
		WHEN 'CES' THEN 'CM.CE_Start '+@Order+',CM.CE_End '
		ELSE 'M.Lastname+'', ''+M.Firstname'
	END;
	
	DECLARE @View as VARCHAR(20) = CASE WHEN @AmountView=1 THEN 'Payment' ELSE 'RAF+0' END;
	DECLARE @SumOrAvg as VARCHAR(20) = CASE WHEN @AmountView=1 THEN 'SUM' ELSE 'AVG' END;
	
	DECLARE @Member_Condition AS VARCHAR(500) = CASE WHEN @Member<>'' THEN 'AND M.Lastname+'', ''+M.Firstname Like '''+@Member+'%''' ELSE '' END;
	DECLARE @Alpha_Condition AS VARCHAR(500) = CASE WHEN @Alpha<>'' THEN 'AND M.Lastname+'', ''+M.Firstname Like '''+@Alpha+'%''' ELSE '' END;
	
	DECLARE @SQL AS VARCHAR(MAX) = '
	DECLARE @LastPaymentYear AS SmallInt = 2015
	DECLARE @LastPaymentHalf AS SmallInt = 1
	
	DECLARE @2ndLastPaymentYear AS SmallInt
	DECLARE @2ndLastPaymentHalf AS SmallInt
	
	DECLARE @3rdLastPaymentYear AS SmallInt
	DECLARE @3rdLastPaymentHalf AS SmallInt	
	
	If @LastPaymentHalf=1
	BEGIN
		SET @2ndLastPaymentYear = @LastPaymentYear - 1
		SET @2ndLastPaymentHalf = 2
		
		SET @3rdLastPaymentYear = @LastPaymentYear - 1
		SET @3rdLastPaymentHalf = 1
	END
	ELSE
	BEGIN
		SET @2ndLastPaymentYear = @LastPaymentYear
		SET @2ndLastPaymentHalf = 1
		
		SET @3rdLastPaymentYear = @LastPaymentYear - 1
		SET @3rdLastPaymentHalf = 0
	END;
		
	With tbl AS(
	SELECT ROW_NUMBER() OVER(ORDER BY '+@SORT+' '+@Order+') AS RowNumber
			, M.Member_PK, M.Member_ID,M.Lastname+'', ''+M.Firstname MemberName,M.DOB, CM.CE_Start, CM.CE_End
			, CF5.'+@View+' Y5, CF4.'+@View+' Y4, CF3.'+@View+' Y3, CF2.'+@View+' Y2 , CF1.'+@View+' Y1, MYR.'+@View+'*MYR.Member_Months MYR, FR.'+@View+'*FR.Member_Months FR
		FROM tblMember M
			INNER JOIN cacheMember CM ON CM.Member_PK = M.Member_PK
			LEFT JOIN cacheFinance CF1 ON CF1.Member_PK = M.Member_PK AND CF1.PaymentYear = @LastPaymentYear		AND CF1.PaymentHalf = @LastPaymentHalf
			LEFT JOIN cacheFinance CF2 ON CF2.Member_PK = M.Member_PK AND CF2.PaymentYear = @2ndLastPaymentYear	AND CF2.PaymentHalf = @2ndLastPaymentHalf
			LEFT JOIN cacheFinance CF3 ON CF3.Member_PK = M.Member_PK AND CF3.PaymentYear = @3rdLastPaymentYear	AND CF3.PaymentHalf = @3rdLastPaymentHalf
			LEFT JOIN cacheFinance CF4 ON CF4.Member_PK = M.Member_PK AND CF4.PaymentYear = @3rdLastPaymentYear-1	AND CF4.PaymentHalf = 0
			LEFT JOIN cacheFinance CF5 ON CF5.Member_PK = M.Member_PK AND CF5.PaymentYear = @3rdLastPaymentYear-2	AND CF5.PaymentHalf = 0
			LEFT JOIN cacheFinance MYR ON MYR.Member_PK = M.Member_PK AND MYR.PaymentHalf = 4
			LEFT JOIN cacheFinance FR  ON  FR.Member_PK = M.Member_PK AND  FR.PaymentHalf = 6
		WHERE 1=1 '+@Member_Condition+' '+@Alpha_Condition+'
	)

	SELECT * FROM tbl WHERE RowNumber>'+CAST(@PageSize*(@Page-1) AS VARCHAR)+' AND RowNumber<='+CAST(@PageSize*@Page AS VARCHAR)+'
	
	SELECT UPPER(LEFT(M.Lastname,1)) alpha1, UPPER(RIGHT(LEFT(M.Lastname,2),1)) alpha2,Count(DISTINCT M.Member_PK) records
		FROM tblMember M
		GROUP BY LEFT(M.Lastname,1), RIGHT(LEFT(M.Lastname,2),1)			
		ORDER BY alpha1, alpha2

	SELECT COUNT(DISTINCT M.Member_PK) Members, '+@SumOrAvg+'(CF5.'+@View+') Y5, '+@SumOrAvg+'(CF4.'+@View+') Y4, '+@SumOrAvg+'(CF3.'+@View+') Y3, '+@SumOrAvg+'(CF2.'+@View+') Y2, '+@SumOrAvg+'(CF1.'+@View+') Y1, '+@SumOrAvg+'(MYR.'+@View+'*MYR.Member_Months) MYR, '+@SumOrAvg+'(FR.'+@View+'*FR.Member_Months) FR
		FROM tblMember M
			INNER JOIN cacheMember CM ON CM.Member_PK = M.Member_PK
			LEFT JOIN cacheFinance CF1 ON CF1.Member_PK = M.Member_PK AND CF1.PaymentYear = @LastPaymentYear		AND CF1.PaymentHalf = @LastPaymentHalf
			LEFT JOIN cacheFinance CF2 ON CF2.Member_PK = M.Member_PK AND CF2.PaymentYear = @2ndLastPaymentYear	AND CF2.PaymentHalf = @2ndLastPaymentHalf
			LEFT JOIN cacheFinance CF3 ON CF3.Member_PK = M.Member_PK AND CF3.PaymentYear = @3rdLastPaymentYear	AND CF3.PaymentHalf = @3rdLastPaymentHalf
			LEFT JOIN cacheFinance CF4 ON CF4.Member_PK = M.Member_PK AND CF4.PaymentYear = @3rdLastPaymentYear-1	AND CF4.PaymentHalf = 0
			LEFT JOIN cacheFinance CF5 ON CF5.Member_PK = M.Member_PK AND CF5.PaymentYear = @3rdLastPaymentYear-2	AND CF5.PaymentHalf = 0
			LEFT JOIN cacheFinance MYR ON MYR.Member_PK = M.Member_PK AND MYR.PaymentHalf = 4
			LEFT JOIN cacheFinance FR  ON  FR.Member_PK = M.Member_PK AND  FR.PaymentHalf = 6	
			
	--Column Summary
	SELECT @LastPaymentYear Y1,@2ndLastPaymentYear Y2,@3rdLastPaymentYear Y3,@3rdLastPaymentYear-1 Y4,@3rdLastPaymentYear-2 Y5,@LastPaymentHalf H1 ,@2ndLastPaymentHalf H2 ,@3rdLastPaymentHalf H3
	';
	
	EXEC (@SQL)
END


GO
