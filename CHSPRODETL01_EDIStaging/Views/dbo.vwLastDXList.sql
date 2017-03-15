SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwLastDXList]
AS
SELECT
     DXCode,
     DXShortDescription,
     DXLongDescription,
     EffectiveFrom,
     EffectiveTo,
     ICDVersion,
     DiagnosisCodeMasterID
FROM  Submissions.dbo.DiagnosisCodeMaster AS a
WHERE EffectiveTo IN
(
    SELECT
         MAX(EffectiveTo)
    FROM  Submissions.dbo.DiagnosisCodeMaster AS b
    WHERE a.DXCode = b.DXCode and a.ICDVersion = b.ICDVersion
);

GO
