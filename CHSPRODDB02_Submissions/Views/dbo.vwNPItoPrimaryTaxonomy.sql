SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW  [dbo].[vwNPItoPrimaryTaxonomy]
AS

SELECT	NPI
		,CASE	WHEN [Healthcare Provider Primary Taxonomy Switch_1] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_1]
				WHEN [Healthcare Provider Primary Taxonomy Switch_2] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_2]
				WHEN [Healthcare Provider Primary Taxonomy Switch_3] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_3]
				WHEN [Healthcare Provider Primary Taxonomy Switch_4] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_4]
				WHEN [Healthcare Provider Primary Taxonomy Switch_5] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_5]
				WHEN [Healthcare Provider Primary Taxonomy Switch_6] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_6]
				WHEN [Healthcare Provider Primary Taxonomy Switch_7] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_7]
				WHEN [Healthcare Provider Primary Taxonomy Switch_8] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_8]
				WHEN [Healthcare Provider Primary Taxonomy Switch_9] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_9]
				WHEN [Healthcare Provider Primary Taxonomy Switch_10] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_10]
				WHEN [Healthcare Provider Primary Taxonomy Switch_11] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_11]
				WHEN [Healthcare Provider Primary Taxonomy Switch_12] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_12]
				WHEN [Healthcare Provider Primary Taxonomy Switch_13] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_13]
				WHEN [Healthcare Provider Primary Taxonomy Switch_14] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_14]
				WHEN [Healthcare Provider Primary Taxonomy Switch_15] = 'Y'
				THEN [Healthcare Provider Taxonomy Code_15]
				END	AS 'PrimaryTaxonomyCode'
--FROM	RefMart.CMS.NPI_MASTER
FROM	chsdw.ref.NPI_Master



GO
