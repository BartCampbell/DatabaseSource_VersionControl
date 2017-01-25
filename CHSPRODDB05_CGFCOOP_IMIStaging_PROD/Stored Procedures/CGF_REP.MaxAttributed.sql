SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE    PROC [CGF_REP].[MaxAttributed]
AS

DECLARE @Output TABLE ([ID] int IDENTITY(1,1), FieldValue varchar(50), DisplayValue varchar(50), Description varchar(100))

INSERT INTO @Output (FieldValue, DisplayValue, Description) SELECT NULL, 'All', 'All Patients'

SELECT * FROM @Output 






GO
