SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Alter date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- um_getUsers 1,25,'','UN','DESC'
CREATE PROCEDURE [dbo].[um_checkUsername] 
	@Usr varchar(300)
AS
BEGIN
	SELECT Count(*) from tblUser WITH (NOLOCK) WHERE Username Like @Usr
END



GO
