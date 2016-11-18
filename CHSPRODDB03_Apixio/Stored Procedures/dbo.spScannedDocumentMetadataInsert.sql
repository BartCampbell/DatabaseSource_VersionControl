SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Author:			Michael Vlk
Create Date:	2016-07-08
Description:	Insert a single record into ScannedDocumentMetadata
Usage:		
	DECLARE @ScannedDocumentMetadataID int
	DECLARE @Date_Refreshed datetime = GETDATE()
	EXECUTE dbo.spScannedDocumentMetadataInsert 
		5 --Pat_Id varchar(30)
		,'PDF' --@Document_Type varchar(10)
		,'TestDocName' --@Document_Title varchar(50)
		,'/FilePatheHere/ThenHere/FinallyHere/' --@File_Path_Name varchar(200)
		,NULL --@From_Date varchar(10) = NULL
		,NULL --@Thru_Date varchar(10) = NULL
		,1998 --@Provider_Id varchar(20)
		,264193 --@Chase_Id bigint
		,@Date_Refreshed --@Date_Refreshed datetime
		,5 --Document_Id bigint
		,@ScannedDocumentMetadataID OUTPUT --@ScannedDocumentMetadataID int OUTPUT
	SELECT @ScannedDocumentMetadataID
****************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[spScannedDocumentMetadataInsert] 
	@Pat_Id varchar(30)
	,@Document_Type varchar(10)
	,@Document_Title varchar(50)
	,@File_Path_Name varchar(200)
	,@From_Date varchar(10) = NULL
	,@Thru_Date varchar(10) = NULL
	,@Provider_Id varchar(20)
	,@Chase_Id bigint
	,@Date_Refreshed datetime
	,@Document_Id bigint
	,@ScannedDocumentMetadataID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON

	INSERT INTO dbo.ScannedDocumentMetadata
		(Pat_Id,Document_Type,Document_Title,File_Path_Name,From_Date,Thru_Date,Provider_Id,Chase_Id,Date_Refreshed,Document_ID)
	SELECT  
		@Pat_Id --tblSuspect.Member_PK
		,@Document_Type --~JPG
		,@Document_Title --~tblScannedData.FileName
		,@File_Path_Name --~
		,@From_Date --
		,@Thru_Date --
		,@Provider_Id --tblSuspect.Provider_PK
		,@Chase_Id --tblSuspect.ChaseID
		,@Date_Refreshed --~GETDATE()
		,@Document_Id --tblScannedData.ScannedData_PK


	SELECT @ScannedDocumentMetadataID = SCOPE_IDENTITY()
END
GO
