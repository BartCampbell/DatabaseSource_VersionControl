SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cm_savePDF 1,'1234.pdf'
CREATE PROCEDURE [dbo].[cm_savePDF] 
	@user int,
	@filename varchar(1000)
AS
BEGIN
	INSERT INTO tblExtractionQueue(PDFname,ExtractionQueueSource_PK,FileSize,AssignedUser_PK,IsDuplicate,UploadDate,AssignedDate) VALUES(@filename,101,100,@user,0,GetDate(),GetDate())
	SELECT @@IDENTITY;
END
GO
