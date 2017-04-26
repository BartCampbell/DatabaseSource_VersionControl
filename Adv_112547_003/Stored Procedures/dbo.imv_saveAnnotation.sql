SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	imv_saveAnnotation 	@ScannedDataPK=0 ,@ScannedDataAnnotation_PK=0 ,	@text='' ,	@position_top=0 ,	@position_left=0 ,@width=0 ,@height=0
CREATE PROCEDURE [dbo].[imv_saveAnnotation] 
	@ScannedDataPK bigint,
	@ScannedDataAnnotation_PK bigint,
	@text varchar(250),
	@position_top smallint,
	@position_left smallint,
	@width smallint,
	@height smallint
AS
BEGIN
	IF @ScannedDataAnnotation_PK=0
	BEGIN
		PRINT 'Insertion'
		INSERT INTO tblScannedDataAnnotation(ScannedData_PK,[text],position_top,position_left,width,height) VALUES(@ScannedDataPK,@text,@position_top,@position_left,@width,@height)
		SELECT @ScannedDataAnnotation_PK = @@IDENTITY
	END
	ELSE IF @text='' 
	BEGIN
		PRINT 'DELETE'
		DELETE FROM tblScannedDataAnnotation WHERE ScannedDataAnnotation_PK=@ScannedDataAnnotation_PK
	END
	ELSE
	BEGIN
		PRINT 'UPDATE'
		UPDATE tblScannedDataAnnotation SET ScannedData_PK=@ScannedDataPK,[text]=@text,position_top=@position_top,position_left=@position_left,width=@width,height=@height WHERE ScannedDataAnnotation_PK=@ScannedDataAnnotation_PK
	END
	SELECT @ScannedDataAnnotation_PK;
END
GO
