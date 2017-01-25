SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/22/2016
-- Description:	Generates the IDSS file specific to HEDIS RRU measures.
-- =============================================
CREATE PROCEDURE [Ncqa].[IDSS_GenerateRRUValues]
(
	@DataRunID int,
	@PopulationID int,
	@ProductLineID smallint,
	@VendorID varchar(32),
	@SubmissionID varchar(32)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MeasureYear smallint;
	SELECT @MeasureYear = YEAR(MMS.DefaultSeedDate) FROM Measure.MeasureSets AS MMS INNER JOIN Batch.DataRuns AS BDR ON MMS.MeasureSetID = BDR.MeasureSetID WHERE BDR.DataRunID = @DataRunID;

	DECLARE @BitProductLines bigint;
	SELECT @BitProductLines = BitValue FROM Product.ProductLines WHERE ProductLineID = @ProductLineID;

	DECLARE @ProductLineM smallint;
	SELECT @ProductLineM = ProductLineID FROM Product.ProductLines WHERE Abbrev = 'M';

	DECLARE @FileVersion nvarchar(16);
	DECLARE @Version varchar(16);

	SELECT @Version = CASE @ProductLineID WHEN @ProductLineM THEN '2014.1' ELSE '2012.1' END;
	SELECT @FileVersion = CASE @ProductLineID WHEN @ProductLineM THEN '2014.1.1' ELSE '2012.3.0' END;

	IF OBJECT_ID('tempdb..#RRUAgeBands') IS NOT NULL
		DROP TABLE #RRUAgeBands;

	WITH RRUAgeBands(Measure, FromAge, ToAge, Abbrev, Descr) AS
	(
			  SELECT 'RDI', 18, 44, '1844', '18-44 years of age'
		UNION SELECT 'RDI', 45, 54, '4554', '45-54 years of age'
		UNION SELECT 'RDI', 55, 64, '5564', '55-64 years of age'
		UNION SELECT 'RDI', 65, 75, '6575', '65-75 years of age'
		UNION SELECT 'RCA', 18, 44, '1844', '18-44 years of age'
		UNION SELECT 'RCA', 45, 54, '4554', '45-54 years of age'
		UNION SELECT 'RCA', 55, 64, '5564', '55-64 years of age'
		UNION SELECT 'RCA', 65, 75, '6575', '65-75 years of age'
		UNION SELECT 'RCO', 42, 44, '4244', '42-44 years of age'
		UNION SELECT 'RCO', 45, 64, '4564', '45-64 years of age'
		UNION SELECT 'RCO', 65, 74, '6574', '65-74 years of age'
		UNION SELECT 'RCO', 75, 255, '75+', '75 years of age or older'
		UNION SELECT 'RAS',  5, 17, '0517', '5-17 years of age'
		UNION SELECT 'RAS', 18, 44, '1844', '18-44 years of age'
		UNION SELECT 'RAS', 45, 54, '4554', '45-54 years of age'
		UNION SELECT 'RAS', 65, 85, '6585', '68-85 years of age'
		UNION SELECT 'RAS', 55, 64, '5564', '55-64 years of age'
		UNION SELECT 'RHY', 18, 44, '1844', '18-44 years of age'
		UNION SELECT 'RHY', 45, 54, '4554', '45-54 years of age'
		UNION SELECT 'RHY', 55, 64, '5564', '55-64 years of age'
		UNION SELECT 'RHY', 65, 85, '6585', '65-84 years of age'
	)
	SELECT * INTO #RRUAgeBands FROM RRUAgeBands;

	CREATE UNIQUE CLUSTERED INDEX IX_#RRUAgeBands ON #RRUAgeBands (Measure, FromAge, ToAge);
	CREATE UNIQUE NONCLUSTERED INDEX IX_#RRUAgeBands2 ON #RRUAgeBands (Measure, Abbrev);

	IF OBJECT_ID('tempdb..#RRUFieldMapping') IS NOT NULL
		DROP TABLE #RRUFieldMapping;

	/*
	BitOption Values:
	----------------------------------------------------------------
	1 = Stardard Fields for HEDIS
	2 = Non-standard fields only in some measures for HEDIS
	4 = Standard Fields for QRS/Marketplace (Added 2015)
	*/

	WITH RRUFieldMapping(ColumnName, IdssName, SortOrder, BitOption) AS
	(
			  SELECT 'CostInpatientCapped', 'InpatFacCost', 1, 5
		UNION SELECT 'CostEMInpatientCapped', 'EvalAndMgmtInpatCost', 2, 1
		UNION SELECT 'CostEMOutpatientCapped', 'EvalAndMgmtOutpatCost', 3, 1
		UNION SELECT 'CostProcInpatientCapped', 'SurgAndProcInpatCost', 4, 1
		UNION SELECT 'CostProcOutpatientCapped', 'SurgAndProcOutpatCost', 5, 1
		UNION SELECT 'CostPharmacyCapped', 'PharmacyCost', 6, 1
		UNION SELECT 'CostImagingCapped', 'ImagCost', 7, 1
		UNION SELECT 'CostLabCapped', 'LabCost', 8, 1
		UNION SELECT 'FreqProcCABG', 'CABGCount', 9, 3
		UNION SELECT 'FreqProcCAD', 'CADDiagCount', 10, 3
		UNION SELECT 'FreqProcCardiacCath', 'CardiacCathCount', 11, 3
		UNION SELECT 'FreqProcCAT', 'CardiacCompTomoCount', 12, 3
		UNION SELECT 'FreqProcCAS', 'CarotidArtStenDiagCount', 13, 3
		UNION SELECT 'FreqProcEndarter', 'CarotidEndarCount', 14, 3
		UNION SELECT 'FreqED', 'EDDisCount', 15, 1
		UNION SELECT 'DaysAcuteInpatientNotSurg', 'InpatFacAcuMedDaysCount', 16, 5
		UNION SELECT 'FreqAcuteInpatientNotSurg', 'InpatFacAcuMedDisCount', 17, 5
		UNION SELECT 'DaysAcuteInpatientSurg', 'InpatFacAcuSurDaysCount', 18, 5
		UNION SELECT 'FreqAcuteInpatientSurg', 'InpatFacAcuSurDisCount', 19, 5
		UNION SELECT 'DaysNonacuteInpatient', 'InpatFacNonAcuDaysCount', 20, 5
		UNION SELECT 'FreqNonacuteInpatient', 'InpatFacNonAcuDisCount', 21, 5
		UNION SELECT 'FreqProcPCI', 'PCICount', 22, 3
		UNION SELECT 'MM', 'MemberMonMed', 23, 5
		UNION SELECT 'MMP', 'MemberMonPhar', 24, 1
	)
	SELECT * INTO #RRUFieldMapping FROM RRUFieldMapping;

	CREATE UNIQUE CLUSTERED INDEX IX_#RRUFieldMapping ON #RRUFieldMapping (ColumnName);

	IF OBJECT_ID('tempdb..#RRUBaseResults') IS NOT NULL
		DROP TABLE #RRUBaseResults;

	SELECT	RMD.BatchID,
			RMD.BitProductLines,
			RMD.DataRunID,
			RMD.DataSetID,
			RMD.DataSourceID,
			RMD.DSEntityID,
			RMD.DSMemberID,
			RMD.EnrollGroupID,
			RMD.EntityID,
			RMD.ExclusionTypeID,
			RMD.IsDenominator,
			RMD.IsExclusion,
			RMD.IsIndicator,
			RMD.IsNumerator,
			RMD.IsNumeratorAdmin,
			RMD.IsNumeratorMedRcd,
			RMD.KeyDate,
			MM.Abbrev AS Measure,
			MM.MeasureGuid,
			RMD.MeasureID,
			RMD.MeasureXrefID,
			MX.Abbrev AS Metric,
			RMD.MetricID,
			RMD.MetricXrefID,
			RMD.PayerID,
			RMD.PopulationID,
			RMD.ResultRowGuid,
			RMD.ResultRowID,
			RRU.Age,
			RRU.CostEMInpatient,
			RRU.CostEMInpatientCapped,
			RRU.CostEMOutpatient,
			RRU.CostEMOutpatientCapped,
			RRU.CostImaging,
			RRU.CostImagingCapped,
			RRU.CostInpatient,
			RRU.CostInpatientCapped,
			RRU.CostLab,
			RRU.CostLabCapped,
			RRU.CostPharmacy,
			RRU.CostPharmacyCapped,
			RRU.CostProcInpatient,
			RRU.CostProcInpatientCapped,
			RRU.CostProcOutpatient,
			RRU.CostProcOutpatientCapped,
			RRU.DaysAcuteInpatient,
			RRU.DaysAcuteInpatientNotSurg,
			RRU.DaysAcuteInpatientSurg,
			RRU.DaysNonacuteInpatient,
			RRU.DemoWeight,
			RRU.FreqAcuteInpatient,
			RRU.FreqAcuteInpatientNotSurg,
			RRU.FreqAcuteInpatientSurg,
			RRU.FreqED,
			RRU.FreqNonacuteInpatient,
			RRU.FreqPharmG1,
			RRU.FreqPharmG2,
			RRU.FreqPharmN1,
			RRU.FreqPharmN2,
			RRU.FreqProcCABG,
			RRU.FreqProcCAD,
			RRU.FreqProcCardiacCath,
			RRU.FreqProcCAS,
			RRU.FreqProcCAT,
			RRU.FreqProcEndarter,
			RRU.FreqProcPCI,
			RRU.Gender,
			RRU.HClinCondWeight,
			RRU.MM,
			RRU.MMP,
			NRRC.Abbrev AS RiskCtgy,
			RRU.RiskCtgyID,
			RRU.TotalWeight
	INTO	#RRUBaseResults
	FROM	Result.MeasureDetail AS RMD
			INNER JOIN Measure.Metrics AS MX
					ON RMD.MetricID = MX.MetricID
			INNER JOIN Measure.Measures AS MM 
					ON RMD.MeasureID = MM.MeasureID
			INNER JOIN Measure.MeasureClasses AS MMC
					ON MM.MeasClassID = MMC.MeasClassID AND
						MMC.Abbrev = 'RRU'              
			LEFT OUTER JOIN Result.MeasureDetail_RRU AS RRU
					ON RMD.ResultRowGuid = RRU.SourceRowGuid AND
						RMD.BatchID = RRU.BatchID AND
						RMD.DataRunID = RRU.DataRunID AND
						RMD.DataSetID = RRU.DataSetID AND
						RMD.DSMemberID = RRU.DSMemberID              
			LEFT OUTER JOIN Ncqa.RRU_RiskCategories AS NRRC
					ON RRU.RiskCtgyID = NRRC.RiskCtgyID
	WHERE	RMD.DataRunID = @DataRunID AND
			RMD.PopulationID = @PopulationID AND
			RMD.BitProductLines & @BitProductLines > 0;

	CREATE UNIQUE CLUSTERED INDEX IX_#RRUBaseResults ON #RRUBaseResults (ResultRowID);
	CREATE NONCLUSTERED INDEX IX_#RRUBaseResults2 ON #RRUBaseResults (Measure, RiskCtgy, Age, Gender);

	IF OBJECT_ID('tempdb..#RRUIdssBase') IS NOT NULL
		DROP TABLE #RRUIdssBase;

	WITH MeasureStrata AS 
	(
		SELECT	RAB.Abbrev AS AgeBand,
				RAB.FromAge,
				RAB.ToAge,
				MG.Gender,
				LOWER(MG.Abbrev) AS GenderAbbrev,
				MM.Abbrev AS Measure,
				MM.MeasureID,
				NRRC.Abbrev AS RiskCtgy,
				NRRC.RiskCtgyID
		FROM	Measure.Measures AS MM
				INNER JOIN #RRUAgeBands AS RAB
						ON MM.Abbrev = RAB.Measure
				INNER JOIN Batch.DataRuns AS BDR
						ON MM.MeasureSetID = BDR.MeasureSetID AND
							BDR.DataRunID = @DataRunID                  
				INNER JOIN Measure.MeasureClasses AS MMC
						ON MM.MeasClassID = MMC.MeasClassID
				INNER JOIN Member.Genders AS MG
						ON MG.Gender BETWEEN 0 AND 1
				CROSS JOIN Ncqa.RRU_RiskCategories AS NRRC
		WHERE	MMC.Abbrev = 'RRU'
	)
	SELECT	MS.Measure,
			MS.MeasureID,
			MS.RiskCtgy,
			MS.RiskCtgyID,
			MS.AgeBand,
			MS.Gender,
			MS.GenderAbbrev,
			CONVERT(int, ROUND(ISNULL(SUM(t.CostInpatientCapped), 0), 0)) AS CostInpatientCapped,
			CONVERT(int, ROUND(ISNULL(SUM(t.CostEMInpatientCapped), 0), 0)) AS CostEMInpatientCapped, 
			CONVERT(int, ROUND(ISNULL(SUM(t.CostEMOutpatientCapped), 0), 0)) AS CostEMOutpatientCapped, 
			CONVERT(int, ROUND(ISNULL(SUM(t.CostProcInpatientCapped), 0), 0)) AS CostProcInpatientCapped, 
			CONVERT(int, ROUND(ISNULL(SUM(t.CostProcOutpatientCapped), 0), 0)) AS CostProcOutpatientCapped, 
			CONVERT(int, ROUND(ISNULL(SUM(t.CostPharmacyCapped), 0), 0)) AS CostPharmacyCapped, 
			CONVERT(int, ROUND(ISNULL(SUM(t.CostImagingCapped), 0), 0)) AS CostImagingCapped, 
			CONVERT(int, ROUND(ISNULL(SUM(t.CostLabCapped), 0), 0)) AS CostLabCapped, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqProcCABG), 0), 0)) AS FreqProcCABG, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqProcCAD), 0), 0)) AS FreqProcCAD, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqProcCardiacCath), 0), 0)) AS FreqProcCardiacCath, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqProcCAT), 0), 0)) AS FreqProcCAT, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqProcCAS), 0), 0)) AS FreqProcCAS, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqProcEndarter), 0), 0)) AS FreqProcEndarter, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqED), 0), 0)) AS FreqED, 
			CONVERT(int, ROUND(ISNULL(SUM(t.DaysAcuteInpatientNotSurg), 0), 0)) AS DaysAcuteInpatientNotSurg, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqAcuteInpatientNotSurg), 0), 0)) AS FreqAcuteInpatientNotSurg, 
			CONVERT(int, ROUND(ISNULL(SUM(t.DaysAcuteInpatientSurg), 0), 0)) AS DaysAcuteInpatientSurg, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqAcuteInpatientSurg), 0), 0)) AS FreqAcuteInpatientSurg, 
			CONVERT(int, ROUND(ISNULL(SUM(t.DaysNonacuteInpatient), 0), 0)) AS DaysNonacuteInpatient, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqNonacuteInpatient), 0), 0)) AS FreqNonacuteInpatient, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqProcPCI), 0), 0)) AS FreqProcPCI, 
			CONVERT(int, ROUND(ISNULL(SUM(t.MM), 0), 0)) AS MM, 
			CONVERT(int, ROUND(ISNULL(SUM(t.MMP), 0), 0)) AS MMP,
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqPharmG1), 0), 0)) AS FreqPharmG1, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqPharmG2), 0), 0)) AS FreqPharmG2,
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqPharmN1), 0), 0)) AS FreqPharmN1, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqPharmN2), 0), 0)) AS FreqPharmN2,
			CONVERT(int, ROUND(ISNULL(SUM(CONVERT(int, t.IsDenominator)), 0), 0)) AS IsDenominator,
			CONVERT(int, ROUND(ISNULL(SUM(CONVERT(int, t.IsIndicator)), 0), 0)) AS IsIndicator,
			IDENTITY(int, 1, 1) AS RowID
	INTO	#RRUIdssBase
	FROM	#RRUBaseResults AS t
			RIGHT OUTER JOIN MeasureStrata AS MS
					ON t.Gender = MS.Gender AND
						t.Measure = MS.Measure AND
						t.MeasureID = MS.MeasureID AND
						t.RiskCtgy = MS.RiskCtgy AND
						t.RiskCtgyID = MS.RiskCtgyID AND
						t.Age BETWEEN MS.FromAge AND MS.ToAge AND
						t.IsDenominator = 1                  
	GROUP BY MS.Measure, MS.MeasureID, MS.RiskCtgy, MS.RiskCtgyID, MS.AgeBand, MS.Gender, MS.GenderAbbrev
	ORDER BY MS.Measure, MS.RiskCtgyID, MS.AgeBand, MS.Gender DESC;

	SELECT  Measure,
			MIN(MM.MeasureGuid) AS [Guid],
			SUM(t.CostInpatientCapped) AS [Cost - Inpatient],
			SUM(t.CostEMInpatientCapped) [Cost - E & M, Inpatient],
			SUM(t.CostEMOutpatientCapped) AS [Cost - E & M, Outpatient],
			SUM(t.CostProcInpatientCapped) AS [Cost - Procedure, Inpatient],
			SUM(t.CostProcOutpatientCapped) AS [Cost - Procedure, Outpatient],
			SUM(t.CostPharmacyCapped) AS [Cost - Pharmacy],
			SUM(t.CostImagingCapped) AS [Cost - Imaging],
			SUM(t.CostLabCapped) AS [Cost - Lab],
			SUM(t.FreqProcCABG) AS [Frequency - Procedure, CABG],
			SUM(t.FreqProcCAD) AS [Frequency - Procedure, CAD],
			SUM(t.FreqProcCardiacCath) AS [Frequency - Cardiac Cath],
			SUM(t.FreqProcCAT) AS [Frequency - CAT],
			SUM(t.FreqProcCAS) AS [Frequency - CAS],
			SUM(t.FreqProcEndarter) AS [Frequency - Endarter],
			SUM(t.FreqProcPCI) AS [Frequency - PCI],
			SUM(t.FreqED) AS [Frequency - ED],
			SUM(t.DaysAcuteInpatientNotSurg) AS [Days - Inpatient, Medicine],
			SUM(t.FreqAcuteInpatientNotSurg) AS [Qty - Inpatient, Medicine],
			SUM(t.DaysAcuteInpatientSurg) AS [Days - Inpatient, Surgery],
			SUM(t.FreqAcuteInpatientSurg) AS [Qty - Inpatient, Surgery],
			SUM(t.DaysNonacuteInpatient) AS [Days - Inpatient, Nonacute],
			SUM(t.FreqNonacuteInpatient) AS [Qty - Inpatient, Nonacute],
			SUM(t.MM) AS [Mbr Months - Med],
			SUM(t.MMP) AS [Mbr Months - Pharm],
			SUM(t.FreqPharmG1) AS [Frequency - Pharm, Generic Only],
			SUM(t.FreqPharmG2) AS [Frequency - Pharm, Generic/Name Brand Available],
			SUM(t.FreqPharmN1) AS [Frequency - Pharm, Name Brand Only],
			SUM(t.FreqPharmN2) AS [Frequency - Pharm, Name Brand/Generic Available],
			SUM(t.IsDenominator) AS Denominator,
			SUM(t.IsIndicator) AS Exclusions
	FROM	#RRUIdssBase AS t
			INNER JOIN Measure.Measures AS MM
					ON MM.MeasureID = t.MeasureID
	GROUP BY t.Measure, t.MeasureID
	ORDER BY 1;

	SELECT  t.Measure,
			MIN(MM.MeasureGuid) AS [Guid],
			Member.ConvertGenderToMF(t.Gender) AS Gender,
			MIN(AB.Descr) AS [Age],
			SUM(t.CostInpatientCapped) AS [Cost - Inpatient],
			SUM(t.CostEMInpatientCapped) [Cost - E & M, Inpatient],
			SUM(t.CostEMOutpatientCapped) AS [Cost - E & M, Outpatient],
			SUM(t.CostProcInpatientCapped) AS [Cost - Procedure, Inpatient],
			SUM(t.CostProcOutpatientCapped) AS [Cost - Procedure, Outpatient],
			SUM(t.CostPharmacyCapped) AS [Cost - Pharmacy],
			SUM(t.CostImagingCapped) AS [Cost - Imaging],
			SUM(t.CostLabCapped) AS [Cost - Lab],
			SUM(t.FreqProcCABG) AS [Frequency - Procedure, CABG],
			SUM(t.FreqProcCAD) AS [Frequency - Procedure, CAD],
			SUM(t.FreqProcCardiacCath) AS [Frequency - Cardiac Cath],
			SUM(t.FreqProcCAT) AS [Frequency - CAT],
			SUM(t.FreqProcCAS) AS [Frequency - CAS],
			SUM(t.FreqProcEndarter) AS [Frequency - Endarter],
			SUM(t.FreqProcPCI) AS [Frequency - PCI],
			SUM(t.FreqED) AS [Frequency - ED],
			SUM(t.DaysAcuteInpatientNotSurg) AS [Days - Inpatient, Medicine],
			SUM(t.FreqAcuteInpatientNotSurg) AS [Qty - Inpatient, Medicine],
			SUM(t.DaysAcuteInpatientSurg) AS [Days - Inpatient, Surgery],
			SUM(t.FreqAcuteInpatientSurg) AS [Qty - Inpatient, Surgery],
			SUM(t.DaysNonacuteInpatient) AS [Days - Inpatient, Nonacute],
			SUM(t.FreqNonacuteInpatient) AS [Qty - Inpatient, Nonacute],
			SUM(t.MM) AS [Mbr Months - Med],
			SUM(t.MMP) AS [Mbr Months - Pharm],
			SUM(t.FreqPharmG1) AS [Frequency - Pharm, Generic Only],
			SUM(t.FreqPharmG2) AS [Frequency - Pharm, Generic/Name Brand Available],
			SUM(t.FreqPharmN1) AS [Frequency - Pharm, Name Brand Only],
			SUM(t.FreqPharmN2) AS [Frequency - Pharm, Name Brand/Generic Available],
			SUM(t.IsDenominator) AS Denominator,
			SUM(t.IsIndicator) AS Exclusions
	FROM	#RRUIdssBase AS t
			INNER JOIN Measure.Measures AS MM
					ON MM.MeasureID = t.MeasureID
			INNER JOIN #RRUAgeBands AS AB
					ON AB.Abbrev = t.AgeBand AND
						AB.Measure = t.Measure
	GROUP BY t.Measure, t.MeasureID, t.AgeBand, t.Gender
	ORDER BY Measure, Gender, MIN(AB.FromAge);

	CREATE UNIQUE CLUSTERED INDEX IX_#RRUIdssBase ON #RRUIdssBase (RowID);

	IF OBJECT_ID('tempdb..#RRUIdssUnpivot') IS NOT NULL
		DROP TABLE #RRUIdssUnpivot;

	SELECT	* 
	INTO	#RRUIdssUnpivot
	FROM	(SELECT * FROM #RRUIdssBase) AS t
			UNPIVOT 
			(
				[Value] FOR ColumnName IN (
											CostInpatientCapped, 
											CostEMInpatientCapped, 
											CostEMOutpatientCapped, 
											CostProcInpatientCapped, 
											CostProcOutpatientCapped, 
											CostPharmacyCapped, 
											CostImagingCapped, 
											CostLabCapped, 
											FreqProcCABG, 
											FreqProcCAD, 
											FreqProcCardiacCath, 
											FreqProcCAT, 
											FreqProcCAS, 
											FreqProcEndarter, 
											FreqED, 
											DaysAcuteInpatientNotSurg, 
											FreqAcuteInpatientNotSurg, 
											DaysAcuteInpatientSurg, 
											FreqAcuteInpatientSurg, 
											DaysNonacuteInpatient, 
											FreqNonacuteInpatient, 
											FreqProcPCI, 
											MM, 
											MMP,
											FreqPharmG1,
											FreqPharmG2,
											FreqPharmN1,
											FreqPharmN2,
											IsDenominator
										)
			) AS ut
	ORDER BY RowID;

	CREATE UNIQUE CLUSTERED INDEX IX_#RRUIdssUnpivot ON #RRUIdssUnpivot (RowID, ColumnName);

	DECLARE @Result xml;
	DECLARE @RAS xml, @RCA xml, @RCO xml, @RDI xml, @RHY xml;

	IF OBJECT_ID('tempdb..#HeaderXmlSource') IS NOT NULL
		DROP TABLE #HeaderXmlSource;

	SELECT DISTINCT
			Measure, 
			MeasureID,
			MeasureGuid
	INTO	#HeaderXmlSource
	FROM	#RRUBaseResults;

	CREATE UNIQUE CLUSTERED INDEX IX_#HeaderXmlSource_ ON #HeaderXmlSource (Measure);

	IF OBJECT_ID('tempdb..#MeasureXmlSource') IS NOT NULL
		DROP TABLE #MeasureXmlSource;

	SELECT	Measure, 
			MeasureID, 
			SUM(CONVERT(int, IsDenominator)) AS IsDenominator, 
			SUM(CONVERT(int, IsIndicator)) AS IsIndicator, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqPharmG1), 0), 0)) AS FreqPharmG1, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqPharmG2), 0), 0)) AS FreqPharmG2,
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqPharmN1), 0), 0)) AS FreqPharmN1, 
			CONVERT(int, ROUND(ISNULL(SUM(t.FreqPharmN2), 0), 0)) AS FreqPharmN2
	INTO	#MeasureXmlSource
	FROM	#RRUBaseResults AS t
	GROUP BY Measure, 
			MeasureID;

	--If QRS/Marketplace, remove pharmacy values from results (Added 2015)...
	IF @ProductLineID = @ProductLineM
		UPDATE	#MeasureXmlSource
		SET		FreqPharmG1 = NULL,
				FreqPharmG2 = NULL,
				FreqPharmN1 = NULL,
				FreqPharmN2 = NULL;

	CREATE UNIQUE CLUSTERED INDEX IX_#MeasureXmlSource ON #MeasureXmlSource (MeasureID);

	IF OBJECT_ID('tempdb..#MetricXmlSource') IS NOT NULL
		DROP TABLE #MetricXmlSource;

	SELECT	IU.*, FM.IdssName, FM.SortOrder
	INTO	#MetricXmlSource
	FROM	#RRUIdssUnpivot AS IU
			INNER JOIN #RRUFieldMapping AS FM
					ON IU.ColumnName = FM.ColumnName AND
						(
							(IU.Measure IN ('RCA','RDI')) OR
							(FM.BitOption & 2 = 0)
						) AND
						(
							(@ProductLineID <> @ProductLineM) OR
							(FM.BitOption & 4 = 4)
						);


	SET @RAS = 
	(SELECT	@Version AS [@Version],
			MeasureGuid AS [@measure-version-id],
			(SELECT	FreqPharmN1 AS [NameBrandOnlyCount],
					FreqPharmN2 AS [NameBrandGenericExistsCount],
					FreqPharmG1 AS [GenericOnlyCount],
					FreqPharmG2 AS [GenericNameBrandExistsCount],
					IsDenominator AS [EligiblePopulation],
					IsIndicator AS [Exclusions]
			FROM	#MeasureXmlSource AS measure
			WHERE	measure.MeasureID = header.MeasureID
			FOR XML PATH('MetaData'), TYPE),
			(SELECT	GenderAbbrev AS Gender,
					AgeBand AS AgeGroup,
					RiskCtgy AS RiskGroup,
					IdssName AS Metric,
					Value
			FROM	#MetricXmlSource AS metrics
			WHERE	metrics.MeasureID = header.MeasureID
			ORDER BY Measure, RowID, SortOrder
			FOR XML PATH('Row'), ROOT('Data'), TYPE)
	FROM	#HeaderXmlSource AS header
	WHERE	Measure = 'RAS'
	ORDER BY Measure
	FOR XML PATH('RAS'), TYPE);

	SELECT @RCA =
	(SELECT	@Version AS [@Version],
			MeasureGuid AS [@measure-version-id],
			(SELECT	FreqPharmN1 AS [NameBrandOnlyCount],
					FreqPharmN2 AS [NameBrandGenericExistsCount],
					FreqPharmG1 AS [GenericOnlyCount],
					FreqPharmG2 AS [GenericNameBrandExistsCount],
					IsDenominator AS [EligiblePopulation],
					IsIndicator AS [Exclusions]
			FROM	#MeasureXmlSource AS measure
			WHERE	measure.MeasureID = header.MeasureID
			FOR XML PATH('MetaData'), TYPE),
			(SELECT	GenderAbbrev AS Gender,
					AgeBand AS AgeGroup,
					RiskCtgy AS RiskGroup,
					IdssName AS Metric,
					Value
			FROM	#MetricXmlSource AS metrics
			WHERE	metrics.MeasureID = header.MeasureID
			ORDER BY Measure, RowID, SortOrder
			FOR XML PATH('Row'), ROOT('Data'), TYPE)
	FROM	#HeaderXmlSource AS header
	WHERE	Measure = 'RCA'
	ORDER BY Measure
	FOR XML PATH('RCA'), TYPE);

	SELECT @RCO =
	(SELECT	@Version AS [@Version],
			MeasureGuid AS [@measure-version-id],
			(SELECT	FreqPharmN1 AS [NameBrandOnlyCount],
					FreqPharmN2 AS [NameBrandGenericExistsCount],
					FreqPharmG1 AS [GenericOnlyCount],
					FreqPharmG2 AS [GenericNameBrandExistsCount],
					IsDenominator AS [EligiblePopulation],
					IsIndicator AS [Exclusions]
			FROM	#MeasureXmlSource AS measure
			WHERE	measure.MeasureID = header.MeasureID
			FOR XML PATH('MetaData'), TYPE),
			(SELECT	GenderAbbrev AS Gender,
					AgeBand AS AgeGroup,
					RiskCtgy AS RiskGroup,
					IdssName AS Metric,
					Value
			FROM	#MetricXmlSource AS metrics
			WHERE	metrics.MeasureID = header.MeasureID
			ORDER BY Measure, RowID, SortOrder
			FOR XML PATH('Row'), ROOT('Data'), TYPE)
	FROM	#HeaderXmlSource AS header
	WHERE	Measure = 'RCO'
	ORDER BY Measure
	FOR XML PATH('RCO'), TYPE);

	SELECT @RDI = 
	(
		SELECT	@Version AS [@Version],
				MeasureGuid AS [@measure-version-id],
				(SELECT	FreqPharmN1 AS [NameBrandOnlyCount],
						FreqPharmN2 AS [NameBrandGenericExistsCount],
						FreqPharmG1 AS [GenericOnlyCount],
						FreqPharmG2 AS [GenericNameBrandExistsCount],
						IsDenominator AS [EligiblePopulation],
						IsIndicator AS [Exclusions]
				FROM	#MeasureXmlSource AS measure
				WHERE	measure.MeasureID = header.MeasureID
				FOR XML PATH('MetaData'), TYPE),
				(SELECT	GenderAbbrev AS Gender,
						AgeBand AS AgeGroup,
						RiskCtgy AS RiskGroup,
						IdssName AS Metric,
						Value
				FROM	#MetricXmlSource AS metrics
				WHERE	metrics.MeasureID = header.MeasureID
				ORDER BY Measure, RowID, SortOrder
				FOR XML PATH('Row'), ROOT('Data'), TYPE)
		FROM	#HeaderXmlSource AS header
		WHERE	Measure = 'RDI'
		ORDER BY Measure
		FOR XML PATH('RDI'), TYPE
	);

	SELECT @RHY = 
	(SELECT	@Version AS [@Version],
			MeasureGuid AS [@measure-version-id],
			(SELECT	FreqPharmN1 AS [NameBrandOnlyCount],
					FreqPharmN2 AS [NameBrandGenericExistsCount],
					FreqPharmG1 AS [GenericOnlyCount],
					FreqPharmG2 AS [GenericNameBrandExistsCount],
					IsDenominator AS [EligiblePopulation],
					IsIndicator AS [Exclusions]
			FROM	#MeasureXmlSource AS measure
			WHERE	measure.MeasureID = header.MeasureID
			FOR XML PATH('MetaData'), TYPE),
			(SELECT	GenderAbbrev AS Gender,
					AgeBand AS AgeGroup,
					RiskCtgy AS RiskGroup,
					IdssName AS Metric,
					Value
			FROM	#MetricXmlSource AS metrics
			WHERE	metrics.MeasureID = header.MeasureID
			ORDER BY Measure, RowID, SortOrder
			FOR XML PATH('Row'), ROOT('Data'), TYPE)
	FROM	#HeaderXmlSource AS header
	WHERE	Measure = 'RHY'
	ORDER BY Measure
	FOR XML PATH('RHY'), TYPE);

	WITH XMLNAMESPACES('http://www.w3.org/2001/XMLSchema-instance' AS xsi, 'http://www.w3.org/2001/XMLSchema' AS xsd, DEFAULT 'http://ncqa.org/hedis/2012/rru')
	SELECT @Result = 
	(
		SELECT	@FileVersion AS [Version],
				@MeasureYear AS [MeasurementYear],
				@VendorID AS [vendor-id],
				@SubmissionID AS [SubmissionID]/*,
				@RDI,
				@RAS,
				@RCA,
				@RHY,
				@RCO*/
		FOR XML RAW('Submission')
	);

	--Use text-manipulation, since the XMLNAMESPACES does not format correctly with child elements (adds namespaces to children as well, not just root)
	SELECT @Result = 
			CONVERT(xml, REPLACE(CONVERT(nvarchar(max), @Result), '/>', '>' + 
			ISNULL(CONVERT(nvarchar(max), @RDI), '') + 
			ISNULL(CONVERT(nvarchar(max), @RAS), '') + 
			ISNULL(CONVERT(nvarchar(max), @RCA), '') + 
			ISNULL(CONVERT(nvarchar(max), @RHY), '') + 
			ISNULL(CONVERT(nvarchar(max), @RCO), '') + 
			'</Submission>'));

	SELECT @Result AS [IDSS RRU];
END
GO
