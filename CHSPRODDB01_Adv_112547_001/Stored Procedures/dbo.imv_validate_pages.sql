SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	imv_move_pages '0,0,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22',9802,2,1
CREATE PROCEDURE [dbo].[imv_validate_pages] 
	@Source_Suspect bigint,
	@Usr int
AS
BEGIN	
		IF NOT EXISTS (SELECT * FROM tblScanningQANote_Suspect WHERE Suspect_PK=@Source_Suspect)
			INSERT INTO tblScanningQANote_Suspect(Suspect_PK,ScanningQANote_PK,dtQA,QA_User_PK) VALUES (@Source_Suspect,1,GetDate(),@usr)
		ELSE
			Update tblScanningQANote_Suspect SET ScanningQANote_PK=1, dtQA=GETDATE(), QA_User_PK=@usr WHERE Suspect_PK=@Source_Suspect
END
GO
