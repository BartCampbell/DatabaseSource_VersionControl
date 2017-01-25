SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*************************************************************************************
Procedure:	rptRunCompare_Population
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

exec [CGF_REP].[FirstRunEndDate]
exec [CGF_REP].[FirstRunEndDate] '12/31/2014'

ToDo:		

	grant execute on [CGF_REP].[FirstRunEndDate] to public 

*************************************************************************************/
CREATE	PROC [CGF_REP].[FirstRunEndDate] 
(
	@EndSeedDate			DATETIME = NULL 
)
AS

SELECT 
	TOP 1 DataRunID
FROM CGF.DataRuns
WHERE (EndSeedDate = @EndSeedDate OR (@EndSeedDate IS NULL AND EndSeedDate LIKE '%%'))
ORDER BY DataRunID DESC



GO
