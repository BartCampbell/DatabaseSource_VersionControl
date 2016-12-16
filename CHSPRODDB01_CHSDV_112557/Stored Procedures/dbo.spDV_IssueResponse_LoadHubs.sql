SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/30/2016
-- Description:	Load all Hubs from the IssueResponse staging table.  
-- =============================================
CREATE PROCEDURE [dbo].[spDV_IssueResponse_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** LOAD H_PROVIDER
INSERT INTO [dbo].[H_IssueResponse]
           ([H_IssueResponse_RK]
           ,[IssueResponse_BK]
           ,[ClientIssueResponseID]
           ,[RecordSource]
           ,[LoadDate])
 
SELECT	DISTINCT IssueResponseHashKey, CRI, IssueResponse_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblIssueResponseStage
	WHERE
		IssueResponseHashKey NOT IN (SELECT H_IssueResponse_RK FROM H_IssueResponse)
		AND CCI = @CCI

		

END




GO
