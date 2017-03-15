SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vwTaxonomySpecialtyXref]
AS
     SELECT
          *
     FROM Submissions.dbo.TaxonomySpecialtyXref;

GO
