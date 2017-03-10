SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Import].[PurgeAllData]
AS
BEGIN;

	TRUNCATE TABLE dbo.AdministrativeEvent;
	TRUNCATE TABLE dbo.ChartImageFileImport
	TRUNCATE TABLE dbo.Member;
	TRUNCATE TABLE dbo.MemberMeasureSample;
	TRUNCATE TABLE dbo.MemberMeasureMetricScoring;
	TRUNCATE TABLE dbo.Providers;
	TRUNCATE TABLE dbo.PursuitEvent;
	TRUNCATE TABLE dbo.ProviderSite;

END;
GO
