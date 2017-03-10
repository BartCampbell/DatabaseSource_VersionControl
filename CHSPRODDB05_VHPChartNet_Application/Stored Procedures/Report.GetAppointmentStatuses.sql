SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetAppointmentStatuses]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH Results AS
	(
		SELECT	'(All Statuses)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	[Description] AS Descr,
				AppointmentStatusID AS ID
		FROM	dbo.AppointmentStatus WITH(NOLOCK)
    )
    SELECT	*
    FROM	Results
    WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY ID
    OPTION	(OPTIMIZE FOR (@IncludeAllOption = 1));    
    
END


GO
GRANT EXECUTE ON  [Report].[GetAppointmentStatuses] TO [Reporting]
GO
