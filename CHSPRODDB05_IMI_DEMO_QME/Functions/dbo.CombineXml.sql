SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE AGGREGATE [dbo].[CombineXml] (@Value [xml], @ForceUnique [bit])
RETURNS [xml]
EXTERNAL NAME [IMI.MeasureEngine.Data.SqlClr].[IMI.MeasureEngine.Data.SqlClr.CombineXml]
GO
GRANT EXECUTE ON  [dbo].[CombineXml] TO [Processor]
GO
