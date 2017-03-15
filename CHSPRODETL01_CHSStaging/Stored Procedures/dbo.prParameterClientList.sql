SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Reporting Team
-- Create date: 12/14/2016
-- Description:	Creates client list for parameter 
-- 12/16/2016 - Updated to correct the spelling of WellCare
-- =============================================

CREATE	PROCEDURE [dbo].[prParameterClientList]

AS

BEGIN 

SELECT DISTINCT case
					when Clientname = 'WellCare'
						then 'WellCare'
					else ClientName
				end as ClientName

FROM dim.Client


RETURN 0

END 

GO
