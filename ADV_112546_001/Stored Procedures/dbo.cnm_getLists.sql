SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cnm_getLists 301,'1'
Create PROCEDURE [dbo].[cnm_getLists] 
	@user int
AS
BEGIN
	SELECT Channel_PK, Channel_Name FROM tblChannel ORDER BY Channel_Name
END
GO
