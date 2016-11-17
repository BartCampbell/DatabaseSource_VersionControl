SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vw_x12_parse_temp_segment]
AS
SELECT     TOP (100) PERCENT x12_parse_temp_id, x12_parse_temp_uid, dbo.fn_RTrimPat(ISNULL(Col001, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col002, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col003, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col004, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col005, '') 
                      + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col006, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col007, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col008, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col009, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col010, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col011, '') 
                      + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col012, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col013, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col014, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col015, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col016, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col017, '') 
                      + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col018, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col019, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col020, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col021, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col022, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col023, '') 
                      + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col024, '') + ISNULL(x12_interchange.element_separator, '*') + ISNULL(Col025, ''), ISNULL(x12_interchange.element_separator, '*')) AS segment
FROM         dbo.x12_parse_temp
INNER JOIN dbo.x12_interchange
	ON x12_parse_temp.x12_parse_temp_uid = x12_interchange.x12_interchange_uid
ORDER BY x12_parse_temp_id

GO
