SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








/*
    Author: Travis Parker
    Date:	  05/12/2016
    Name:	  advance.vwProvider
    Desc:	  view of Provider data for Advance ETL
*/

CREATE VIEW [advance].[vwProvider]
AS
     SELECT DISTINCT
          p.CentauriProviderID,
		p.NPI,
          RTRIM(LTRIM(p.LastName)) LastName,
          RTRIM(LTRIM(p.FirstName)) FirstName
     FROM dim.Provider AS p


GO
