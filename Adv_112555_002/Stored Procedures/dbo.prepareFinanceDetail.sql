SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To prepare Finance Report Details
-- =============================================
/* Sample Executions
Truncate Table cacheFinanceDmg
Truncate Table cacheFinanceHCC
Truncate Table cacheFinanceInteraction
Truncate Table cacheFinance

EXEC prepareFinanceDetail @PaymentYear = 2012, @YearHalf = 0, @DOS_Start = '2011-1-1', @DOS_End = '2011-12-31', @Paid=1, @Transaction='2013-01-25',@payment_cache=1
EXEC prepareFinanceDetail @PaymentYear = 2013, @YearHalf = 0, @DOS_Start = '2012-1-1', @DOS_End = '2012-12-31', @Paid=1, @Transaction='2013-03-25',@payment_cache=1
EXEC prepareFinanceDetail @PaymentYear = 2014, @YearHalf = 1, @DOS_Start = '2012-7-1', @DOS_End = '2013-6-30', @Paid=1, @Transaction='2013-09-25',@payment_cache=1
EXEC prepareFinanceDetail @PaymentYear = 2014, @YearHalf = 2, @DOS_Start = '2013-1-1', @DOS_End = '2013-12-31', @Paid=0, @Transaction='2014-03-25',@payment_cache=1
EXEC prepareFinanceDetail @PaymentYear = 2015, @YearHalf = 1, @DOS_Start = '2013-7-1', @DOS_End = '2014-6-30', @Paid=0, @Transaction='2014-09-25',@payment_cache=1
*/
CREATE PROCEDURE [dbo].[prepareFinanceDetail]
	@PaymentYear AS SmallInt,
	@YearHalf AS TinyInt,
	@DOS_Start AS Date,
	@DOS_End AS Date,
	@Paid AS BIT,
	@Transaction AS Date,
	@payment_cache AS BIT
AS
BEGIN
	--Setting Variables
	DECLARE @AgeDate AS Date = CAST(@PaymentYear AS VARCHAR)+'-2-1';
	DECLARE @V12Ratio AS Float = 1
	DECLARE @V22Ratio AS FLOAT = 0
	If (@PaymentYear=2014)
	BEGIN
		SET @V12Ratio = 0.25
		SET @V22Ratio = 0.75
	END
	ELSE If (@PaymentYear<2014)
	BEGIN
		SET @V12Ratio = 1
		SET @V22Ratio = 0
	END
	ELSE If (@PaymentYear>2014)
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
	SELECT @FFS_V12=FFS_V12,@FFS_V22=FFS_V22,@FFS_V21=FFS_V21,@FFS_FG=FFS_FG,@Coding_Intensity=Coding_Intensity FROM tblAdjustment WHERe RateYear=@PaymentYear

	--Clearing Finance Cache, This SP will repopulate it
	DELETE FD FROM cacheFinanceDmg FD INNER JOIN cacheFinance F ON F.CacheFinance_PK = FD.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
	DELETE FD FROM cacheFinanceHCC FD INNER JOIN cacheFinance F ON F.CacheFinance_PK = FD.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
	DELETE FD FROM cacheFinanceInteraction FD INNER JOIN cacheFinance F ON F.CacheFinance_PK = FD.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
	DELETE F FROM cacheFinance F WHERE PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf

	--Inserting list of eligible members with their respective MEDICAID status (using last month from paid period)
	--@YearHalf=5 is in case of Final Reconciliations
	IF (@Paid = 1 OR @YearHalf=5)
	BEGIN
		Insert Into cacheFinance(Member_PK,PaymentYear,PaymentHalf,Community,Institutional,ESRD,HOSP,NewEnr,RAF,Payment,is_payment_cache,IsPaid)
		SELECT DISTINCT E.Member_PK,@PaymentYear PaymentYear,@YearHalf PaymentHalf,Community,Institutional,ESRD,HOSP,NewEnr,0 RAF,0 Payment,@payment_cache is_payment_cache,@Paid IsPaid FROM tblCMSEligibility E
			Cross Apply (SELECT DISTINCT TOP 1 EligibleMonth FROM tblCMSEligibility 
				WHERE Member_PK = E.Member_PK 
						AND YEAR(EligibleMonth)=@PaymentYear 
						AND 
						(
							(@YearHalf=1 AND Month(E.EligibleMonth) IN (1,2,3,4,5,6))
								OR
							(@YearHalf IN (2,5) AND Month(E.EligibleMonth) IN (7,8,9,10,11,12))
								OR 
							 @YearHalf=0
						 ) 
				Order By EligibleMonth DESC) T
		WHERE T.EligibleMonth = E.EligibleMonth
		ORDER BY E.Member_PK
				
		--To get Most recent MOR in temporary table
		SELECT DISTINCT MORHeader_PK,CacheFinance_PK INTO #tmpCacheFinanceMOR FROM tblMORHeader H 
			INNER JOIN cacheFinance F ON F.Member_PK = H.Member_PK AND F.PaymentYear=@PaymentYear AND F.PaymentHalf=@YearHalf
			Outer Apply (SELECT MAX(RunDate) RunDate from tblMORHeader WHERE PaymentYear=@PaymentYear AND Member_PK=H.Member_PK) T
		WHERE H.PaymentYear=@PaymentYear AND T.RunDate = H.RunDate AND ((@YearHalf=1 AND H.PaymentMonth<=6) OR @YearHalf<>1)
	
		--Demographics from MOR to cache
		INSERT INTO cacheFinanceDmg(CacheFinance_PK,Dmg_PK,RAF)
		SELECT H.CacheFinance_PK,Dmg_PK,0 FROM tblMORDetailDmg D INNER JOIN #tmpCacheFinanceMOR H ON D.MORHeader_PK = H.MORHeader_PK
		
		--HCCs from MOR to cache
		INSERT INTO cacheFinanceHCC(CacheFinance_PK,HCC,PaymentModel,TrumpedHCC,RAF)
		SELECT H.CacheFinance_PK,HCC,PaymentModel,HCC,0 FROM tblMORDetailHCC D INNER JOIN #tmpCacheFinanceMOR H ON D.MORHeader_PK = H.MORHeader_PK
		
		--Interactions from MOR to cache
		IF (@Paid = 1) -- Not for Final Reconciliations
		BEGIN
			INSERT INTO cacheFinanceInteraction(CacheFinance_PK,Interaction_PK,PaymentModel,RAF)
			SELECT H.CacheFinance_PK,Interaction_PK,PaymentModel,0 FROM tblMORDetailInteraction D INNER JOIN #tmpCacheFinanceMOR H ON D.MORHeader_PK = H.MORHeader_PK
		END
	 END

	 IF (@Paid = 0)
	 BEGIN	
		DECLARE @EligibleMonth AS Date
		SELECT DISTINCT TOP 1 @EligibleMonth = EligibleMonth FROM tblCMSEligibility ORDER BY EligibleMonth DESC
		
		IF (@YearHalf<>5)
		BEGIN
			Insert Into cacheFinance(Member_PK,PaymentYear,PaymentHalf,Community,Institutional,ESRD,HOSP,NewEnr,RAF,Payment)
			SELECT DISTINCT E.Member_PK,@PaymentYear PaymentYear,@YearHalf PaymentHalf,Community,Institutional,ESRD,HOSP,NewEnr,0 RAF,0 Payment FROM tblCMSEligibility E
			WHERE E.EligibleMonth = @EligibleMonth
			ORDER BY E.Member_PK
			
			--************************************************************
			--************************************************************
			--Inserting Demographic Info
			--************************************************************
			--************************************************************
			Insert Into cacheFinanceDmg(cacheFinance_PK,Dmg_Pk,RAF)
			SELECT cacheFinance_PK,Dmg_Pk,0 
			FROM tblMember M 
			INNER JOIN cacheFinance CF ON M.Member_PK = CF.Member_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
			INNER JOIN tblDmg D 
			ON D.Age_Low<=DATEDIFF(YEAR,DOB,@AgeDate) AND D.Age_High>=DATEDIFF(YEAR,DOB,@AgeDate)
			WHERE ((D.IsMale = 1 AND Gender='M') OR (D.IsMale = 0 AND Gender<>'M'))

			--Disability Info in Demographic for Member Disable in any year
			--DECLARE @PaymentYear AS INT = 2014
			--DECLARE @YearHalf AS INT = 1
			Insert Into cacheFinanceDmg(cacheFinance_PK,Dmg_Pk,RAF)
			SELECT DISTINCT CF.cacheFinance_PK,D.Dmg_Pk,0 RAF 
			FROM cacheFinanceDmg FD
				INNER JOIN cacheFinance F ON FD.cacheFinance_PK = F.cacheFinance_PK AND F.PaymentYear<>@PaymentYear --AND F.PaymentHalf<>@YearHalf
				INNER JOIN tblDmg D ON D.Dmg_PK = FD.Dmg_PK AND D.Dmg_Desc Like 'Originally Disabled%'
				INNER JOIN cacheFinance CF ON CF.Member_PK=F.Member_PK AND CF.PaymentYear=@PaymentYear AND CF.PaymentHalf=@YearHalf	
				OUTER APPLY (SELECT Dmg_PK FROM cacheFinanceDmg X WHERE X.cacheFinance_PK = CF.cacheFinance_PK AND D.Dmg_PK = X.Dmg_PK) T
			WHERE T.Dmg_PK IS NULL

			--Disability Info in Demographic for Member less that 65 age
			Insert Into cacheFinanceDmg(cacheFinance_PK,Dmg_Pk,RAF)
			SELECT DISTINCT CF.cacheFinance_PK,D2.Dmg_Pk,0 RAF
			FROM cacheFinanceDmg FD
				INNER JOIN cacheFinance CF ON FD.cacheFinance_PK = CF.cacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				INNER JOIN tblDmg D1 ON D1.Dmg_PK = FD.Dmg_PK AND D1.Age_High>0 AND D1.Age_High<65
				INNER JOIN tblDmg D2 ON D2.Dmg_Desc Like 'Originally Disabled%' AND D1.IsMale = D2.IsMale
				OUTER APPLY (SELECT Dmg_PK FROM cacheFinanceDmg X WHERE X.cacheFinance_PK = CF.cacheFinance_PK AND D2.Dmg_PK = X.Dmg_PK) T
			WHERE T.Dmg_PK IS NULL
		END

		--************************************************************
		--************************************************************
		--Inserting HCC reading RAPS
		--************************************************************
		--************************************************************

		--V21 HCC Insertion for ESRD Members
		INSERT INTO cacheFinanceHCC(CacheFinance_PK,HCC,PaymentModel,TrumpedHCC)
		SELECT DISTINCT CF.CacheFinance_PK,MC.V21HCC HCC,21 PaymentModel,MC.V21HCC TrumpedHCC FROM tblRAPSData R
		INNER JOIN tblModelCode MC ON MC.DiagnosisCode = R.DiagnosisCode AND MC.IsICD10 = R.IsICD10
		INNER JOIN cacheFinance CF ON CF.Member_PK = R.Member_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
		LEFT JOIN cacheFinanceHCC FH ON FH.CacheFinance_PK = CF.CacheFinance_PK AND FH.PaymentModel = 21 AND FH.HCC = MC.V21HCC
		WHERE FH.CacheFinance_PK IS NULL AND CF.ESRD = 1 AND MC.V21HCC IS NOT NULL AND R.DOS_Thru>=@DOS_Start AND R.DOS_Thru<=@DOS_End AND R.TransactionDate<=@Transaction

		IF (@V22Ratio>0)
		BEGIN
			--V22 HCC Insertion for ESRD Members
			INSERT INTO cacheFinanceHCC(CacheFinance_PK,HCC,PaymentModel,TrumpedHCC)
			SELECT DISTINCT F.CacheFinance_PK,MC.V22HCC HCC,22 PaymentModel,MC.V22HCC TrumpedHCC FROM tblRAPSData R
			INNER JOIN tblModelCode MC ON MC.DiagnosisCode = R.DiagnosisCode AND MC.IsICD10 = R.IsICD10
			INNER JOIN cacheFinance F ON F.Member_PK = R.Member_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
			LEFT JOIN cacheFinanceHCC FH ON FH.CacheFinance_PK = F.CacheFinance_PK AND FH.PaymentModel = 22 AND FH.HCC = MC.V22HCC
			WHERE FH.CacheFinance_PK IS NULL AND (F.Community=1 OR F.Institutional=1) AND MC.V22HCC IS NOT NULL AND R.DOS_Thru>=@DOS_Start AND R.DOS_Thru<=@DOS_End AND R.TransactionDate<=@Transaction
		END

		IF (@V12Ratio>0)
		BEGIN
			--V12 HCC Insertion for ESRD Members
			INSERT INTO cacheFinanceHCC(CacheFinance_PK,HCC,PaymentModel,TrumpedHCC)
			SELECT DISTINCT F.CacheFinance_PK,MC.V12HCC HCC,12 PaymentModel,MC.V12HCC TrumpedHCC FROM tblRAPSData R
			INNER JOIN tblModelCode MC ON MC.DiagnosisCode = R.DiagnosisCode AND MC.IsICD10 = R.IsICD10
			INNER JOIN cacheFinance F ON F.Member_PK = R.Member_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
			LEFT JOIN cacheFinanceHCC FH ON FH.CacheFinance_PK = F.CacheFinance_PK AND FH.PaymentModel = 12 AND FH.HCC = MC.V12HCC
			WHERE FH.CacheFinance_PK IS NULL AND (F.Community=1 OR F.Institutional=1) AND MC.V12HCC IS NOT NULL AND R.DOS_Thru>=@DOS_Start AND R.DOS_Thru<=@DOS_End AND R.TransactionDate<=@Transaction
		END

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
				FROM cacheFinanceHCC FH
					INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear='+CAST(@PaymentYear AS VARCHAR)+' AND PaymentHalf='+CAST(@YearHalf AS VARCHAR)+'
					Cross Apply (SELECT * FROM cacheFinanceHCC H WHERE H.CacheFinance_PK = F.CacheFinance_PK AND H.PaymentModel = '+CAST(@T_PaymentModel AS VARCHAR)+' AND HCC='+CAST(@T_HCC AS VARCHAR)+') X
				WHERE FH.PaymentModel = '+CAST(@T_PaymentModel AS VARCHAR)+' AND FH.HCC IN ('+@T_TrumpedHCC+')';
		    
			EXEC (@SQL)

			FETCH NEXT FROM TrumpHCC into @T_HCC,@T_PaymentModel,@T_TrumpedHCC
		END

		CLOSE TrumpHCC
		DEALLOCATE TrumpHCC

		--************************************************************
		--************************************************************
		--Inserting Disease Interactions for all 3 models (V12,V21,V22)
		--************************************************************
		--************************************************************

		Insert Into cacheFinanceInteraction(CacheFinance_PK,Interaction_PK,PaymentModel)
		SELECT CacheFinance_PK,I.Interaction_PK,PaymentModel FROM (
		--V12 Disease Interactions
			--DIABETES_CHF
			SELECT DISTINCT F.CacheFinance_PK,'DIABETES_CHF' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (15,16,17,18,19)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'DIABETES_CHF' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (80)	
			UNION
			--DM_CVD
			SELECT DISTINCT F.CacheFinance_PK,'DM_CVD' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (15,16,17,18,19)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'DM_CVD' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (95,96,100,101)		
			UNION
			--CHF_COPD
			SELECT DISTINCT F.CacheFinance_PK,'CHF_COPD' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (80)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'CHF_COPD' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (108)
			UNION
			--COPD_CVD_CAD
			SELECT DISTINCT F.CacheFinance_PK,'COPD_CVD_CAD' Interaction,FH.PaymentModel, 3 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (108)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'COPD_CVD_CAD' Interaction,FH.PaymentModel, 3 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (95,96,100,101)	
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'COPD_CVD_CAD' Interaction,FH.PaymentModel, 3 TotalDisease, 3 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (81,82,83)
			UNION	
			--CHF_RENAL
			SELECT DISTINCT F.CacheFinance_PK,'CHF_RENAL' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (80)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'CHF_RENAL' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (131)
			UNION
			--RF_CHF_DM
			SELECT DISTINCT F.CacheFinance_PK,'RF_CHF_DM' Interaction,FH.PaymentModel, 3 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (131)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'RF_CHF_DM' Interaction,FH.PaymentModel, 3 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (80)	
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'RF_CHF_DM' Interaction,FH.PaymentModel, 3 TotalDisease, 3 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=12 AND FH.HCC IN (15,16,17,18,19)	
		--V22 Disease Interactions
			--CANCER_IMMUNE
			UNION		
			SELECT DISTINCT F.CacheFinance_PK,'CANCER_IMMUNE' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (8,9,10,11,12)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'CANCER_IMMUNE' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (47)		
			--CHF_COPD
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'CHF_COPD' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (85)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'CHF_COPD' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (110,111)
			--CHF_RENAL
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'CHF_RENAL' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (85)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'CHF_RENAL' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (134,135,136,137)
			--CHF_RENAL
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'CHF_RENAL' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (85)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'CHF_RENAL' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (134,135,136,137)		
			--COPD_CARD_RESP_FAIL
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'COPD_CARD_RESP_FAIL' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (110,111)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'COPD_CARD_RESP_FAIL' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (82,83,84)		
			--DIABETES_CHF
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'DIABETES_CHF' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (17,18,19)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'DIABETES_CHF' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (85)
			--SEPSIS_CARD_RESP_FAIL 
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SEPSIS_CARD_RESP_FAIL' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (2)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SEPSIS_CARD_RESP_FAIL' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (82,83,84)		
			--ART_OPENINGS_PRESSURE_ULCER 
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'ART_OPENINGS_PRESSURE_ULCER' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (188)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'ART_OPENINGS_PRESSURE_ULCER' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (157,158)
			--ASP_SPEC_BACT_PNEUM_PRES_ULC 
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'ASP_SPEC_BACT_PNEUM_PRES_ULC' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (114)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'ASP_SPEC_BACT_PNEUM_PRES_ULC' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (157,158)
			--ASP_SPEC_BACT_PNEUM_PRES_ULC 
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'ASP_SPEC_BACT_PNEUM_PRES_ULC' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (114)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'ASP_SPEC_BACT_PNEUM_PRES_ULC' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (157,158)
			--COPD_ASP_SPEC_BACT_PNEUM 
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'COPD_ASP_SPEC_BACT_PNEUM' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (110,111)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'COPD_ASP_SPEC_BACT_PNEUM' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (114)
			--SCHIZO-PHRENIA_CHF 
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SCHIZO-PHRENIA_CHF' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (57)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SCHIZO-PHRENIA_CHF' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (85)						
			--SCHIZO-PHRENIA_COPD
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SCHIZO-PHRENIA_COPD' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (57)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SCHIZO-PHRENIA_COPD' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (110,111)					
			--SCHIZO-PHRENIA_SEIZURES
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SCHIZO-PHRENIA_SEIZURES' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (57)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SCHIZO-PHRENIA_SEIZURES' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (79)
			--SEPSIS_ARTIF_OPENINGS
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SEPSIS_ARTIF_OPENINGS' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (2)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SEPSIS_ARTIF_OPENINGS' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (188)
			--SEPSIS_ASP_SPEC_BACT_PNEUM			
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SEPSIS_ASP_SPEC_BACT_PNEUM' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (2)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SEPSIS_ASP_SPEC_BACT_PNEUM' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (114)	
			--SEPSIS_PRESSURE_ULCER			
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SEPSIS_PRESSURE_ULCER' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (2)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SEPSIS_PRESSURE_ULCER' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (157,158)
		--V21 Disease Interactions
			--SEPSIS_CARD_RESP_FAIL
			UNION		
			SELECT DISTINCT F.CacheFinance_PK,'SEPSIS_CARD_RESP_FAIL' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (2)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'SEPSIS_CARD_RESP_FAIL' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (82,83,84)
			--CANCER_IMMUNE
			UNION		
			SELECT DISTINCT F.CacheFinance_PK,'CANCER_IMMUNE' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (8,9,10,11,12)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'CANCER_IMMUNE' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (47)	
			--DIABETES_CHF
			UNION		
			SELECT DISTINCT F.CacheFinance_PK,'DIABETES_CHF' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (17,18,19)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'DIABETES_CHF' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (85)
			--CHF_COPD
			UNION		
			SELECT DISTINCT F.CacheFinance_PK,'CHF_COPD' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (85)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'CHF_COPD' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (110,111)
			--COPD_CARD_RESP_FAIL
			UNION		
			SELECT DISTINCT F.CacheFinance_PK,'COPD_CARD_RESP_FAIL' Interaction,FH.PaymentModel, 2 TotalDisease, 1 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (110,111)
			UNION
			SELECT DISTINCT F.CacheFinance_PK,'COPD_CARD_RESP_FAIL' Interaction,FH.PaymentModel, 2 TotalDisease, 2 DiseaseNum
				FROM cacheFinanceHCC FH INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
				WHERE FH.PaymentModel=22 AND FH.HCC IN (82,83,84)
		) DI LEFT JOIN tblInteraction I ON I.Interaction = DI.Interaction
		GROUP BY CacheFinance_PK,I.Interaction_PK,PaymentModel Having MAX(TotalDisease)=COUNT(DiseaseNum)
		ORDER BY I.Interaction_PK

		--*********************************************************************************
		--For V12 Model Removing 'CHF_RENAL' AND 'DIABETES_CHF' WHERE 'RF_CHF_DM' exists
		--*********************************************************************************
		DELETE FH
		FROM cacheFinanceInteraction FH
		INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
		INNER JOIN tblInteraction I ON I.Interaction_PK = FH.Interaction_PK
		Cross Apply (SELECT _FH.* FROM cacheFinanceInteraction _FH INNER JOIN tblInteraction _I ON F.CacheFinance_PK = _FH.CacheFinance_PK AND _I.Interaction_PK = _FH.Interaction_PK WHERE _I.Interaction='RF_CHF_DM' AND _FH.PaymentModel=12) T
		WHERE I.Interaction IN ('DIABETES_CHF','CHF_RENAL') AND FH.PaymentModel=12
					
	 END

	--*****************************************************************
	--*****************************************************************
	--	Applying Factor Rates
	--*****************************************************************
	--*****************************************************************
	
	--**************** Demographic Rate ***************************
	IF (@V22Ratio>0)
	BEGIN
		--Applying V22 Rates for Community AND Institutional
		Update FD SET RAF = dbo.tmi_udf_AdjRAF(CASE WHEN F.Community=1 THEN DR.Community ELSE DR.Institutional END * @V22Ratio,@FFS_V22,@Coding_Intensity)
		FROM cacheFinanceDmg FD 
		INNER JOIN cacheFinance F ON F.CacheFinance_PK = FD.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
		INNER JOIN tblDmgRate DR ON DR.Dmg_PK = FD.Dmg_PK AND DR.RateYear = @PaymentYear AND DR.PaymentModel=22
		WHERE F.Community=1 OR F.Institutional=1
	END

	IF (@V12Ratio>0)
	BEGIN
		--Applying V22 Rates for Community AND Institution
		Update FD SET RAF = FD.RAF + dbo.tmi_udf_AdjRAF(CASE WHEN F.Community=1 THEN DR.Community ELSE DR.Institutional END * @V12Ratio,@FFS_V12,@Coding_Intensity)
		FROM cacheFinanceDmg FD 
		INNER JOIN cacheFinance F ON F.CacheFinance_PK = FD.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
		INNER JOIN tblDmgRate DR ON DR.Dmg_PK = FD.Dmg_PK AND DR.RateYear = @PaymentYear AND DR.PaymentModel=12
		WHERE F.Community=1 OR F.Institutional=1
	END

	--Applying V21 Rates for ESRD
	Update FD SET RAF = dbo.tmi_udf_AdjRAF(DR.ESRD,@FFS_V21,@Coding_Intensity)
	FROM cacheFinanceDmg FD
	INNER JOIN cacheFinance F ON F.CacheFinance_PK = FD.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
	INNER JOIN tblDmgRate DR ON DR.Dmg_PK = FD.Dmg_PK AND DR.RateYear = @PaymentYear AND DR.PaymentModel=21
	WHERE F.ESRD=1

	--**************** HCC Rate ***************************
	--Applying HCC Rates using Member Medicare Status for all models (V12,V21,V22)
	Update FH SET RAF = dbo.tmi_udf_AdjRAF(CASE WHEN F.Community=1 THEN HR.Community WHEN F.Institutional=1 THEN HR.Institutional ELSE HR.ESRD END * CASE WHEN FH.PaymentModel=12 THEN @V12Ratio WHEN FH.PaymentModel=22 THEN @V22Ratio ELSE 1 END,CASE WHEN FH.PaymentModel=12 THEN @FFS_V12 WHEN FH.PaymentModel=22 THEN @FFS_V22 ELSE @FFS_V21 END,@Coding_Intensity)
	FROM cacheFinanceHCC FH
	INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
	INNER JOIN tblHCCRate HR ON HR.HCC = FH.HCC AND HR.PaymentModel=FH.PaymentModel AND HR.RateYear = @PaymentYear 
	WHERE FH.TrumpedHCC = FH.HCC

	--**************** Interactions Rate ***************************	
	--Applying rates for Interactions using Member Medicare Status
	Update FH SET RAF = dbo.tmi_udf_AdjRAF(CASE WHEN F.Community=1 THEN HR.Community WHEN F.Institutional=1 THEN HR.Institutional ELSE HR.ESRD END * CASE WHEN FH.PaymentModel=12 THEN @V12Ratio WHEN FH.PaymentModel=22 THEN @V22Ratio ELSE 1 END,CASE WHEN FH.PaymentModel=12 THEN @FFS_V12 WHEN FH.PaymentModel=22 THEN @FFS_V22 ELSE @FFS_V21 END,@Coding_Intensity)
	FROM cacheFinanceInteraction FH
	INNER JOIN cacheFinance F ON F.CacheFinance_PK = FH.CacheFinance_PK AND PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
	INNER JOIN tblInteractionRate HR ON HR.Interaction_PK = FH.Interaction_PK AND HR.PaymentModel=FH.PaymentModel AND HR.RateYear = @PaymentYear 

	--*****************************************************************
	--*****************************************************************
	--	Updating RAF in Master cache using Dmg, HCC and Interaction caches
	--*****************************************************************
	--*****************************************************************
	Update F SET RAF = IsNull(FD.RAF,0)+IsNull(FH.RAF,0)+IsNull(FI.RAF,0), BidRate=700, Payment = CAST(IsNull(FD.RAF,0)+IsNull(FH.RAF,0)+IsNull(FI.RAF,0) AS MONEY) * CAST(700 AS MONEY)
	FROM cacheFinance F
		Outer Apply (SELECT SUM(RAF) RAF FROM cacheFinanceDmg WHERE CacheFinance_PK = F.CacheFinance_PK) FD
		Outer Apply (SELECT SUM(RAF) RAF FROM cacheFinanceHCC WHERE CacheFinance_PK = F.CacheFinance_PK) FH
		Outer Apply (SELECT SUM(RAF) RAF FROM cacheFinanceInteraction WHERE CacheFinance_PK = F.CacheFinance_PK) FI
	WHERE PaymentYear=@PaymentYear AND PaymentHalf=@YearHalf
END

GO
