SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	ir_getCharts 0,1,225,'','AD','DESC',0,0,5,1,0
CREATE PROCEDURE [dbo].[ir_updateInvoice] 
	@Suspect bigint,
	@IsApproved bit,
	@usr int
AS
BEGIN

	UPDATE tblSuspectInvoiceInfo SET IsApproved = @IsApproved, Update_User_PK=@usr, dtUpdate = GETDATE() WHERE Suspect_PK = @Suspect
END



GO
