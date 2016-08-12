SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To prepare Finance Report
-- =============================================

CREATE PROCEDURE [dbo].[prepareFinance]
AS
BEGIN
	Truncate Table cacheFinanceDmg
	Truncate Table cacheFinanceHCC
	Truncate Table cacheFinanceInteraction
	Truncate Table cacheFinance
	
	DECLARE @LastPaidYear AS SmallInt
	DECLARE @LastPaidMonth AS SmallInt
	
	SELECT @LastPaidYear=YEAR(MAX(EligibleMonth)),@LastPaidMonth=MONTH(MAX(EligibleMonth)) FROM tblCMSEligibility

	DECLARE @PY AS INT
	DECLARE @PH AS INT
	DECLARE @Trans_Date AS DATE
	DECLARE @DOS_SDate AS DATE
	DECLARE @DOS_EDate AS DATE
	
	SET @PY = @LastPaidYear-2
	SET @PH = 0
	SET @Trans_Date=NULL
	SET @DOS_SDate = CAST(@LastPaidYear-3 AS VARCHAR)+'-1-1'
	SET @DOS_EDate = CAST(@LastPaidYear-3 AS VARCHAR)+'-12-31'
	EXEC prepareFinanceDetail @PaymentYear = @PY, @YearHalf = @PH, @DOS_Start = @DOS_SDate, @DOS_End = @DOS_EDate, @Paid=1, @Transaction=@Trans_Date,@payment_cache=1
	
	SET @PY = @LastPaidYear-1
	SET @PH = 0
	SET @Trans_Date=NULL
	SET @DOS_SDate = CAST(@LastPaidYear-2 AS VARCHAR)+'-1-1'
	SET @DOS_EDate = CAST(@LastPaidYear-2 AS VARCHAR)+'-12-31'
	EXEC prepareFinanceDetail @PaymentYear = @PY, @YearHalf = @PH, @DOS_Start = @DOS_SDate, @DOS_End = @DOS_EDate, @Paid=1, @Transaction=@Trans_Date,@payment_cache=1
	If (@LastPaidMonth>6)
	BEGIN
		SET @PY = @LastPaidYear
		SET @PH = 0
		SET @Trans_Date=NULL
		SET @DOS_SDate = CAST(@LastPaidYear-1 AS VARCHAR)+'-1-1'
		SET @DOS_EDate = CAST(@LastPaidYear-1 AS VARCHAR)+'-12-31'
		EXEC prepareFinanceDetail @PaymentYear = @PY, @YearHalf = @PH, @DOS_Start = @DOS_SDate, @DOS_End = @DOS_EDate, @Paid=1, @Transaction=@Trans_Date,@payment_cache=1

		SET @PY = @LastPaidYear+1
		SET @PH = 1
		SELECT @Trans_Date=SweepDeadline FROM tblSweep WHERE SweepYear=@LastPaidYear AND Sweep='Sep'
		SET @Trans_Date='2014-09-25'
		SET @DOS_SDate = CAST(@LastPaidYear-1 AS VARCHAR)+'-7-1'
		SET @DOS_EDate = CAST(@LastPaidYear AS VARCHAR)+'-6-30'
		EXEC prepareFinanceDetail @PaymentYear = @PY, @YearHalf = @PH, @DOS_Start = @DOS_SDate, @DOS_End = @DOS_EDate, @Paid=0, @Transaction=@Trans_Date,@payment_cache=1

		SET @PY = @LastPaidYear+1
		SET @PH = 2
		SELECT @Trans_Date=SweepDeadline FROM tblSweep WHERE SweepYear=@LastPaidYear+1 AND Sweep='Mar'
		SET @DOS_SDate = CAST(@LastPaidYear AS VARCHAR)+'-1-1'
		SET @DOS_EDate = CAST(@LastPaidYear AS VARCHAR)+'-12-31'
		EXEC prepareFinanceDetail @PaymentYear = @PY, @YearHalf = @PH, @DOS_Start = @DOS_SDate, @DOS_End = @DOS_EDate, @Paid=0, @Transaction=@Trans_Date,@payment_cache=1
		
		--Aditional Cache for Mid Year with is_payment_cache = 0
		SET @PY = @LastPaidYear
		SET @PH = 1
		SET @Trans_Date=NULL
		SET @DOS_SDate = CAST(@LastPaidYear-2 AS VARCHAR)+'-7-1'
		SET @DOS_EDate = CAST(@LastPaidYear-1 AS VARCHAR)+'-6-30'
		EXEC prepareFinanceDetail @PaymentYear = @PY, @YearHalf = @PH, @DOS_Start = @DOS_SDate, @DOS_End = @DOS_EDate, @Paid=1, @Transaction=@Trans_Date,@payment_cache=0

		SET @PY = @LastPaidYear
		SET @PH = 2
		SELECT @Trans_Date=SweepDeadline FROM tblSweep WHERE SweepYear=@LastPaidYear AND Sweep='Mar'
		SET @DOS_SDate = CAST(@LastPaidYear-1 AS VARCHAR)+'-1-1'
		SET @DOS_EDate = CAST(@LastPaidYear-1 AS VARCHAR)+'-12-31'
		EXEC prepareFinanceDetail @PaymentYear = @PY, @YearHalf = @PH, @DOS_Start = @DOS_SDate, @DOS_End = @DOS_EDate, @Paid=0, @Transaction=@Trans_Date,@payment_cache=0
	END
	ELSE
	BEGIN
		SET @PY = @LastPaidYear
		SET @PH = 1
		SET @Trans_Date=NULL
		SET @DOS_SDate = CAST(@LastPaidYear-2 AS VARCHAR)+'-7-1'
		SET @DOS_EDate = CAST(@LastPaidYear-1 AS VARCHAR)+'-6-30'
		EXEC prepareFinanceDetail @PaymentYear = @PY, @YearHalf = @PH, @DOS_Start = @DOS_SDate, @DOS_End = @DOS_EDate, @Paid=1, @Transaction=@Trans_Date,@payment_cache=1

		SET @PY = @LastPaidYear
		SET @PH = 2
		SELECT @Trans_Date=SweepDeadline FROM tblSweep WHERE SweepYear=@LastPaidYear AND Sweep='Mar'
		SET @DOS_SDate = CAST(@LastPaidYear-1 AS VARCHAR)+'-1-1'
		SET @DOS_EDate = CAST(@LastPaidYear-1 AS VARCHAR)+'-12-31'
		EXEC prepareFinanceDetail @PaymentYear = @PY, @YearHalf = @PH, @DOS_Start = @DOS_SDate, @DOS_End = @DOS_EDate, @Paid=0, @Transaction=@Trans_Date,@payment_cache=1

		SET @PY = @LastPaidYear+1
		SET @PH = 1
		SELECT @Trans_Date=SweepDeadline FROM tblSweep WHERE SweepYear=@LastPaidYear AND Sweep='Sep'
		SET @DOS_SDate = CAST(@LastPaidYear-1 AS VARCHAR)+'-7-1'
		SET @DOS_EDate = CAST(@LastPaidYear AS VARCHAR)+'-6-30'
		EXEC prepareFinanceDetail @PaymentYear = @PY, @YearHalf = @PH, @DOS_Start = @DOS_SDate, @DOS_End = @DOS_EDate, @Paid=0, @Transaction=@Trans_Date,@payment_cache=1
		
	END
	
	--MID Year Cache
	DECLARE @LastPaidMonthMY AS INT = CASE WHEN @LastPaidMonth>6 THEN 6 ELSE @LastPaidMonth END

	INSERT INTO cacheFinance(Member_PK,PaymentYear,PaymentHalf,Community,Institutional,ESRD,HOSP,NewEnr,RAF,Payment,BidRate,IsPaid,is_payment_cache,member_months)
	SELECT F1.Member_PK,F1.PaymentYear,4 PaymentHalf,F2.Community,F2.Institutional,F2.ESRD,F2.HOSP,F2.NewEnr,F2.RAF-F1.RAF RAF,F2.Payment-F1.Payment,F1.BidRate,0 IsPaid,0 is_payment_cache,
		CASE WHEN E.Months=@LastPaidMonthMY THEN 6 WHEN @LastPaidMonthMY=E.MaxMonth THEN E.Months+6-@LastPaidMonthMY ELSE E.Months END member_months
		FROM cacheFinance F1 
		INNER JOIN cacheFinance F2 ON F1.Member_PK = F2.Member_PK
		OUTER APPLY (SELECT COUNT(EligibleMonth) Months,MIN(Month(EligibleMonth)) MinMonth,Max(Month(EligibleMonth)) MaxMonth FROM tblCMSEligibility X WHERE YEAR(EligibleMonth)=@LastPaidYear AND X.Member_PK=F1.Member_PK AND MONTH(EligibleMonth)<=6) E
	WHERE F1.PaymentYear = @LastPaidYear AND F2.PaymentYear = @LastPaidYear AND F1.PaymentHalf=1 AND F2.PaymentHalf=2	

	--Final Year Cache
	SET @PY = @LastPaidYear-1
	SET @PH = 5
	SELECT @Trans_Date=SweepDeadline FROM tblSweep WHERE SweepYear=@LastPaidYear AND Sweep='Jan'
	SET @DOS_SDate = CAST(@LastPaidYear-2 AS VARCHAR)+'-1-1'
	SET @DOS_EDate = CAST(@LastPaidYear-2 AS VARCHAR)+'-12-31'
	EXEC prepareFinanceDetail @PaymentYear = @PY, @YearHalf = @PH, @DOS_Start = @DOS_SDate, @DOS_End = @DOS_EDate, @Paid=0, @Transaction=@Trans_Date,@payment_cache=0	
	
	INSERT INTO cacheFinance(Member_PK,PaymentYear,PaymentHalf,Community,Institutional,ESRD,HOSP,NewEnr,RAF,Payment,BidRate,IsPaid,is_payment_cache,member_months)
	SELECT F1.Member_PK,F1.PaymentYear,6 PaymentHalf,F2.Community,F2.Institutional,F2.ESRD,F2.HOSP,F2.NewEnr,F2.RAF-F1.RAF RAF,F2.Payment-F1.Payment,F1.BidRate,0 IsPaid,0 is_payment_cache,
		Months member_months
		FROM cacheFinance F1 
		INNER JOIN cacheFinance F2 ON F1.Member_PK = F2.Member_PK
		OUTER APPLY (SELECT COUNT(EligibleMonth) Months FROM tblCMSEligibility X WHERE YEAR(EligibleMonth)=@PY AND X.Member_PK=F1.Member_PK) E
	WHERE F1.PaymentYear = @PY AND F2.PaymentYear = @PY AND F1.PaymentHalf=0 AND F2.PaymentHalf=5		
END
GO
