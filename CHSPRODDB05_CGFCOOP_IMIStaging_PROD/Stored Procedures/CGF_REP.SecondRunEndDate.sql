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

exec [CGF_REP].[SecondRunEndDate]
exec [CGF_REP].[SecondRunEndDate] '12/31/2014'

ToDo:		

	GRANT EXECUTE ON [CGF_REP].[SecondRunEndDate] TO PUBLIC 

*************************************************************************************/
CREATE	PROC [CGF_REP].[SecondRunEndDate] 
(
	@EndSeedDate			DATETIME = NULL 
)
AS

DECLARE @TABLE TABLE ([ID] INT IDENTITY(1,1), DataRunID INT) 

INSERT INTO @TABLE 
(DataRunID) 
SELECT 
	TOP 2 DataRunID
FROM CGF.DataRuns
WHERE (EndSeedDate = @EndSeedDate OR (@EndSeedDate IS NULL AND EndSeedDate LIKE '%%'))
ORDER BY DataRunID DESC

-- Return 
SELECT DataRunID FROM @TABLE WHERE [ID] = @@rowcount 

GO
