SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetAppointments]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;
	
	WITH Results AS
	(
		SELECT	CONVERT(datetime, NULL) AS AppointmentDateTime,
				'(All Appointments)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	AppointmentDateTime,
				CONVERT(varchar(128), AppointmentDateTime, 101) + ' ' + 
					--LEFT(CONVERT(varchar(128), AppointmentDateTime, 108), 5) + ' - ' + 
					/*LTRIM*/(RIGHT(CONVERT(varchar(128), AppointmentDateTime, 100), 7)) + ' - ' + 
					A.AbstractorName AS Descr,
				APPT.AppointmentID AS ID
		FROM	dbo.Appointment AS APPT WITH(NOLOCK)
				INNER JOIN dbo.Abstractor AS A WITH(NOLOCK)
						ON A.AbstractorID = APPT.AbstractorID
    )
    SELECT	*
    FROM	Results
    WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY AppointmentDateTime, Descr
    OPTION (OPTIMIZE FOR (@IncludeAllOption = 1));    
    
END
GO
GRANT EXECUTE ON  [Report].[GetAppointments] TO [Reporting]
GO
