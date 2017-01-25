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

exec [CGF_REP].[RunEndDate]
exec [CGF_REP].[RunEndDate] '12/31/2014'

ToDo:		

	grant execute on [CGF_REP].[RunEndDate] to public 

*************************************************************************************/
CREATE	PROC [CGF_REP].[RunEndDate] 
(
	@EndSeedDate			DATETIME = NULL 
)
AS

SELECT 
	DataRunID, 
	--DataRun = CONVERT(VARCHAR(10), DataRunID) + ' [' + CONVERT(VARCHAR(30), CreatedDate) + ']'
	DataRun = CONVERT(VARCHAR(30), CreatedDate) 
FROM CGF.DataRuns
WHERE (EndSeedDate = @EndSeedDate OR (@EndSeedDate IS NULL AND EndSeedDate LIKE '%%'))
ORDER BY EndSeedDate DESC



GO
