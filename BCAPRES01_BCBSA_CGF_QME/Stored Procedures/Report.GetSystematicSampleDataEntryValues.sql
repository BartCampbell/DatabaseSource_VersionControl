SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/12/2013
-- Description:	Based on a report originally created for Commonwealth Care Alliance, returns a detailed systematic sampling roster from the STAGING,
--				containing all transferred values entered from ChartNet.
-- =============================================
CREATE PROCEDURE [Report].[GetSystematicSampleDataEntryValues]
(
	@UserName nvarchar(128) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @Result int;
	
	BEGIN TRY;
	
		IF @UserName IS NULL
			SET @USerName = SUSER_SNAME();
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'GetSystematicSampleDataEntryValues'; 
		SET @LogObjectSchema = 'Report'; 
					
		DECLARE @CountRecords int;
		
		---------------------------------------------------------------------------
		
		DECLARE @Parameters AS Report.ReportParameters;
		
		SELECT DISTINCT
				CM.CustomerMemberID AS [Customer Member ID],
				CM.NameFirst AS [First Name],
				CM.NameLast AS [Last Name],
				CM.DateOfBirth AS [DOB],
				CM.Gender,
				'###-##-' + RIGHT(CM.SSN, 4) AS SSN,
				M.HEDISMeasure AS Measure,
				MX.HEDISSubMetricCode AS Metric,
				MX.HEDISSubMetricDescription AS [Metric Description],
				MMS.SampleDrawOrder AS [Sample Order],
				MMS.SampleType [Sample Type],
				MMS.DischargeDate AS [Event Date],
				P.PursuitNumber AS [Pursuit Number],
				NULLIF(PS.ProviderSiteName, '') AS [Provider Site, Name],
				NULLIF(PS.Address1, '') AS [Provider Site, Address 1],
				NULLIF(PS.Address2, '') AS [Provider Site, Address 2],
				NULLIF(PS.City, '') AS [Provider Site, City],
				NULLIF(PS.[State], '') AS [Provider Site, State],
				NULLIF(PS.Zip, '') AS [Provider Site, Zip Code],
				NULLIF(PS.Contact, '') AS [Provider Site, Contact],
				NULLIF(PS.Phone, '') AS [Provider Site, Phone],
				NULLIF(PV.ChartStatus, '') AS [Chart Status],
				CA.AbstractorName AS [Abstractor],
				P.AbstractionDate AS [Abstraction Date],
				ISNULL(CB.AbstractorName, CMRU.CreatedUser) AS [Most-Recent Created By],
				CMRU.CreatedDate AS [Most-Recent Created Date],
				ISNULL(UB.AbstractorName, CMRU.LastChangedUser) AS [Most-Recent Updated By],
				CMRU.LastChangedDate AS [Most-Recent Updated Date],
				CASE WHEN MMMS.AdministrativeHitCount > 0 THEN 1 ELSE 0 END AS [Numerator - Administrative],
				CASE WHEN MMMS.MedicalRecordHitCount > 0  THEN 1 ELSE 0 END AS [Numerator - Medical Record],
				CASE WHEN MMMS.HybridHitCount > 0  THEN 1 ELSE 0 END AS [Numerator - Hybrid],
				CASE WHEN MMMS.ExclusionCount > 0 THEN 1 ELSE 0 END AS [Exclusion],
				VD.ServiceDate AS [Service Date],
				VD.ServiceInfo01 AS [Field 1 - Name],
				VD.ServiceValue01 AS [Field 1 - Value],
				VD.ServiceInfo02 AS [Field 2 - Name],
				VD.ServiceValue02 AS [Field 2 - Value],
				VD.ServiceInfo03 AS [Field 3 - Name],
				VD.ServiceValue03 AS [Field 3 - Value],
				VD.ServiceInfo04 AS [Field 4 - Name],
				VD.ServiceValue04 AS [Field 4 - Value],
				VD.ServiceInfo05 AS [Field 5 - Name],
				VD.ServiceValue05 AS [Field 5 - Value],
				VD.ServiceInfo06 AS [Field 6 - Name],
				VD.ServiceValue06 AS [Field 6 - Value],
				VD.ServiceInfo07 AS [Field 7 - Name],
				VD.ServiceValue07 AS [Field 7 - Value],
				VD.ServiceInfo08 AS [Field 8 - Name],
				VD.ServiceValue08 AS [Field 8 - Value]
		FROM	ChartNet.MemberMeasureSample AS MMS
				INNER JOIN ChartNet.Pursuit AS P
						ON MMS.MemberID = P.MemberID 
				INNER JOIN ChartNet.PursuitEvent AS PV
						ON P.PursuitID = PV.PursuitID AND
							MMS.MeasureID = PV.MeasureID
				INNER JOIN ChartNet.Member AS CM
						ON P.MemberID = CM.MemberID
				INNER JOIN ChartNet.Measure AS M
						ON PV.MeasureID = M.MeasureID
				INNER JOIN ChartNet.HEDISSubMetric AS MX
						ON M.MeasureID = MX.MeasureID AND
							MX.DisplayInScoringPanel = 1
				LEFT OUTER JOIN ChartNet.MedicalRecordUpdates AS CMRU
						ON P.MemberID = CMRU.MemberID AND
							MX.HEDISSubMetricID = CMRU.MetricID AND
							MX.MeasureID = CMRU.MeasureID
				LEFT OUTER JOIN	ChartNet.Abstractor AS CB
						ON CMRU.CreatedAbstractorID = CB.AbstractorID
				LEFT OUTER JOIN ChartNet.Abstractor AS UB
						ON CMRU.LastChangedAbstractorID = UB.AbstractorID
				LEFT OUTER JOIN ChartNet.ProviderSite AS PS
						ON P.ProviderSiteID = PS.ProviderSiteID
				LEFT OUTER JOIN ChartNet.Abstractor AS CA
						ON P.AbstractorID = CA.AbstractorID
				LEFT OUTER JOIN ChartNet.EventDetail AS VD
						ON CM.CustomerMemberID = VD.CustomerMemberID AND
							(MMS.DischargeDate IS NULL OR MMS.DischargeDate = VD.KeyDate) AND 
							MX.HEDISSubMetricCode = VD.Metric
				LEFT OUTER JOIN ChartNet.MemberMeasureMetricScoring AS MMMS
						ON MMS.MemberMeasureSampleID = MMMS.MemberMeasureSampleID AND
							MX.HEDISSubMetricID = MMMS.HEDISSubMetricID
		ORDER BY Measure, [Sample Order]
		
		SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
		SET @LogEndTime = GETDATE();
		
		EXEC @Result = [Log].RecordReportUsage	@BeginTime = @LogBeginTime,
												@CountRecords = @CountRecords,
												@EndTime = @LogEndTime, 
												@Parameters = @Parameters,
												@SrcObjectName = @LogObjectName,
												@SrcObjectSchema = @LogObjectSchema,
												@UserName = @UserName;


		RETURN 0;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(max);
		DECLARE @ErrNumber int;
		DECLARE @ErrSeverity int;
		DECLARE @ErrSource nvarchar(512);
		DECLARE @ErrState int;
		
		DECLARE @ErrResult int;
		
		SELECT	@ErrApp = DB_NAME(),
				@ErrLine = ERROR_LINE(),
				@ErrMessage = ERROR_MESSAGE(),
				@ErrNumber = ERROR_NUMBER(),
				@ErrSeverity = ERROR_SEVERITY(),
				@ErrSource = ERROR_PROCEDURE(),
				@ErrState = ERROR_STATE();
				
		EXEC @ErrResult = [Log].RecordError	@Application = @ErrApp,
											@LineNumber = @ErrLine,
											@Message = @ErrMessage,
											@ErrorNumber = @ErrNumber,
											@ErrorType = 'Q',
											@ErrLogID = @ErrLogID OUTPUT,
											@Severity = @ErrSeverity,
											@Source = @ErrSource,
											@State = @ErrState;
		
		IF @ErrResult <> 0
			BEGIN
				PRINT '*** Error Log Failure:  Unable to record the specified entry. ***'
				SET @ErrNumber = @ErrLine * -1;
			END
			
		RETURN @ErrNumber;
	END CATCH;
END

GO
GRANT EXECUTE ON  [Report].[GetSystematicSampleDataEntryValues] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetSystematicSampleDataEntryValues] TO [Reports]
GO
