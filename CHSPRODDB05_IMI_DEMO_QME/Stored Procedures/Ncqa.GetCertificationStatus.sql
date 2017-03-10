SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/6/2015
-- Description:	Returns a list of the decks avialable for certification from the linked Staging database, along with the date certified measures were completed.
-- =============================================
CREATE PROCEDURE [Ncqa].[GetCertificationStatus]
(
	@MeasureSetID int,
	@ShowSummary bit = 1,
	@SourceDatabase nvarchar(128) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	IF @SourceDatabase IS NOT NULL
		EXEC Import.SetSourceDatabase @DatabaseName = @SourceDatabase;

	IF OBJECT_ID('tempdb..#Certified') IS NOT NULL
		DROP TABLE #Certified;

	IF OBJECT_ID('tempdb..#MeasureSetList') IS NOT NULL
		DROP TABLE #MeasureSetList;

	SELECT	MMS2.MeasureSetID
	INTO	#MeasureSetList
	FROM	Measure.MeasureSets AS MMS1
			INNER JOIN Measure.MeasureSets AS MMS2
					ON MMS2.DefaultSeedDate = MMS1.DefaultSeedDate
	WHERE	MMS1.MeasureSetTypeID IN (1, 2) AND
			MMS2.MeasureSetTypeID IN (1, 2) AND
			MMS1.MeasureSetID = @MeasureSetID
	UNION
	SELECT	@MeasureSetID;

	CREATE UNIQUE CLUSTERED INDEX IX_#MeasureSetList ON #MeasureSetList (MeasureSetID);

	SELECT	CertDate, Abbrev AS Measure
	INTO	#Certified
	FROM	Measure.Measures 
	WHERE	(MeasureSetID IN (SELECT MeasureSetID FROM #MeasureSetList)) AND 
			(CertDate IS NOT NULL)
	ORDER BY 1;

	IF OBJECT_ID('tempdb..#Available') IS NOT NULL
		DROP TABLE #Available;

	WITH Conversion(FromMeasure, ToMeasure) AS
	(
		SELECT 'HPDI', 'TLM'
		UNION
		SELECT 'HPDI', 'EBS'
		UNION
		SELECT 'HPDI', 'RDM'
		UNION
		SELECT 'HPDI', 'LDM'
		UNION
		SELECT 'HPD', 'TLM'
		UNION
		SELECT 'HPD', 'EBS'
		UNION
		SELECT 'HPD', 'RDM'
		UNION
		SELECT 'HPD', 'LDM'
	)
	SELECT	ISNULL(t.ToMeasure, NMD.Measure) AS Measure
	INTO	#Available
	FROM	Ncqa.MeasureDecks AS NMD
			LEFT OUTER JOIN Conversion AS t
					ON t.FromMeasure = NMD.NcqaDeck
	WHERE	(CountSample > 0) OR 
			(CountTest > 0)
	ORDER BY Measure;

	WITH Summary AS
	(
		SELECT  (SELECT COUNT(*) FROM #Available) AS CountAvailable,
				(SELECT COUNT(*) FROM #Certified) AS CountCertified,
				(SELECT COUNT(*) FROM Measure.Measures WHERE (MeasureSetID IN (SELECT MeasureSetID FROM #MeasureSetList)) AND IsEnabled = 1) AS CountMeasures

	)
	SELECT	t.CountCertified AS [Measures Certified],
			t.CountAvailable AS [Measure Decks Available],
            t.CountMeasures AS [Total Measures],
			CONVERT(varchar(32), CONVERT(decimal(18, 1), ROUND(CONVERT(decimal(18,6), t.CountCertified) / CONVERT(decimal(18,6), t.CountAvailable), 4) * 100)) + '%' AS [Certified of Available],
			CONVERT(varchar(32), CONVERT(decimal(18, 1), ROUND(CONVERT(decimal(18,6), t.CountCertified) / CONVERT(decimal(18,6), t.CountMeasures), 4) * 100)) + '%' AS [Certified of Total]
	FROM	Summary AS t;

	WITH MeasureList AS
	(
		SELECT	CertDate,
				Measure,
				1 AS SortOrder
		FROM	#Certified
		UNION ALL
		SELECT	NULL AS CertDate,
				Measure,
				2 AS SortOrder
		FROM	#Available
		WHERE	Measure NOT IN (SELECT Measure FROM #Certified)
	)
	SELECT	t.Measure,
			MM.Descr AS [Measure Description],
			t.CertDate AS [Date Certified]
	FROM	MeasureList AS t
			LEFT OUTER JOIN Measure.Measures AS MM
					ON MM.Abbrev = t.Measure AND
						(MM.MeasureSetID IN (SELECT MeasureSetID FROM #MeasureSetList))
	ORDER BY t.SortOrder, t.Measure;

	SELECT Abbrev AS Measure, Descr AS [Measure Description] FROM Measure.Measures WHERE (MeasureSetID IN (SELECT MeasureSetID FROM #MeasureSetList)) AND IsEnabled = 1 AND Abbrev NOT IN (SELECT Measure FROM #Available) ORDER BY Abbrev;
END

GO
GRANT VIEW DEFINITION ON  [Ncqa].[GetCertificationStatus] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[GetCertificationStatus] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[GetCertificationStatus] TO [Processor]
GO
