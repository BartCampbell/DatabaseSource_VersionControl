SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cpm_Update] 
	@id int, 
	@coderlevel int
AS
BEGIN	
	Update tblUser SET CoderLevel=@coderlevel
	WHERE User_PK=@id
END
GO
