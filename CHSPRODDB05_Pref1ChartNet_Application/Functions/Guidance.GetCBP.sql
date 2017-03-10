SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Guidance].[GetCBP]
(	
	@PursuitEventID int
)
RETURNS table 
AS
RETURN 
(
	WITH KeyDates AS
	(
		SELECT  dbo.MeasureYearStartDate() AS MeasureYearStart,
				dbo.MeasureYearEndDate() AS MeasureYearEnd,
				dbo.MeasureYearStartDateYearOffset(-1) AS PriorMeasureYearStart,
				dbo.MeasureYearHalfway(0) AS MeasureYearHalfwayPoint
	),
	ListBase AS
	(
		SELECT TOP 1
				R.PursuitID, 
				RV.PursuitEventID,
				RV.AbstractionStatusID,
				RV.LastChangedDate,
				MBR.DateOfBirth,
				CASE WHEN ISNULL(MBR.DateOfBirth, 0) = ISNULL(MBR.OriginalDateOfBirth, 0) THEN '(Administrative)' ELSE '(Medical Record)' END AS DOBEdited,
				dbo.GetAgeAsOf(MBR.DateOfBirth, dbo.MeasureYearEndDate()) AS MemberAge,
				KD.MeasureYearStart AS StartOfYear,
				KD.PriorMeasureYearStart AS StartOfPriorYear,
				KD.MeasureYearEnd AS EndOfYear,
				CONVERT(varchar, YEAR(KD.MeasureYearEnd)) AS MeasureYear,
				MRCC.ServiceDate AS ConfirmationDate,
				CASE WHEN MMMS.SuppIndicator = 1 OR MMS.DiabetesDiagnosisDate IS NOT NULL AND MMS.DiabetesDiagnosisDate BETWEEN KD.PriorMeasureYearStart AND KD.MeasureYearEnd THEN 1 ELSE 0 END AS HasDiabetes,
				MMS.DiabetesDiagnosisDate,
				CASE WHEN CBPDiabetes.NoDiabetesDiagnosisFlag = 1 AND CBPDiabetes.DiabetesRefutedFlag = 1 THEN 1 ELSE 0 END AS CancelDiabetes
		FROM	dbo.Pursuit AS R
				INNER JOIN dbo.PursuitEvent AS RV
						ON R.PursuitID = RV.PursuitID
				INNER JOIN dbo.Member AS MBR
						ON R.MemberID = MBR.MemberID
				INNER JOIN dbo.MemberMeasureSample AS MMS
						ON MMS.EventDate = RV.EventDate AND
							MMS.MeasureID = RV.MeasureID AND
							MMS.MemberID = R.MemberID
				INNER JOIN dbo.MemberMeasureMetricScoring AS MMMS
						ON MMMS.MemberMeasureSampleID = MMS.MemberMeasureSampleID 
				INNER JOIN dbo.HEDISSubMetric AS MX
						ON MX.HEDISSubMetricID = MMMS.HEDISSubMetricID AND
							MX.HEDISMeasureInit = 'CBP'
				CROSS JOIN KeyDates AS KD
				OUTER APPLY (
								SELECT TOP 1 
										tMRCC.ServiceDate 
								FROM	dbo.MedicalRecordCBPConf AS tMRCC 
										INNER JOIN dbo.Pursuit AS tR 
												ON tR.PursuitID = tMRCC.PursuitID 
								WHERE	tR.MemberID = R.MemberID AND 
										tMRCC.NotationType IS NOT NULL AND
										(
											tMRCC.ServiceDate <= KD.MeasureYearHalfwayPoint OR 
											tMRCC.DocumentationType = 'Undated Problem List'
										) 
								ORDER BY tMRCC.ServiceDate ASC
							) AS MRCC
				OUTER APPLY
							(
								SELECT	MAX(CONVERT(int, tCBPDiabetes.NoDiabetesDiagnosisFlag)) AS NoDiabetesDiagnosisFlag,
										MAX(CONVERT(int, tCBPDiabetes.DiabetesRefutedFlag)) AS DiabetesRefutedFlag
								FROM	dbo.MedicalRecordCBPDiabetes AS tCBPDiabetes
										INNER JOIN dbo.Pursuit AS tR
												ON tR.PursuitID = tCBPDiabetes.PursuitID
								WHERE	tR.MemberID = R.MemberID AND
										tCBPDiabetes.ServiceDate BETWEEN KD.PriorMeasureYearStart AND KD.MeasureYearEnd
							) AS CBPDiabetes
		WHERE	RV.PursuitEventID = @PursuitEventID  
	)
	SELECT	'Member''s Date of Birth' AS Title,
			dbo.ConvertDateToVarchar(DateOfBirth) + ' ' + DOBEdited AS [Value],
			1.0 AS SortOrder
	FROM	ListBase
	UNION 
	SELECT	'Member''s Age as of 12/31/' + MeasureYear AS Title,
			CONVERT(varchar, MemberAge) AS [Value],
			2.0 AS SortOrder
	FROM	ListBase
	UNION	
	SELECT	'Hypertension Diagnosis Confirmed' AS Title,
			CASE WHEN ConfirmationDate IS NOT NULL THEN 'Yes, ' + dbo.ConvertDateToVarchar(ConfirmationDate) ELSE 'No' END,
			3.1 AS SortOrder
	FROM	ListBase 
	UNION 
	SELECT	'BP Reading Date Range' AS Title,
			dbo.ConvertDateToVarchar(CASE WHEN StartOfYear > ConfirmationDate THEN StartOfYear ELSE DATEADD(dd, 1, ConfirmationDate) END) + ' -' + dbo.ConvertDateToVarchar(EndOfYear) AS Value,
			3.2 AS SortOrder
	FROM	ListBase
	UNION	
	SELECT	'Diabetes Diagnosis' AS Title,
			CASE WHEN ListBase.CancelDiabetes = 1 AND ListBase.HasDiabetes = 1 THEN 'No, Refuted by Medical Record' ELSE CASE WHEN ListBase.HasDiabetes = 1 THEN 'Yes' ELSE 'No' END + ISNULL(', ' + dbo.ConvertDateToVarchar(DiabetesDiagnosisDate), '') END AS Value,
			3.3 AS SortOrder
	FROM	ListBase
)

GO
