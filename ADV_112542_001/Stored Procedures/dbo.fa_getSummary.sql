SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To get Finance Report Summary for Dashboad
-- =============================================
/* Sample Executions
fa_getSummary
*/
CREATE PROCEDURE [dbo].[fa_getSummary]

AS
BEGIN
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
--		, SUM(CF4.Payment)+SUM(FR.Payment) Proj4, SUM(CF3.Payment)+SUM(MYR.Payment) Proj3, 0 Proj5
	IF (@LastPaymentHalf=1)
	BEGIN
		SELECT SUM(CF5.Payment)	Paid4, SUM(CF4.Payment) Paid3					, SUM(CF3.Payment) Paid2 ,				  0 Paid1,
							  0 Proj4, SUM(CF3.Payment)+SUM(FR.Payment) Proj3	, SUM(CF2.Payment) Proj2 , SUM(CF1.Payment) Proj1
			,SUM(CF5.Payment) P5,SUM(CF4.Payment) P4,SUM(CF3.Payment) P3,SUM(CF2.Payment) P2,SUM(CF1.Payment) P1,SUM(MYR.Payment) MYR,SUM(FR.Payment) FR
		FROM tblMember M
			INNER JOIN cacheMember CM ON CM.Member_PK = M.Member_PK
			LEFT JOIN cacheFinance CF1 ON CF1.Member_PK = M.Member_PK AND CF1.PaymentYear = @LastPaymentYear		AND CF1.PaymentHalf = @LastPaymentHalf
			LEFT JOIN cacheFinance CF2 ON CF2.Member_PK = M.Member_PK AND CF2.PaymentYear = @2ndLastPaymentYear	AND CF2.PaymentHalf = @2ndLastPaymentHalf
			LEFT JOIN cacheFinance CF3 ON CF3.Member_PK = M.Member_PK AND CF3.PaymentYear = @3rdLastPaymentYear	AND CF3.PaymentHalf = @3rdLastPaymentHalf
			LEFT JOIN cacheFinance CF4 ON CF4.Member_PK = M.Member_PK AND CF4.PaymentYear = @3rdLastPaymentYear-1	AND CF4.PaymentHalf = 0
			LEFT JOIN cacheFinance CF5 ON CF5.Member_PK = M.Member_PK AND CF5.PaymentYear = @3rdLastPaymentYear-2	AND CF5.PaymentHalf = 0
			LEFT JOIN cacheFinance MYR ON MYR.Member_PK = M.Member_PK AND MYR.PaymentHalf = 4
			LEFT JOIN cacheFinance FR  ON  FR.Member_PK = M.Member_PK AND  FR.PaymentHalf = 6
	END
		/*
	Else
	BEGIN
	--Need to do this for 2nd half payment

		SELECT SUM(CF5.Payment)	Paid4, SUM(CF4.Payment) Paid3					, SUM(CF3.Payment) Paid2 ,				  0 Paid1,
							  0 Proj4, SUM(CF3.Payment)+SUM(FR.Payment) Proj3	, SUM(CF2.Payment) Proj2 , SUM(CF1.Payment) Proj1
		FROM tblMember M
			INNER JOIN cacheMember CM ON CM.Member_PK = M.Member_PK
			LEFT JOIN cacheFinance CF1 ON CF1.Member_PK = M.Member_PK AND CF1.PaymentYear = @LastPaymentYear		AND CF1.PaymentHalf = @LastPaymentHalf
			LEFT JOIN cacheFinance CF2 ON CF2.Member_PK = M.Member_PK AND CF2.PaymentYear = @2ndLastPaymentYear	AND CF2.PaymentHalf = @2ndLastPaymentHalf
			LEFT JOIN cacheFinance CF3 ON CF3.Member_PK = M.Member_PK AND CF3.PaymentYear = @3rdLastPaymentYear	AND CF3.PaymentHalf = @3rdLastPaymentHalf
			LEFT JOIN cacheFinance CF4 ON CF4.Member_PK = M.Member_PK AND CF4.PaymentYear = @3rdLastPaymentYear-1	AND CF4.PaymentHalf = 0
			LEFT JOIN cacheFinance CF5 ON CF5.Member_PK = M.Member_PK AND CF5.PaymentYear = @3rdLastPaymentYear-2	AND CF5.PaymentHalf = 0
			--LEFT JOIN cacheFinance MYR ON MYR.Member_PK = M.Member_PK AND MYR.PaymentHalf = 4
			LEFT JOIN cacheFinance FR  ON  FR.Member_PK = M.Member_PK AND  FR.PaymentHalf = 6

	END	
			*/
			
	SELECT @LastPaymentYear-1 LastPaymentYear
		,@LastPaymentYear Y1,@2ndLastPaymentYear Y2,@3rdLastPaymentYear Y3,@3rdLastPaymentYear-1 Y4,@3rdLastPaymentYear-2 Y5,@LastPaymentHalf H1 ,@2ndLastPaymentHalf H2 ,@3rdLastPaymentHalf H3
END


GO
