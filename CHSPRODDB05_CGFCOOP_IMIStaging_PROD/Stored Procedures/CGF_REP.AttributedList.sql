SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE    PROC [CGF_REP].[AttributedList]
AS

DECLARE @Output TABLE ([ID] int IDENTITY(1,1), FieldValue varchar(50), DisplayValue varchar(50), Description varchar(100))

INSERT INTO @Output (FieldValue, DisplayValue, Description) SELECT NULL, 'All', 'All Patients'
INSERT INTO @Output (FieldValue, DisplayValue, Description) SELECT 1, 'Out Of Network', 'Out of Network - Patients attributed to an out of network PCP'
INSERT INTO @Output (FieldValue, DisplayValue, Description) SELECT 2, 'St Francis', 'St. Francis - Patients attributed to a St. Francis PCP'
INSERT INTO @Output (FieldValue, DisplayValue, Description) SELECT 3, 'Unattributed', 'Unattributed - Patients not attributed to any PCP, regardless of reason'

SELECT * FROM @Output 






GO
