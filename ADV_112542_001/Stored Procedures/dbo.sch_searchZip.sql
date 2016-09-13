SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- um_searchZip '123'
CREATE PROCEDURE [dbo].[sch_searchZip] 
	@Zip varchar(5)
AS
BEGIN
	select top 1 ZipCode_PK,ZipCode,City,County,[State] from tblZipCode WHERE zipcode like @Zip+'%'
END


GO
