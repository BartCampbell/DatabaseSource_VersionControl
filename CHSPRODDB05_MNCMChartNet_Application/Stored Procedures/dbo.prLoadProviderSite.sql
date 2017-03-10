SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[prLoadProviderSite]
--***********************************************************************
--***********************************************************************
/*
Loads ChartNet Application table: ProviderSite, 
from Client Import table: ProviderSite
*/
--***********************************************************************
--***********************************************************************
AS 
BEGIN;

	BEGIN TRANSACTION TLoadProviderSite;

	INSERT  INTO ProviderSite
			(CustomerProviderSiteID,
			 ProviderSiteName,
			 Address1,
			 Address2,
			 City,
			 State,
			 Zip,
			 Phone,
			 Fax,
			 Contact,
			 County,
			 TaxID
			)
			SELECT  CustomerProviderSiteID = '',
					ProviderSiteName = '',
					Address1 = '',
					Address2 = '',
					City = '',
					State = '',
					Zip = '',
					Phone = '',
					Fax = '',
					Contact = '',
					County = '',
					TaxID = ''
			UNION ALL
			SELECT	DISTINCT
					CustomerProviderSiteID = ProviderSiteID,
					ProviderSiteName = ProviderSiteName,
					Address1 = Address1,
					Address2 = Address2,
					City = City,
					State = State,
					Zip = Zip,
					Phone = Phone,
					Fax = Fax,
					Contact = Contact,
					County = County,
					TaxID = TaxID
			FROM    RDSM.ProviderSite;

	EXEC dbo.prLoadProviderSiteOrigianls;

	COMMIT TRANSACTION TLoadProviderSite;
END;








GO
