SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sch_mergeOffice 7,'0,0',1
CREATE PROCEDURE [dbo].[sch_saveEMR] 
	@emr varchar(25),
	@user int
AS
BEGIN
	IF not exists(SELECT * FROM tblEMR_Type WHERE REPLACE(EMR_Type,' ','')  like REPLACE(@emr,' ',''))
	BEGIN
		Insert Into tblEMR_Type(EMR_Type,User_PK,dtInsert,IsNew) values(@emr,@user,GetDate(),1)

		SELECT @@IDENTITY EMR_Type_PK, 1 Added
	END
	ELSE
	BEGIN
		SELECT TOP 1 EMR_Type_PK,0 Added FROM tblEMR_Type WHERE REPLACE(EMR_Type,' ','')  like REPLACE(@emr,' ','')
	END
END

GO
