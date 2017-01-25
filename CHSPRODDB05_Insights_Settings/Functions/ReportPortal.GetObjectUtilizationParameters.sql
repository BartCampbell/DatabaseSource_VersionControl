SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		George Graves	
-- Create date: 06/21/2016
-- Description:	Retrieves the parsed xml parameters for a specified report object.
-- =============================================
CREATE FUNCTION [ReportPortal].[GetObjectUtilizationParameters]
(	
	-- Add the parameters for the function here
	@PrincipalID smallint,
	@RptObjID smallint,
	@RptObjUtilID smallint

)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
		WITH ParameterAttributes AS
	(
		SELECT	P.value('@id', 'varchar(16)') AS ID,
				P.value('@description', 'varchar(16)') AS Descr,
				P.value('@value', 'varchar(16)') AS Value,
				P.value('@null', 'varchar(16)') AS [Null],
				P.value('@nullable', 'varchar(16)') AS Nullable,
				RPOU.RptObjID
		FROM	ReportPortal.ObjectUtilization AS RPOU
				CROSS APPLY RPOU.params.nodes('/parameters/parameter') AS N(P)
		WHERE	(RPOU.params.exist('/parameters[1]/parameter[1]') = 1) AND
				(RPOU.PrincipalID = @PrincipalID) AND 
				(RPOU.RptObjID = @RptObjID) AND
                (RPOU.RptObjUtilID = @RptObjUtilID)
				)
	SELECT	t.ID,
			t.Descr,
			t.Value,
			t.[NULL],
			t.Nullable,
			t.RptObjID
	FROM	ParameterAttributes AS t
)
GO
