SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwDiagnosisCodes]
AS
     SELECT
          i.Id AS InterchangeID,
          d.PositionInInterchange,
          ts.Id AS TransactionSetID,
          d.ParentLoopId,
          CONVERT(VARCHAR(50),CASE LEFT(d.[01], CHARINDEX(':', d.[01])-1)
              WHEN 'BK'
              THEN 'ICD-9-CM'
              WHEN 'ABK'
              THEN 'ICD-10-CM'
              ELSE LEFT(d.[01], CHARINDEX(':', d.[01])-1)
          END) AS ICDVersion,
          ISNULL(dx01.DXCode, RIGHT(d.[01], LEN(d.[01])-CHARINDEX(':', d.[01]))) AS PrimaryDXCode,
          dx01.DXShortDescription AS PrimaryDXDescription,
          ISNULL(dx02.DXCode, RIGHT(d.[02], LEN(d.[02])-CHARINDEX(':', d.[02]))) AS DXCode2,
          dx02.DXShortDescription AS DXDescription2,
          ISNULL(dx03.DXCode, RIGHT(d.[03], LEN(d.[03])-CHARINDEX(':', d.[03]))) AS DXCode3,
          dx03.DXShortDescription AS DXDescription3,
          ISNULL(dx04.DXCode, RIGHT(d.[04], LEN(d.[04])-CHARINDEX(':', d.[04]))) AS DXCode4,
          dx04.DXShortDescription AS DXDescription4,
          ISNULL(dx05.DXCode, RIGHT(d.[05], LEN(d.[05])-CHARINDEX(':', d.[05]))) AS DXCode5,
          dx05.DXShortDescription AS DXDescription5,
          ISNULL(dx06.DXCode, RIGHT(d.[06], LEN(d.[06])-CHARINDEX(':', d.[06]))) AS DXCode6,
          dx06.DXShortDescription AS DXDescription6,
          ISNULL(dx07.DXCode, RIGHT(d.[07], LEN(d.[07])-CHARINDEX(':', d.[07]))) AS DXCode7,
          dx07.DXShortDescription AS DXDescription7,
          ISNULL(dx08.DXCode, RIGHT(d.[08], LEN(d.[08])-CHARINDEX(':', d.[08]))) AS DXCode8,
          dx08.DXShortDescription AS DXDescription8,
          ISNULL(dx09.DXCode, RIGHT(d.[09], LEN(d.[09])-CHARINDEX(':', d.[09]))) AS DXCode9,
          dx09.DXShortDescription AS DXDescription9,
          ISNULL(dx10.DXCode, RIGHT(d.[10], LEN(d.[10])-CHARINDEX(':', d.[10]))) AS DXCode10,
          dx10.DXShortDescription AS DXDescription10,
          ISNULL(dx11.DXCode, RIGHT(d.[11], LEN(d.[11])-CHARINDEX(':', d.[11]))) AS DXCode11,
          dx11.DXShortDescription AS DXDescription11,
          ISNULL(dx12.DXCode, RIGHT(d.[12], LEN(d.[12])-CHARINDEX(':', d.[12]))) AS DXCode12,
          dx12.DXShortDescription AS DXDescription12
     FROM Interchange AS i
          INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                             AND ts.InterchangeId = i.Id
          INNER JOIN LastRevHI AS d ON d.InterchangeId = i.Id
                                       AND d.TransactionSetId = ts.Id
          LEFT JOIN vwLastDXList AS dx01 ON RIGHT(d.[01], LEN(d.[01])-CHARINDEX(':', d.[01])) = dx01.DXCode
                                            AND dx01.ICDVersion = CASE
                                                                      WHEN LEFT(d.[01], CHARINDEX(':', d.[01])-1) =
                                                                      'BK'
                                                                      THEN 9
                                                                      WHEN LEFT(d.[01], CHARINDEX(':', d.[01])-1) =
                                                                      'ABK'
                                                                      THEN 10
                                                                      ELSE 0
                                                                  END
          LEFT JOIN vwLastDXList AS dx02 ON RIGHT(d.[02], LEN(d.[02])-CHARINDEX(':', d.[02])) = dx02.DXCode
                                            AND dx02.ICDVersion = CASE
                                                                      WHEN LEFT(d.[02], CHARINDEX(':', d.[02])-1) =
                                                                      'BF'
                                                                      THEN 9
                                                                      WHEN LEFT(d.[02], CHARINDEX(':', d.[02])-1) =
                                                                      'ABF'
                                                                      THEN 10
                                                                      ELSE 0
                                                                  END
          LEFT JOIN vwLastDXList AS dx03 ON RIGHT(d.[03], LEN(d.[03])-CHARINDEX(':', d.[03])) = dx03.DXCode
                                            AND dx03.ICDVersion = CASE
                                                                      WHEN LEFT(d.[03], CHARINDEX(':', d.[03])-1) =
                                                                      'BF'
                                                                      THEN 9
                                                                      WHEN LEFT(d.[03], CHARINDEX(':', d.[03])-1) =
                                                                      'ABF'
                                                                      THEN 10
                                                                      ELSE 0
                                                                  END
          LEFT JOIN vwLastDXList AS dx04 ON RIGHT(d.[04], LEN(d.[04])-CHARINDEX(':', d.[04])) = dx04.DXCode
                                            AND dx04.ICDVersion = CASE
                                                                      WHEN LEFT(d.[04], CHARINDEX(':', d.[04])-1) =
                                                                      'BF'
                                                                      THEN 9
                                                                      WHEN LEFT(d.[04], CHARINDEX(':', d.[04])-1) =
                                                                      'ABF'
                                                                      THEN 10
                                                                      ELSE 0
                                                                  END
          LEFT JOIN vwLastDXList AS dx05 ON RIGHT(d.[05], LEN(d.[05])-CHARINDEX(':', d.[05])) = dx05.DXCode
                                            AND dx05.ICDVersion = CASE
                                                                      WHEN LEFT(d.[05], CHARINDEX(':', d.[05])-1) =
                                                                      'BF'
                                                                      THEN 9
                                                                      WHEN LEFT(d.[05], CHARINDEX(':', d.[05])-1) =
                                                                      'ABF'
                                                                      THEN 10
                                                                      ELSE 0
                                                                  END
          LEFT JOIN vwLastDXList AS dx06 ON RIGHT(d.[06], LEN(d.[06])-CHARINDEX(':', d.[06])) = dx06.DXCode
                                            AND dx06.ICDVersion = CASE
                                                                      WHEN LEFT(d.[06], CHARINDEX(':', d.[06])-1) =
                                                                      'BF'
                                                                      THEN 9
                                                                      WHEN LEFT(d.[06], CHARINDEX(':', d.[06])-1) =
                                                                      'ABF'
                                                                      THEN 10
                                                                      ELSE 0
                                                                  END
          LEFT JOIN vwLastDXList AS dx07 ON RIGHT(d.[07], LEN(d.[07])-CHARINDEX(':', d.[07])) = dx07.DXCode
                                            AND dx07.ICDVersion = CASE
                                                                      WHEN LEFT(d.[07], CHARINDEX(':', d.[07])-1) =
                                                                      'BF'
                                                                      THEN 9
                                                                      WHEN LEFT(d.[07], CHARINDEX(':', d.[07])-1) =
                                                                      'ABF'
                                                                      THEN 10
                                                                      ELSE 0
                                                                  END
          LEFT JOIN vwLastDXList AS dx08 ON RIGHT(d.[08], LEN(d.[08])-CHARINDEX(':', d.[08])) = dx08.DXCode
                                            AND dx08.ICDVersion = CASE
                                                                      WHEN LEFT(d.[08], CHARINDEX(':', d.[08])-1) =
                                                                      'BF'
                                                                      THEN 9
                                                                      WHEN LEFT(d.[08], CHARINDEX(':', d.[08])-1) =
                                                                      'ABF'
                                                                      THEN 10
                                                                      ELSE 0
                                                                  END
          LEFT JOIN vwLastDXList AS dx09 ON RIGHT(d.[09], LEN(d.[09])-CHARINDEX(':', d.[09])) = dx09.DXCode
                                            AND dx09.ICDVersion = CASE
                                                                      WHEN LEFT(d.[09], CHARINDEX(':', d.[09])-1) =
                                                                      'BF'
                                                                      THEN 9
                                                                      WHEN LEFT(d.[09], CHARINDEX(':', d.[09])-1) =
                                                                      'ABF'
                                                                      THEN 10
                                                                      ELSE 0
                                                                  END
          LEFT JOIN vwLastDXList AS dx10 ON RIGHT(d.[10], LEN(d.[10])-CHARINDEX(':', d.[10])) = dx10.DXCode
                                            AND dx10.ICDVersion = CASE
                                                                      WHEN LEFT(d.[10], CHARINDEX(':', d.[10])-1) =
                                                                      'BF'
                                                                      THEN 9
                                                                      WHEN LEFT(d.[10], CHARINDEX(':', d.[10])-1) =
                                                                      'ABF'
                                                                      THEN 10
                                                                      ELSE 0
                                                                  END
          LEFT JOIN vwLastDXList AS dx11 ON RIGHT(d.[11], LEN(d.[11])-CHARINDEX(':', d.[11])) = dx11.DXCode
                                            AND dx11.ICDVersion = CASE
                                                                      WHEN LEFT(d.[11], CHARINDEX(':', d.[11])-1) =
                                                                      'BF'
                                                                      THEN 9
                                                                      WHEN LEFT(d.[11], CHARINDEX(':', d.[11])-1) =
                                                                      'ABF'
                                                                      THEN 10
                                                                      ELSE 0
                                                                  END
          LEFT JOIN vwLastDXList AS dx12 ON RIGHT(d.[12], LEN(d.[12])-CHARINDEX(':', d.[12])) = dx12.DXCode
                                            AND dx12.ICDVersion = CASE
                                                                      WHEN LEFT(d.[12], CHARINDEX(':', d.[12])-1) =
                                                                      'BF'
                                                                      THEN 9
                                                                      WHEN LEFT(d.[12], CHARINDEX(':', d.[12])-1) =
                                                                      'ABF'
                                                                      THEN 10
                                                                      ELSE 0
                                                                  END;




GO
