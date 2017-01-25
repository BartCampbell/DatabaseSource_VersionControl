SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*************************************************************************************
Procedure:	[CGF_REP].[MeasureMetricDesc] 
Author:		Leon Dowling
Copyright:	© 2013
Date:		2014.12.30
Purpose:	
Parameters:	
Depends On:	
Calls:		
Called By:	
Returns:	
Notes:		
Process:	
Test Script:	

exec [CGF_REP].[MeasureMetricDesc] 

ToDo:		

	GRANT EXECUTE ON [CGF_REP].[MeasureMetricDesc] TO PUBLIC 

*************************************************************************************/
CREATE	PROC [CGF_REP].[MeasureMetricDesc] 
AS

SELECT 
	DISTINCT MeasureMetricDesc
FROM CGF.MeasureMetrics 

UNION

SELECT NULL

ORDER BY MeasureMetricDesc 


GO
