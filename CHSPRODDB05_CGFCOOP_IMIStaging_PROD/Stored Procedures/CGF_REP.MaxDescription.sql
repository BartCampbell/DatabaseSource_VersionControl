SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [CGF_REP].[MaxDescription] 
AS

SELECT 
	PopulationDesc ='VHP: Commercial'

--FROM (
--	SELECT DISTINCT PopulationDesc = ISNULL(rbm.PopulationDesc,'Not Defined')
--		FROM CGF.ResultsByMember rbm
--	) x
--		ORDER BY ISNULL(PopulationDesc,'Not Defined')



GO
