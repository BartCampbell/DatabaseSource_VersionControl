SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/24/2015
-- Description:	Retrieves the parsed xml parameter info for a specified report object.
-- =============================================
CREATE FUNCTION [ReportPortal].[GetObjectInfoParameters]
(	
	@RptObjID smallint = NULL
)
RETURNS TABLE 
AS
RETURN 
(
	WITH ParameterAttributes AS
	(
		SELECT	CONVERT(bit, P.value('@allowblank', 'varchar(16)')) AS AllowBlank,
				CONVERT(bit, P.value('@multivalue', 'varchar(16)')) AS AllowMulti,
				CONVERT(bit, P.value('@nullable', 'varchar(16)')) AS AllowNull,
				CONVERT(bit, P.value('@promptuser', 'varchar(16)')) AS AllowPrompt,
				CONVERT(bit, P.value('@aredefaultvaluesquerybased', 'varchar(16)')) AS IsDefaultQueryBased,
				CONVERT(bit, P.value('@isqueryparameter', 'varchar(16)')) AS IsForQuery,		
				CONVERT(bit, P.value('@visible', 'varchar(16)')) AS IsVisible,
				CONVERT(bit, P.value('@arevalidvaluesquerybased', 'varchar(16)')) AS IsValueQueryBased,
				P.value('@datatype', 'varchar(64)') AS ParameterDataType,
				P.value('@name', 'nvarchar(128)') AS ParameterName,
				P.value('@prompt', 'varchar(256)') AS ParameterPrompt,
				P.value('@state', 'nvarchar(128)') AS ParameterState,
				ROI.RptObjID
		FROM	ReportPortal.ObjectInfo AS ROI
				CROSS APPLY ROI.Info.nodes('/parameters/parameter') AS N(P)
		WHERE	(ROI.Info.exist('/parameters[1]/parameter[1]') = 1) AND
				((@RptObjID IS NULL) OR (ROI.RptObjID = @RptObjID))
	)
	SELECT	t.AllowBlank,
			t.AllowMulti,
			t.AllowNull,
			t.AllowPrompt,
			CONVERT(bit, CASE WHEN t.ParameterState = 'MissingValidValue' THEN 0 ELSE 1 END) AS HasDefaultValue,
			CONVERT(bit, CASE WHEN t.ParameterState = 'HasOutstandingDependencies' THEN 1 ELSE 0 END) AS HasDependencies,
			t.IsDefaultQueryBased,
			t.IsForQuery,
			CONVERT(bit, CASE WHEN t.ParameterPrompt IS NULL OR t.IsVisible = 0 THEN 0 ELSE 1 END) AS IsVisible,
			t.IsValueQueryBased,
			t.ParameterDataType,
			t.ParameterName,
			t.ParameterPrompt,
			t.ParameterState,
			t.RptObjID
	FROM	ParameterAttributes AS t
)
GO
GRANT SELECT ON  [ReportPortal].[GetObjectInfoParameters] TO [PortalApp]
GO
