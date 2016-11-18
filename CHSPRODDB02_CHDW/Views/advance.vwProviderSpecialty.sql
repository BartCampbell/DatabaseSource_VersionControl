SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







/*
    Author: Travis Parker
    Date:	  05/12/2016
    Name:	  advance.vwProviderSpecialty
    Desc:	  view of ProviderSpecialty data for Advance ETL
*/

CREATE VIEW [advance].[vwProviderSpecialty]
AS
     SELECT DISTINCT
          p.CentauriProviderID,
          COALESCE(NULLIF(s.ProviderTypeDesc, ''), s.TaxonomyDesc) AS Specialty
     FROM dim.Provider AS p
          INNER JOIN dim.ProviderSpecialty AS ps ON p.ProviderID = ps.ProviderID
          INNER JOIN dim.Specialty AS s ON ps.SpecialtyID = s.SpecialtyID;




GO
