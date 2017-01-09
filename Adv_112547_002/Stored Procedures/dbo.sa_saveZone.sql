SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sa_saveZone 0
CREATE PROCEDURE [dbo].[sa_saveZone] 
	@PK int,
	@zone_name varchar(50),
	@zips varchar(max)
AS
BEGIN
	if @PK=0
	BEGIN
		INSERT INTO tblZone(Zone_Name) VALUES (@zone_name)
		SELECT @PK=@@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE tblZone SET Zone_Name=@zone_name WHERE Zone_PK = @PK
		DELETE FROM tblZoneZipcode WHERE Zone_PK = @PK
	END	

	SET @zips = 'INSERT INTO tblZoneZipcode(Zone_PK,Zipcode_PK)
	SELECT '+CAST(@PK as varchar)+',Zipcode_PK FROM tblZipcode WHERE Zipcode_PK IN ('+ @zips +')'

	EXEC(@zips)

	SELECT Zone_PK, Zone_Name FROM tblZone WITH (NOLOCK) 
END
GO
