SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Report].[MeasureFieldKey] AS
WITH ReportTypes AS
(
	SELECT	CAST('Summary' AS varchar(32)) AS Descr
	UNION
	SELECT	CAST('Detail' AS varchar(32)) AS Descr
	UNION 
	SELECT	CAST('Provider' AS varchar(32)) AS Descr
	UNION 
	SELECT	CAST('Comparison' AS varchar(32)) AS Descr
),
SortOrders AS
(
	SELECT	RF.FieldID, RMF.MeasureID,
			RT.Descr AS ReportType,
			ROW_NUMBER() OVER (PARTITION BY RMF.MeasureID, RT.Descr ORDER BY RMF.SortOrder) AS SortOrder
	FROM	Report.MeasureFields AS RMF
			INNER JOIN Report.Fields AS RF
					ON RMF.FieldID = RF.FieldID
			CROSS JOIN ReportTypes AS RT
	WHERE	(RF.AllowComparison = 1 AND RT.Descr = 'Comparison') OR
			(RF.AllowDetail = 1 AND RT.Descr = 'Detail') OR
			(RF.AllowProviders = 1 AND RT.Descr = 'Provider') OR
			(RT.Descr = 'Summary')
),
MeasureFieldsPivot AS
(
	SELECT	
			[1] AS FieldID01, [2] AS FieldID02,
			[3] AS FieldID03, [4] AS FieldID04,
			[5] AS FieldID05, [6] AS FieldID06,
			[7] AS FieldID07, [8] AS FieldID08,
			[9] AS FieldID09, [10] AS FieldID10,
			[11] AS FieldID11, [12] AS FieldID12,
			MeasureID, ReportType
	FROM
			(SELECT	FieldID, MeasureID, ReportType, SortOrder
			FROM	SortOrders) AS RMF
			PIVOT
			(
				MAX(	FieldID) 
				FOR		SortOrder IN
						([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
			) AS t
)
SELECT	Report.MeasureFieldDescription(t.FieldID01, t.MeasureID) AS FieldDescr01,
		Report.MeasureFieldDescription(T.FieldID02, t.MeasureID) AS FieldDescr02,
		Report.MeasureFieldDescription(T.FieldID03, t.MeasureID) AS FieldDescr03,
		Report.MeasureFieldDescription(T.FieldID04, t.MeasureID) AS FieldDescr04,
		Report.MeasureFieldDescription(T.FieldID05, t.MeasureID) AS FieldDescr05,
		Report.MeasureFieldDescription(T.FieldID06, t.MeasureID) AS FieldDescr06,
		Report.MeasureFieldDescription(T.FieldID07, t.MeasureID) AS FieldDescr07,
		Report.MeasureFieldDescription(T.FieldID08, t.MeasureID) AS FieldDescr08,
		Report.MeasureFieldDescription(T.FieldID09, t.MeasureID) AS FieldDescr09,
		Report.MeasureFieldDescription(T.FieldID10, t.MeasureID) AS FieldDescr10,
		Report.MeasureFieldDescription(T.FieldID11, t.MeasureID) AS FieldDescr11,
		Report.MeasureFieldDescription(T.FieldID12, t.MeasureID) AS FieldDescr12,
		t.FieldID01,
		t.FieldID02,
		t.FieldID03,
		t.FieldID04,
		t.FieldID05,
		t.FieldID06,
		t.FieldID07,
		t.FieldID08,
		t.FieldID09,
		t.FieldID10,
		t.FieldID11,
		t.FieldID12,
		RF01.FieldName AS FieldName01,
		RF02.FieldName AS FieldName02,
		RF03.FieldName AS FieldName03,
		RF04.FieldName AS FieldName04,
		RF05.FieldName AS FieldName05,
		RF06.FieldName AS FieldName06,
		RF07.FieldName AS FieldName07,
		RF08.FieldName AS FieldName08,
		RF09.FieldName AS FieldName09,
		RF10.FieldName AS FieldName10,
		RF11.FieldName AS FieldName11,
		RF12.FieldName AS FieldName12,
		RF01.NumberFormat AS FieldNumberFormat01,
		RF02.NumberFormat AS FieldNumberFormat02,
		RF03.NumberFormat AS FieldNumberFormat03,
		RF04.NumberFormat AS FieldNumberFormat04,
		RF05.NumberFormat AS FieldNumberFormat05,
		RF06.NumberFormat AS FieldNumberFormat06,
		RF07.NumberFormat AS FieldNumberFormat07,
		RF08.NumberFormat AS FieldNumberFormat08,
		RF09.NumberFormat AS FieldNumberFormat09,
		RF10.NumberFormat AS FieldNumberFormat10,
		RF11.NumberFormat AS FieldNumberFormat11,
		RF12.NumberFormat AS FieldNumberFormat12,
		t.MeasureID,
		t.ReportType
FROM	MeasureFieldsPivot AS t
		LEFT OUTER JOIN Report.Fields AS RF01
				ON t.FieldID01 = RF01.FieldID 
		LEFT OUTER JOIN Report.Fields AS RF02
				ON t.FieldID02 = RF02.FieldID 
		LEFT OUTER JOIN Report.Fields AS RF03
				ON t.FieldID03 = RF03.FieldID 
		LEFT OUTER JOIN Report.Fields AS RF04
				ON t.FieldID04 = RF04.FieldID 
		LEFT OUTER JOIN Report.Fields AS RF05
				ON t.FieldID05 = RF05.FieldID 
		LEFT OUTER JOIN Report.Fields AS RF06
				ON t.FieldID06 = RF06.FieldID 
		LEFT OUTER JOIN Report.Fields AS RF07
				ON t.FieldID07 = RF07.FieldID 
		LEFT OUTER JOIN Report.Fields AS RF08
				ON t.FieldID08 = RF08.FieldID 
		LEFT OUTER JOIN Report.Fields AS RF09
				ON t.FieldID09 = RF09.FieldID 
		LEFT OUTER JOIN Report.Fields AS RF10
				ON t.FieldID10 = RF10.FieldID 
		LEFT OUTER JOIN Report.Fields AS RF11
				ON t.FieldID11 = RF11.FieldID 
		LEFT OUTER JOIN Report.Fields AS RF12
				ON t.FieldID12 = RF12.FieldID;

GO
