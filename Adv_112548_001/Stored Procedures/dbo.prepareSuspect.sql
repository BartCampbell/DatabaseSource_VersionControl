SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To prepare Suspect
-- =============================================
/* Sample Executions
Truncate Table cacheSuspectHCC

EXEC prepareSuspect @SuspectPaymentYear=2014
*/
CREATE PROCEDURE [dbo].[prepareSuspect]
	@SuspectPaymentYear AS SmallInt
AS
BEGIN
	--************************************************************
	--************************************************************
	--Build List of HCCs from Past Years
	--************************************************************
	--************************************************************
	SELECT DISTINCT E.Member_PK,Community,Institutional,ESRD,HOSP,NewEnr,0 RAF,0 Payment INTO #tmp FROM tblCMSEligibility E
		Cross Apply (SELECT DISTINCT TOP 1 EligibleMonth FROM tblCMSEligibility 
			WHERE Member_PK = E.Member_PK 
					AND YEAR(EligibleMonth)=@SuspectPaymentYear
			Order By EligibleMonth DESC) T
	WHERE T.EligibleMonth = E.EligibleMonth
	ORDER BY E.Member_PK

	SELECT Member_PK,HCC,PaymentModel,MAX(Paid) Paid,MAX(RAPS) RAPS,MAX(Projected) Projected,0 Pharmacy,0 Lab INTO #HCCs FROM (
		SELECT DISTINCT Member_PK,HCC,PaymentModel,1 Paid,0 RAPS,0 Projected FROM tblMORHeader H 
			INNER JOIN tblMORDetailHCC D ON H.MORHeader_PK = D.MORHeader_PK
		WHERE H.PaymentYear<=@SuspectPaymentYear
		UNION
		SELECT DISTINCT Member_PK,MC.V12HCC HCC,12 PaymentModel,0 Paid,1 RAPS,0 Projected FROM tblRAPSData R 
			INNER JOIN tblModelCode MC ON MC.DiagnosisCode = R.DiagnosisCode AND R.IsICD10=MC.IsICD10
		WHERE YEAR(R.DOS_Thru)<@SuspectPaymentYear AND V12HCC IS NOT NULL
		UNION
		SELECT DISTINCT Member_PK,MC.V21HCC HCC,21 PaymentModel,0 Paid,1 RAPS,0 Projected  FROM tblRAPSData R 
			INNER JOIN tblModelCode MC ON MC.DiagnosisCode = R.DiagnosisCode AND R.IsICD10=MC.IsICD10
		WHERE YEAR(R.DOS_Thru)<@SuspectPaymentYear AND V21HCC IS NOT NULL
		UNION
		SELECT DISTINCT Member_PK,MC.V22HCC HCC,22 PaymentModel,0 Paid,1 RAPS,0 Projected  FROM tblRAPSData R 
			INNER JOIN tblModelCode MC ON MC.DiagnosisCode = R.DiagnosisCode AND R.IsICD10=MC.IsICD10
		WHERE YEAR(R.DOS_Thru)<@SuspectPaymentYear AND V22HCC IS NOT NULL
	) T GROUP BY Member_PK,HCC,PaymentModel

	/*
	Clearing HCC which are not required for the model
	*/
	DELETE H FROM #HCCs H INNER JOIN #tmp T ON T.Member_PK = H.Member_PK
		WHERE (T.ESRD=1 AND PaymentModel<>21) OR (T.ESRD<>1 AND PaymentModel=21)

	/*
	Inserting V12 to V22 HCC Mapping as Projected List
	*/
	INSERT INTO #HCCs(Member_PK,HCC,PaymentModel,Paid,RAPS,Projected,Pharmacy,Lab)
	SELECT DISTINCT Member_PK,M.V22HCC HCC,22 PaymentModel,0 Paid,0 RAPS,1 Projected,0 Pharmacy,0 Lab FROM #HCCs H
		INNER JOIN tblV12toV22 M ON M.V12HCC = H.HCC AND H.PaymentModel=12

	/*
	Inserting Projected List
	*/
	SELECT Member_PK,HCC,PaymentModel,HCC TrumpedHCC,MAX(Paid) Paid,MAX(RAPS) RAPS,MAX(Projected) Projected,0 Pharmacy,0 Lab INTO #HCCs2 FROM #HCCs
	GROUP BY Member_PK,HCC,PaymentModel

	--************************************************************
	--************************************************************
	--Apply HCC Trumping to all 3 models (V12,V21,V22)
	--************************************************************
	--************************************************************
	DECLARE @SQL VARCHAR(MAX)
	DECLARE @T_HCC smallint
	DECLARE @T_PaymentModel smallint
	DECLARE @T_TrumpedHCC VARCHAR(50)
	DECLARE TrumpHCC CURSOR LOCAL FOR SELECT HCC,PaymentModel,TrumpedHCC FROM tblHCCTrumping ORDER BY PaymentModel,HCC DESC

	OPEN TrumpHCC
	FETCH NEXT FROM TrumpHCC into @T_HCC,@T_PaymentModel,@T_TrumpedHCC
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SQL = 'Update FH SET FH.TrumpedHCC = '+CAST(@T_HCC AS VARCHAR)+'
			FROM #HCCs2 FH
				Cross Apply (SELECT * FROM #HCCs2 H WHERE H.Member_PK = FH.Member_PK AND H.PaymentModel = '+CAST(@T_PaymentModel AS VARCHAR)+' AND HCC='+CAST(@T_HCC AS VARCHAR)+') X
			WHERE FH.PaymentModel = '+CAST(@T_PaymentModel AS VARCHAR)+' AND FH.HCC IN ('+@T_TrumpedHCC+')';
	    
		EXEC (@SQL)

		FETCH NEXT FROM TrumpHCC into @T_HCC,@T_PaymentModel,@T_TrumpedHCC
	END

	CLOSE TrumpHCC
	DEALLOCATE TrumpHCC

	--Inserting Final List
	SELECT DISTINCT Member_PK,T.HCC,T.PaymentModel,Paid,RAPS,Pharmacy,Lab,Projected,MaxTrump INTO #HCCsList1 FROM #HCCs2 T 
		INNER JOIN tblHCC H ON H.HCC = T.HCC AND H.PaymentModel = T.PaymentModel
	WHERE T.TrumpedHCC=T.HCC
	
	--************************************************************
	--************************************************************
	--Build List of HCCs for Report Year
	--************************************************************
	--************************************************************
	SELECT Member_PK,HCC,PaymentModel,HCC TrumpedHCC INTO #HCCs3 FROM (
		SELECT DISTINCT Member_PK,MC.V12HCC HCC,12 PaymentModel,0 Paid,1 RAPS,0 Projected FROM tblRAPSData R 
			INNER JOIN tblModelCode MC ON MC.DiagnosisCode = R.DiagnosisCode AND R.IsICD10=MC.IsICD10
		WHERE YEAR(R.DOS_Thru)=@SuspectPaymentYear-1 AND V12HCC IS NOT NULL
		UNION
		SELECT DISTINCT Member_PK,MC.V21HCC HCC,21 PaymentModel,0 Paid,1 RAPS,0 Projected  FROM tblRAPSData R 
			INNER JOIN tblModelCode MC ON MC.DiagnosisCode = R.DiagnosisCode AND R.IsICD10=MC.IsICD10
		WHERE YEAR(R.DOS_Thru)=@SuspectPaymentYear-1 AND V21HCC IS NOT NULL
		UNION
		SELECT DISTINCT Member_PK,MC.V22HCC HCC,22 PaymentModel,0 Paid,1 RAPS,0 Projected  FROM tblRAPSData R 
			INNER JOIN tblModelCode MC ON MC.DiagnosisCode = R.DiagnosisCode AND R.IsICD10=MC.IsICD10
		WHERE YEAR(R.DOS_Thru)=@SuspectPaymentYear-1 AND V22HCC IS NOT NULL
	) T GROUP BY Member_PK,HCC,PaymentModel

	/*
	Clearing HCC which are not required for the model
	*/
	DELETE H FROM #HCCs3 H INNER JOIN #tmp T ON T.Member_PK = H.Member_PK
		WHERE (T.ESRD=1 AND PaymentModel<>21) OR (T.ESRD<>1 AND PaymentModel=21)

	--************************************************************
	--************************************************************
	--Apply HCC Trumping to all 3 models (V12,V21,V22)
	--************************************************************
	--************************************************************
	DECLARE TrumpHCC CURSOR LOCAL FOR SELECT HCC,PaymentModel,TrumpedHCC FROM tblHCCTrumping ORDER BY PaymentModel,HCC DESC

	OPEN TrumpHCC
	FETCH NEXT FROM TrumpHCC into @T_HCC,@T_PaymentModel,@T_TrumpedHCC
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SQL = 'Update FH SET FH.TrumpedHCC = '+CAST(@T_HCC AS VARCHAR)+'
			FROM #HCCs3 FH
				Cross Apply (SELECT * FROM #HCCs3 H WHERE H.Member_PK = FH.Member_PK AND H.PaymentModel = '+CAST(@T_PaymentModel AS VARCHAR)+' AND HCC='+CAST(@T_HCC AS VARCHAR)+') X
			WHERE FH.PaymentModel = '+CAST(@T_PaymentModel AS VARCHAR)+' AND FH.HCC IN ('+@T_TrumpedHCC+')';
	    
		EXEC (@SQL)

		FETCH NEXT FROM TrumpHCC into @T_HCC,@T_PaymentModel,@T_TrumpedHCC
	END

	CLOSE TrumpHCC
	DEALLOCATE TrumpHCC

	--Inserting Final List
	SELECT DISTINCT Member_PK,T.HCC,T.PaymentModel,MaxTrump INTO #HCCsList2 FROM #HCCs3 T 
		INNER JOIN tblHCC H ON H.HCC = T.HCC AND H.PaymentModel = T.PaymentModel
	WHERE T.TrumpedHCC=T.HCC
	
	--************************************************************
	--************************************************************
	--Making Suspect List
	--************************************************************
	--************************************************************
	--Truncate Table cacheSuspectHCC
	DELETE FROM cacheSuspectHCC WHERE SuspectYear=@SuspectPaymentYear
	INSERT INTO cacheSuspectHCC(Member_PK,SuspectYear,PreHCC,PreRAF,PostHCC,PostRAF,PaymentModel,Paid,RAPS,Projected,Pharmacy,Lab)
	SELECT Member_PK,@SuspectPaymentYear SuspectYear,MIN(X.PreHCC) PreHCC,0.0000 PreRAF,MIN(PostHCC) PostHCC,0.0000 PostRAF,X.PaymentModel,MAX(Paid) Paid,MAX(RAPS) RAPS,MAX(Projected) Projected,MAX(Pharmacy) Pharmacy,MAX(Lab) Lab FROM (
		SELECT DISTINCT Member_PK,T.HCC PreHCC,T.PaymentModel,Paid,RAPS,Projected,Pharmacy,Lab,MaxTrump,NULL PostHCC FROM #HCCsList1 T
		UNION
		SELECT DISTINCT Member_PK,NULL HCC,T.PaymentModel,0 Paid,0 RAPS,0 Projected,0 Pharmacy,0 Lab,MaxTrump,HCC PostHCC FROM #HCCsList2 T
	) X GROUP BY Member_PK,X.PaymentModel,MaxTrump

	--************************************************************
	--************************************************************
	--Applying HCC Rate
	--************************************************************
	--************************************************************
	--DECLARE @SuspectPaymentYear AS SMALLINT = 2014
	DECLARE @V12Ratio AS Float = 1
	DECLARE @V22Ratio AS FLOAT = 0
	If (@SuspectPaymentYear=2014)
	BEGIN
		SET @V12Ratio = 0.25
		SET @V22Ratio = 0.75
	END
	ELSE If (@SuspectPaymentYear<2014)
	BEGIN
		SET @V12Ratio = 1
		SET @V22Ratio = 0
	END
	ELSE If (@SuspectPaymentYear>2014)
	BEGIN
		SET @V12Ratio = 0.67
		SET @V22Ratio = 0.33
	END
	
	--Reading Adjustment Values
	DECLARE @FFS_V12 AS Float
	DECLARE @FFS_V22 AS Float
	DECLARE @FFS_V21 AS Float
	DECLARE @FFS_FG AS Float
	DECLARE @Coding_Intensity AS Float
	SELECT @FFS_V12=FFS_V12,@FFS_V22=FFS_V22,@FFS_V21=FFS_V21,@FFS_FG=FFS_FG,@Coding_Intensity=Coding_Intensity FROM tblAdjustment WHERe RateYear=@SuspectPaymentYear
	
	--Applying HCC Rates using Member Medicare Status for all models (V12,V21,V22) for preHCC
	Update H SET PreRAF = dbo.tmi_udf_AdjRAF(CASE WHEN F.Community=1 THEN HR.Community WHEN F.Institutional=1 THEN HR.Institutional ELSE HR.ESRD END * CASE WHEN H.PaymentModel=12 THEN @V12Ratio WHEN H.PaymentModel=22 THEN @V22Ratio ELSE 1 END,CASE WHEN H.PaymentModel=12 THEN @FFS_V12 WHEN H.PaymentModel=22 THEN @FFS_V22 ELSE @FFS_V21 END,@Coding_Intensity)
	FROM cacheSuspectHCC H
	INNER JOIN #tmp F ON F.Member_PK = H.Member_PK
	INNER JOIN tblHCCRate HR ON HR.HCC = H.PreHCC AND HR.PaymentModel=H.PaymentModel AND HR.RateYear = @SuspectPaymentYear 
	WHERE H.SuspectYear = @SuspectPaymentYear
	
	--Applying HCC Rates using Member Medicare Status for all models (V12,V21,V22) for postHCC
	Update H SET postRAF = dbo.tmi_udf_AdjRAF(CASE WHEN F.Community=1 THEN HR.Community WHEN F.Institutional=1 THEN HR.Institutional ELSE HR.ESRD END * CASE WHEN H.PaymentModel=12 THEN @V12Ratio WHEN H.PaymentModel=22 THEN @V22Ratio ELSE 1 END,CASE WHEN H.PaymentModel=12 THEN @FFS_V12 WHEN H.PaymentModel=22 THEN @FFS_V22 ELSE @FFS_V21 END,@Coding_Intensity)
	FROM cacheSuspectHCC H
	INNER JOIN #tmp F ON F.Member_PK = H.Member_PK
	INNER JOIN tblHCCRate HR ON HR.HCC = H.postHCC AND HR.PaymentModel=H.PaymentModel AND HR.RateYear = @SuspectPaymentYear 
	WHERE H.SuspectYear = @SuspectPaymentYear	
	
	--Inserting Summary Data
	DELETE FROM cacheSuspect WHERE SuspectYear = @SuspectPaymentYear
	INSERT INTO cacheSuspect(Member_PK,SuspectYear,PreHCCs,PreRAF,PostHCCs,PostRAF,BidRate)
	SELECT Member_PK,SuspectYear,COUNT(PreHCC) PreHCCs,SUM(PreRAF) PreRAF,COUNT(PostHCC) PostHCCs,SUM(PostRAF) PostRAF,0 BidRate FROM cacheSuspectHCC WHERE SuspectYear = @SuspectPaymentYear GROUP BY Member_PK,SuspectYear
	
	Update H SET BidRate = 700
	FROM cacheSuspect H
	WHERE H.SuspectYear = @SuspectPaymentYear
	
END
GO
