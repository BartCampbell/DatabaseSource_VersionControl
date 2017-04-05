SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*************************************************************************************
Procedure:	DataEvaluation.HEDISProfileClientManualProc 
Author:		Brandon Rodman
Copyright:	© 2016
Date:		2016.12.09

*/

--/*




CREATE PROC [dbo].[BCBSAZ_HEDISOverallProfile] 
	@vcClient				varchar(20)= 'BCBSAZ',
	@dEndYear				Date --= '20161231'

AS
BEGIN


SELECT *-- [ProfileName],
      --[ReturnValue]
    FROM [BCBSA_CGF_Staging].[dbo].[HEDISDefinitionProfileResults]
  
  
  End
  


GO
