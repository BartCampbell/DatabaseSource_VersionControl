SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Import].[LoadData_QINET_Staging]
(
    @DatabaseName nvarchar(128),
    @ServerName nvarchar(128)
)
AS 
BEGIN; 

	/*
	EXEC [dbo].[prLoadClientFiles_from_QINET_Staging] '???_QINET_Staging', 'CNET_IMPORT_TEMP'
	*/

	EXEC master.dbo.spLinkServerManager 'CREATE', 'CNET_IMPORT_TEMP', @ServerName,'master','HHPLINKUSER','446L1nkU53r#';

	DECLARE @SqlCmd nvarchar(max);

	EXEC Import.PurgeAllData @IncludeCharts = 0;

	SELECT  @SqlCmd = 'INSERT INTO [dbo].[Member] SELECT * FROM ' +
			QUOTENAME('CNET_IMPORT_TEMP') + '.' + QUOTENAME(@DatabaseName) +
			'.[ChartNetImport].[Member];'
	PRINT 'Executing: ' + @SqlCmd;
	EXEC(@SqlCmd)

	SELECT  @SqlCmd = 'INSERT INTO [dbo].[Providers] SELECT * FROM ' +
			QUOTENAME('CNET_IMPORT_TEMP') + '.' + QUOTENAME(@DatabaseName) +
			'.[ChartNetImport].[Providers];'
	PRINT 'Executing: ' + @SqlCmd;
	EXEC(@SqlCmd)

	SELECT  @SqlCmd = 'INSERT INTO dbo.PursuitEvent SELECT * FROM ' +
			QUOTENAME('CNET_IMPORT_TEMP') + '.' + QUOTENAME(@DatabaseName) +
			'.[ChartNetImport].[PursuitEvent];'
	PRINT 'Executing: ' + @SqlCmd;
	EXEC(@SqlCmd)

	SELECT  @SqlCmd = 'INSERT INTO dbo.ProviderSite SELECT * FROM ' +
			QUOTENAME('CNET_IMPORT_TEMP') + '.' + QUOTENAME(@DatabaseName) +
			'.[ChartNetImport].[ProviderSite];'
	PRINT 'Executing: ' + @SqlCmd;
	EXEC(@SqlCmd)

	SELECT  @SqlCmd = 'INSERT INTO dbo.AdministrativeEvent SELECT * FROM ' +
			QUOTENAME('CNET_IMPORT_TEMP') + '.' + QUOTENAME(@DatabaseName) +
			'.[ChartNetImport].[AdministrativeEvent]'
	PRINT 'Executing: ' + @SqlCmd;
	EXEC(@SqlCmd)

	SELECT  @SqlCmd = 'INSERT INTO dbo.MemberMeasureSample SELECT * FROM ' +
			QUOTENAME('CNET_IMPORT_TEMP') + '.' + QUOTENAME(@DatabaseName) +
			'.[ChartNetImport].[MemberMeasureSample]'
	PRINT 'Executing: ' + @SqlCmd;
	EXEC(@SqlCmd)

	SELECT  @SqlCmd = 'INSERT INTO dbo.MemberMeasureMetricScoring SELECT * FROM ' +
			QUOTENAME('CNET_IMPORT_TEMP') + '.' + QUOTENAME(@DatabaseName) +
			'.[ChartNetImport].[MemberMeasureMetricScoring]'
	PRINT 'Executing: ' + @SqlCmd;
	EXEC(@SqlCmd)

	EXEC master.dbo.spLinkServerManager 'DROP', 'CNET_IMPORT_TEMP';

	EXEC dbo.GetRecordCounts @TableSchema = 'dbo';
	
END;
GO
