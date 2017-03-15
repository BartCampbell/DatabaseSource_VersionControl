SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dv].[HEDIS_ClientMember]
AS
     
    SELECT DISTINCT
	   i.MEM_NBR,
	   dbo.ufn_parsefind(REPLACE(i.RecordSource,'_',':'),':',1) AS Client,
	   LoadDate,
	   RecordSource
    FROM stage.HEDIS_Import i
GO
