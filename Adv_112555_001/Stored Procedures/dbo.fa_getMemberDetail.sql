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
fa_getMemberDetail @Member=78,@AmountView=1
*/
CREATE PROCEDURE [dbo].[fa_getMemberDetail]
	@Member BigInt,
	@AmountView bit
AS
BEGIN
	DECLARE @View as VARCHAR(20) = CASE WHEN @AmountView=1 THEN 'D.RAF*F.BidRate' ELSE 'D.RAF' END;
	DECLARE @RView as VARCHAR(200) = CASE WHEN @AmountView=1 THEN '(SUM(IsNull(RAF2,0)-IsNull(RAF1,0)))*F.BidRate' ELSE 'SUM(IsNull(RAF2,0)-IsNull(RAF1,0))' END;
	DECLARE @SQL1 AS VARCHAR(MAX) = '	
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
	
	--HCC List
	SELECT T.HCC,T.PaymentModel,HCC_Desc,MAX(Y5) Y5,MAX(Y4) Y4,MAX(Y3) Y3,MAX(Y2) Y2,MAX(Y1) Y1,MAX(MYR) MYR,MAX(FR) FR FROM (
		SELECT D.HCC,D.PaymentModel,'+@View+' Y1,Null Y2, Null Y3, Null Y4, Null Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceHCC D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE D.HCC = D.TrumpedHCC AND F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @LastPaymentYear		AND PaymentHalf = @LastPaymentHalf 
		UNION
		SELECT D.HCC,D.PaymentModel,NULL Y1,'+@View+' Y2, Null Y3, Null Y4, Null Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceHCC D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE D.HCC = D.TrumpedHCC AND F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @2ndLastPaymentYear	AND PaymentHalf = @2ndLastPaymentHalf 
		UNION
		SELECT D.HCC,D.PaymentModel,NULL Y1,NULL Y2,'+@View+' Y3, Null Y4, Null Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceHCC D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE D.HCC = D.TrumpedHCC AND F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @3rdLastPaymentYear	AND PaymentHalf = @3rdLastPaymentHalf
		UNION
		SELECT D.HCC,D.PaymentModel,NULL Y1,NULL Y2, Null Y3,'+@View+' Y4, Null Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceHCC D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE D.HCC = D.TrumpedHCC AND F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @3rdLastPaymentYear-1	AND PaymentHalf = 0
		UNION
		SELECT D.HCC,D.PaymentModel,NULL Y1,NULL Y2, Null Y3, Null Y4,'+@View+' Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceHCC D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE D.HCC = D.TrumpedHCC AND F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @3rdLastPaymentYear-2	AND PaymentHalf = 0
		UNION
		SELECT D.HCC,D.PaymentModel,NULL Y1,NULL Y2, Null Y3, Null Y4, NULL Y5,'+@RView+' MYR, NULL FR
			FROM (
				SELECT D.HCC,D.PaymentModel,D.RAF RAF1, NULL RAF2 FROM cacheFinance F 
					INNER JOIN cacheFinanceHCC D ON D.CacheFinance_PK=F.CacheFinance_PK 
					WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @2ndLastPaymentYear AND PaymentHalf = 1
				UNION
				SELECT D.HCC,D.PaymentModel,NULL RAF1, D.RAF RAF2 FROM cacheFinance F 
					INNER JOIN cacheFinanceHCC D ON D.CacheFinance_PK=F.CacheFinance_PK 
					WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @2ndLastPaymentYear AND PaymentHalf = 2	
			) D,cacheFinance F WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentHalf = 4 GROUP BY HCC,PaymentModel,F.BidRate,F.member_months Having '+@RView+'<>0
		UNION
		SELECT D.HCC,D.PaymentModel,NULL Y1,NULL Y2, Null Y3, Null Y4, NULL Y5,NULL MYR, '+@RView+' FR
			FROM (
				SELECT D.HCC,D.PaymentModel,D.RAF RAF1, NULL RAF2 FROM cacheFinance F 
					INNER JOIN cacheFinanceHCC D ON D.CacheFinance_PK=F.CacheFinance_PK 
					WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @2ndLastPaymentYear-1 AND PaymentHalf = 0
				UNION
				SELECT D.HCC,D.PaymentModel,NULL RAF1, D.RAF RAF2 FROM cacheFinance F 
					INNER JOIN cacheFinanceHCC D ON D.CacheFinance_PK=F.CacheFinance_PK 
					WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @2ndLastPaymentYear-1 AND PaymentHalf = 5	
			) D,cacheFinance F WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentHalf = 6 GROUP BY HCC,PaymentModel,F.BidRate,F.member_months Having '+@RView+'<>0
				
	) T INNER JOIN tblHCC H ON H.HCC = T.HCC AND H.PaymentModel = T.PaymentModel Group By T.HCC,T.PaymentModel,HCC_Desc';

	DECLARE @SQL2 AS VARCHAR(MAX) = '	
	--Interactions List
	SELECT T.Interaction_PK,T.PaymentModel,I.Interaction,MAX(Y5) Y5,MAX(Y4) Y4,MAX(Y3) Y3,MAX(Y2) Y2,MAX(Y1) Y1,MAX(MYR) MYR,MAX(FR) FR FROM (
		SELECT D.Interaction_PK,D.PaymentModel,'+@View+' Y1,Null Y2, Null Y3, Null Y4, Null Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceInteraction D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @LastPaymentYear		AND PaymentHalf = @LastPaymentHalf 
		UNION
		SELECT D.Interaction_PK,D.PaymentModel,NULL Y1,'+@View+' Y2, Null Y3, Null Y4, Null Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceInteraction D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @2ndLastPaymentYear	AND PaymentHalf = @2ndLastPaymentHalf 
		UNION
		SELECT D.Interaction_PK,D.PaymentModel,NULL Y1,NULL Y2,'+@View+' Y3, Null Y4, Null Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceInteraction D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @3rdLastPaymentYear	AND PaymentHalf = @3rdLastPaymentHalf
		UNION
		SELECT D.Interaction_PK,D.PaymentModel,NULL Y1,NULL Y2, Null Y3,'+@View+' Y4, Null Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceInteraction D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @3rdLastPaymentYear-1	AND PaymentHalf = 0
		UNION
		SELECT D.Interaction_PK,D.PaymentModel,NULL Y1,NULL Y2, Null Y3, Null Y4,'+@View+' Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceInteraction D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @3rdLastPaymentYear-2	AND PaymentHalf = 0
		UNION
		SELECT D.Interaction_PK,D.PaymentModel,NULL Y1,NULL Y2, Null Y3, Null Y4, NULL Y5,'+@RView+' MYR, NULL FR
			FROM (
				SELECT D.Interaction_PK,D.PaymentModel,D.RAF RAF1, NULL RAF2 FROM cacheFinance F 
					INNER JOIN cacheFinanceInteraction D ON D.CacheFinance_PK=F.CacheFinance_PK 
					WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @2ndLastPaymentYear AND PaymentHalf = 1
				UNION
				SELECT D.Interaction_PK,D.PaymentModel,NULL RAF1, D.RAF RAF2 FROM cacheFinance F 
					INNER JOIN cacheFinanceInteraction D ON D.CacheFinance_PK=F.CacheFinance_PK 
					WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @2ndLastPaymentYear AND PaymentHalf = 2	
			) D,cacheFinance F WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentHalf = 4 GROUP BY Interaction_PK,PaymentModel,F.BidRate,F.member_months Having '+@RView+'<>0
		UNION
		SELECT D.Interaction_PK,D.PaymentModel,NULL Y1,NULL Y2, Null Y3, Null Y4, NULL Y5,NULL MYR, '+@RView+' FR
			FROM (
				SELECT D.Interaction_PK,D.PaymentModel,D.RAF RAF1, NULL RAF2 FROM cacheFinance F 
					INNER JOIN cacheFinanceInteraction D ON D.CacheFinance_PK=F.CacheFinance_PK 
					WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @2ndLastPaymentYear-1 AND PaymentHalf = 0
				UNION
				SELECT D.Interaction_PK,D.PaymentModel,NULL RAF1, D.RAF RAF2 FROM cacheFinance F 
					INNER JOIN cacheFinanceInteraction D ON D.CacheFinance_PK=F.CacheFinance_PK 
					WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @2ndLastPaymentYear-1 AND PaymentHalf = 5	
			) D,cacheFinance F WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentHalf = 6 GROUP BY Interaction_PK,PaymentModel,F.BidRate,F.member_months Having '+@RView+'<>0
	) T INNER JOIN tblInteraction I ON I.Interaction_PK = T.Interaction_PK Group By T.Interaction_PK,T.PaymentModel,I.Interaction	';

	DECLARE @SQL3 AS VARCHAR(MAX) = '
	--Demographic List
	SELECT T.Dmg_PK,I.Dmg_Desc,MAX(Y5) Y5,MAX(Y4) Y4,MAX(Y3) Y3,MAX(Y2) Y2,MAX(Y1) Y1 FROM (
		SELECT D.Dmg_PK,'+@View+' Y1,Null Y2, Null Y3, Null Y4, Null Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceDmg D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @LastPaymentYear		AND PaymentHalf = @LastPaymentHalf 
		UNION
		SELECT D.Dmg_PK,NULL Y1,'+@View+' Y2, Null Y3, Null Y4, Null Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceDmg D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @2ndLastPaymentYear	AND PaymentHalf = @2ndLastPaymentHalf 
		UNION
		SELECT D.Dmg_PK,NULL Y1,NULL Y2,'+@View+' Y3, Null Y4, Null Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceDmg D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @3rdLastPaymentYear	AND PaymentHalf = @3rdLastPaymentHalf
		UNION
		SELECT D.Dmg_PK,NULL Y1,NULL Y2, Null Y3,'+@View+' Y4, Null Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceDmg D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @3rdLastPaymentYear-1	AND PaymentHalf = 0
		UNION
		SELECT D.Dmg_PK,NULL Y1,NULL Y2, Null Y3, Null Y4,'+@View+' Y5,NULL MYR, NULL FR FROM cacheFinance F INNER JOIN cacheFinanceDmg D ON D.CacheFinance_PK=F.CacheFinance_PK 
												WHERE F.Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentYear = @3rdLastPaymentYear-2	AND PaymentHalf = 0
	) T INNER JOIN tblDmg I ON I.Dmg_PK = T.Dmg_PK Group By T.Dmg_PK,I.Dmg_Desc

	--Column Summary
	SELECT @LastPaymentYear Y1,@2ndLastPaymentYear Y2,@3rdLastPaymentYear Y3,@3rdLastPaymentYear-1 Y4,@3rdLastPaymentYear-2 Y5,@LastPaymentHalf H1 ,@2ndLastPaymentHalf H2 ,@3rdLastPaymentHalf H3
		,(SELECT member_months FROM cacheFinance WHERE Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentHalf = 4) MYR
		,(SELECT member_months FROM cacheFinance WHERE Member_PK='+CAST(@Member AS VARCHAR)+' AND PaymentHalf = 6) FR
	'
	
	EXEC (@SQL1+@SQL2+@SQL3);
	--PRINT @SQL1
	--PRINT @SQL2
	--PRINT @SQL3;
END

GO
