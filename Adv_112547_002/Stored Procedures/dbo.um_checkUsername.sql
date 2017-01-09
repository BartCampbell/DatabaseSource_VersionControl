SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- um_getUsers 1,25,'','UN','DESC'
create PROCEDURE [dbo].[um_checkUsername] 
	@Usr varchar(300)
AS
BEGIN
	SELECT Count(*) from tblUser WHERE Username Like @Usr
END

GO
