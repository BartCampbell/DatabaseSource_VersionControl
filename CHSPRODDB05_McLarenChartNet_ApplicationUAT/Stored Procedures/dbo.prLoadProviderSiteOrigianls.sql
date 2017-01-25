SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[prLoadProviderSiteOrigianls]
AS
BEGIN
	
	UPDATE	dbo.ProviderSite
	SET		OriginalAddress1 = Address1,
			OriginalAddress2 = Address2,
			OriginalCity = City,
			OriginalState = State,
			OriginalZip = Zip,
			OriginalPhone = Phone,
			OriginalFax = Fax,
			OriginalContact = Contact,
			OriginalCounty = County,
			CreatedUser = ISNULL(CreatedUser, 'system'),
			LastChangedUser = ISNULL(LastChangedUser, 'system')
	WHERE	(OriginalAddress1 IS NULL) AND
			(OriginalAddress2 IS NULL) AND
			(OriginalCity IS NULL) AND
			(OriginalState IS NULL) AND
			(OriginalZip IS NULL) AND
			(OriginalPhone IS NULL) AND
			(OriginalFax IS NULL) AND
			(OriginalContact IS NULL) AND
			(OriginalCounty IS NULL);

END
GO
