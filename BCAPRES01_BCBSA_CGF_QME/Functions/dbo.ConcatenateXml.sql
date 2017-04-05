SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE AGGREGATE [dbo].[ConcatenateXml] (@Value [xml], @ForceUnique [bit])
RETURNS [xml]
EXTERNAL NAME [IMI.MeasureEngine.Data.SqlClr].[ConcatenateXml]
GO
