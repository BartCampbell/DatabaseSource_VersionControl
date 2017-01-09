SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	[sch_getAssignment] @Office=0
CREATE PROCEDURE [dbo].[sch_getAssignment] 
	@Office bigint
AS
BEGIN
	SELECT IsNull(POAU.Lastname+IsNull(','+POAU.Firstname,''),'') AssignedScheduler	
	FROM tblProviderOffice PO WITH (NOLOCK) INNER JOIN tblUser POAU WITH (NOLOCK) ON PO.AssignedUser_PK = POAU.User_PK
	WHERE PO.ProviderOffice_PK = @Office
END
GO
