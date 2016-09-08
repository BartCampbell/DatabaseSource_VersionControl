SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cm_getRecentFiles 1,1
CREATE PROCEDURE [dbo].[cm_getRecentFiles] 
	@User smallint,
	@doNext tinyInt
AS
BEGIN
		if @doNext=1 
		BEGIN
			with tbl as (
				SELECT TOP (1) * FROM tblExtractionQueue WHERE AssignedUser_PK IS NULL ORDER BY UploadDate ASC)

			Update tbl SET AssignedUser_PK=@User, AssignedDate=GETDATE()
		END
			

		SELECT TOP 20 EQ.ExtractionQueue_PK,PDFname,COUNT(DISTINCT EQAL.Suspect_PK) AttachedCharts,AssignedDate FROM tblExtractionQueue EQ WITH (NOLOCK)
			LEFT JOIN tblExtractionQueueAttachLog EQAL WITH (NOLOCK) ON EQ.ExtractionQueue_PK = EQAL.ExtractionQueue_PK
		WHERE AssignedUser_PK=@User
		GROUP BY EQ.ExtractionQueue_PK,PDFname,AssignedDate
		ORDER BY AssignedDate DESC
END
GO
