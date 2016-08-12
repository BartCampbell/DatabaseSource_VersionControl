SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sa_getZones 1
CREATE PROCEDURE [dbo].[sa_getZones] 
	@zone int
AS
BEGIN
	IF (@zone<>0) 
		SELECT Zipcode_PK FROM tblZoneZipcode WHERE Zone_PK=@zone
	ELSE IF (@zone=0)
	BEGIN
		SELECT Zone_PK, Zone_Name FROM tblZone WITH (NOLOCK) 
	END
END
GO
