SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwProviderSpecialties]
AS
select NPI, Specialty, TaxonomyCode
FROM
(
select NPI, 
NULLIF([Healthcare Provider Taxonomy Code_1],'') AS Specialty1,
NULLIF([Healthcare Provider Taxonomy Code_2],'') AS Specialty2,
NULLIF([Healthcare Provider Taxonomy Code_3],'') AS Specialty3,
NULLIF([Healthcare Provider Taxonomy Code_4],'') AS Specialty4,
NULLIF([Healthcare Provider Taxonomy Code_5],'') AS Specialty5,
NULLIF([Healthcare Provider Taxonomy Code_6],'') AS Specialty6,
NULLIF([Healthcare Provider Taxonomy Code_7],'') AS Specialty7,
NULLIF([Healthcare Provider Taxonomy Code_8],'') AS Specialty8,
NULLIF([Healthcare Provider Taxonomy Code_9],'') AS Specialty9,
NULLIF([Healthcare Provider Taxonomy Code_10],'') AS Specialty10,
NULLIF([Healthcare Provider Taxonomy Code_11],'') AS Specialty11,
NULLIF([Healthcare Provider Taxonomy Code_12],'') AS Specialty12,
NULLIF([Healthcare Provider Taxonomy Code_13],'') AS Specialty13,
NULLIF([Healthcare Provider Taxonomy Code_14],'') AS Specialty14,
NULLIF([Healthcare Provider Taxonomy Code_15],'') AS Specialty15
FROM RefMart.CMS.NPI_Master m 
) AS UP 
UNPIVOT
(
    TaxonomyCode FOR Specialty IN (Specialty1, Specialty2, Specialty3, Specialty4, Specialty5, Specialty6, Specialty7, Specialty8, Specialty9, Specialty10, Specialty11, Specialty12, Specialty13, Specialty14, Specialty15 )
) as upv;


GO
