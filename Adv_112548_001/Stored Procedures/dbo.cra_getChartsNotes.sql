SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	cra_getCharts 0,0,5498,1,1,25,0,0,0
CREATE PROCEDURE [dbo].[cra_getChartsNotes] 
	@Suspect bigint
AS
BEGIN
	SELECT U.Lastname + ', ' + U.Firstname fullname, SINL.dtInsert, IsNull(SINL.IsScheduler,0) IsScheduler,
		IncompleteNote,Note
	FROM tblSuspectIncompleteNotesLog SINL
		INNER JOIN tblIncompleteNote ICN ON ICN.IncompleteNote_PK = SINL.IncompleteNote_pk
		INNER JOIN tblUser U ON U.User_PK = SINL.User_PK
	WHERE SINL.Suspect_PK = @Suspect	
	ORDER BY SINL.dtInsert DESC
END
GO
