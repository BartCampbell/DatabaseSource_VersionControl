SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetAppointmentTimeframes]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;
	
	WITH Results AS
	(
		SELECT	'(All Appointments)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	Descr + ' (' + dbo.ConvertDateToVarchar(StartDate) + ' - ' + dbo.ConvertDateToVarchar(EndDate) +')' AS Descr,
				ID
		FROM	dbo.AppointmentStandardTimeframes WITH(NOLOCK)
    )
    SELECT	*
    FROM	Results
    WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY ID, Descr
    OPTION (OPTIMIZE FOR (@IncludeAllOption = 1));    
    
END

GO
GRANT EXECUTE ON  [Report].[GetAppointmentTimeframes] TO [Reporting]
GO
