SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Export].[MedicalRecordDetailWithMetric] AS 
WITH Metrics AS
(
	SELECT	MX.HEDISSubMetricID,
            MX.HEDISSubMetricCode,
            MX.HEDISSubMetricDescription,
            MX.HEDISMeasureInit,
            MX.MeasureID,
            MX.DisplayName,
			MX.ReportName,
            MX.SortOrder,
            MX.DisplayInScoringPanel,
            MCMX.MeasureComponentID
	FROM	dbo.HEDISSubMetric AS MX
			INNER JOIN dbo.MeasureComponentMetrics AS MCMX
					ON MCMX.HEDISSubMetricID = MX.HEDISSubMetricID
	WHERE	MX.DisplayInScoringPanel = 1
)
SELECT TOP (100) PERCENT
		R.PursuitNumber,
		MBR.CustomerMemberID,
		MBR.ProductLine,
		MBR.Product,
		CONVERT(varchar(64), MDC.MeasureComponentID) + '-' + CONVERT(varchar(64), MDC.PursuitEventID) + '-' + CONVERT(varchar(64), MDC.MedicalRecordKey) AS IMIReferenceNumber,
		P.CustomerProviderID,
		P.NameEntityFullName AS ProviderName,
		PS.CustomerProviderSiteID,
		PS.ProviderSiteName,
		M.HEDISMeasure AS Measure,
		MC.TabDisplayTitle AS MeasureComponent,
		ISNULL(MX.HEDISSubMetricCode, MX2.HEDisSubMetricCode) AS Metric,
		ISNULL(MX.ReportName, MX2.ReportName) AS MetricDescription,
		RV.EventDate,
		RV.MedicalRecordNumber,
		R.PursuitCategory,
		AST.Description AS AbstractionStatus,
		CST.Title AS ChartStatus,
		A.AbstractorName AS Abstractor,
		A.FirstName AS AbstractorFirstName,
		A.LastName AS AbstractorLastName,
		A.UserName AS AbstractorUserName,
		R.AbstractionDate,
        MDC.ServiceDate AS EntryServiceDate,
        MDC.CreatedDate AS EntryCreatedDate,
        MDC.CreatedUser AS EntryCreatedUser,
        MDC.LastChangedDate AS EntryLastChangedDate,
        MDC.LastChangedUser AS EntryLastChangedUser,
		MDC.ColTitle01 AS EntryColumn01Title,
		MDC.ColType01 AS EntryColumn01DataType,
		MDC.ColValue01 AS EntryColumn01Value,
		MDC.ColTitle02 AS EntryColumn02Title,
		MDC.ColType02 AS EntryColumn02DataType,
		MDC.ColValue02 AS EntryColumn02Value,
		MDC.ColTitle03 AS EntryColumn03Title,
		MDC.ColType03 AS EntryColumn03DataType,
		MDC.ColValue03 AS EntryColumn03Value,
		MDC.ColTitle04 AS EntryColumn04Title,
		MDC.ColType04 AS EntryColumn04DataType,
		MDC.ColValue04 AS EntryColumn04Value,
		MDC.ColTitle05 AS EntryColumn05Title,
		MDC.ColType05 AS EntryColumn05DataType,
		MDC.ColValue05 AS EntryColumn05Value,
		MDC.ColTitle06 AS EntryColumn06Title,
		MDC.ColType06 AS EntryColumn06DataType,
		MDC.ColValue06 AS EntryColumn06Value,
		MDC.ColTitle07 AS EntryColumn07Title,
		MDC.ColType07 AS EntryColumn07DataType,
		MDC.ColValue07 AS EntryColumn07Value,
		MDC.ColTitle08 AS EntryColumn08Title,
		MDC.ColType08 AS EntryColumn08DataType,
		MDC.ColValue08 AS EntryColumn08Value,
		MDC.ColTitle09 AS EntryColumn09Title,
		MDC.ColType09 AS EntryColumn09DataType,
		MDC.ColValue09 AS EntryColumn09Value,
		MDC.ColTitle10 AS EntryColumn10Title,
		MDC.ColType10 AS EntryColumn10DataType,
		MDC.ColValue10 AS EntryColumn10Value,
		MDC.ColTitle11 AS EntryColumn11Title,
		MDC.ColType11 AS EntryColumn11DataType,
		MDC.ColValue11 AS EntryColumn11Value,
		MDC.ColTitle12 AS EntryColumn12Title,
		MDC.ColType12 AS EntryColumn12DataType,
		MDC.ColValue12 AS EntryColumn12Value--,
		--MDC.ColumnXml AS EntryDataXml
FROM	dbo.MedicalRecordComposite AS MDC
		INNER JOIN dbo.PursuitEvent AS RV
				ON MDC.PursuitEventID = RV.PursuitEventID
		LEFT OUTER JOIN dbo.ChartStatusValue AS CST
				ON RV.ChartStatusValueID = CST.ChartStatusValueID
		LEFT OUTER JOIN dbo.AbstractionStatus AS AST
				ON RV.AbstractionStatusID = AST.AbstractionStatusID
		INNER JOIN dbo.Pursuit AS R
				ON MDC.PursuitID = R.PursuitID
		INNER JOIN dbo.ProviderSite AS PS
				ON R.ProviderSiteID = PS.ProviderSiteID
		INNER JOIN dbo.Providers AS P
				ON R.ProviderID = P.ProviderID
		INNER JOIN dbo.Member AS MBR
				ON R.MemberID = MBR.MemberID
		LEFT OUTER JOIN dbo.Abstractor AS A
				ON R.AbstractorID = A.AbstractorID
		INNER JOIN dbo.MeasureComponent AS MC
				ON MDC.MeasureComponentID = MC.MeasureComponentID
		LEFT OUTER JOIN Metrics AS MX
				ON MC.MeasureComponentID = MX.MeasureComponentID AND
					MC.MeasureID = MX.MeasureID                 
		INNER JOIN dbo.Measure AS M
				ON MC.MeasureID = M.MeasureID
		OUTER APPLY (SELECT tMX.* FROM dbo.HEDISSubMetric AS tMX WHERE (MX.HEDISSubMetricCode) IS NULL AND tMX.HEDISSubMetricCode <> 'FPCRATIO' AND (tMX.MeasureID = M.MeasureID) AND (MC.Title <> 'HbA1c Exclusion' OR (MC.Title = 'HbA1c Exclusion' AND tMX.HEDISSubMetricCode = 'CDC3'))) AS MX2
ORDER BY Measure, MeasureComponent, Metric, IMIReferenceNumber;



GO
