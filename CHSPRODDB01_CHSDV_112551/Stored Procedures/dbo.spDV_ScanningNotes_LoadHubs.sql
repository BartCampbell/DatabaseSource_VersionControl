SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/25/2016
-- Description:	Load all Hubs from the ScanningNotes staging table.  
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ScanningNotes_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** LOAD H_PROVIDER
INSERT INTO [dbo].[H_ScanningNotes]
           ([H_ScanningNotes_RK]
           ,[ScanningNotes_BK]
           ,[ClientScanningNotesID]
           ,[RecordSource]
           ,[LoadDate])
 
SELECT	DISTINCT ScanningNotesHashKey, CNI, ScanningNote_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblScanningNotesStage
	WHERE
		ScanningNotesHashKey not in (Select H_ScanningNotes_RK from H_ScanningNotes)
		AND CCI = @CCI



--** LOAD H_CLIENT
INSERT INTO H_Client
	SELECT 
		DISTINCT ClientHashKey, CCI, Client, RecordSource,  LoadDate
	FROM 
		CHSStaging.adv.tblScanningNotesStage
	WHERE
		ClientHashKey not in (Select H_Client_RK from H_Client)
			AND CCI = @CCI




END



GO
