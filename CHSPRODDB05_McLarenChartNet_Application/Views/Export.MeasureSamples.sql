SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Export].[MeasureSamples] AS
SELECT	MMS.MemberMeasureSampleID AS ChartNetSampleID,
        MMS.ProductLine,
        MMS.Product,
		MBR.CustomerMemberID,
		M.HEDISMeasure AS Measure,
        MMS.EventDate,
        MMS.SampleType,
        MMS.SampleDrawOrder
FROM	dbo.MemberMeasureSample AS MMS
		INNER JOIN dbo.Member AS MBR
				ON MMS.MemberID = MBR.MemberID AND
					MMS.Product = MBR.Product AND
					MMS.ProductLine = MBR.ProductLine              
		INNER JOIN dbo.Measure AS M
				ON MMS.MeasureID = M.MeasureID              
					                
GO
GRANT SELECT ON  [Export].[MeasureSamples] TO [Export]
GO
