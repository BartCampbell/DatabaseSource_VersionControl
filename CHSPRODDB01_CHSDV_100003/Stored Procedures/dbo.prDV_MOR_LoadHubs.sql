SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:	    Jason Franks
-- Create date: 2/23/2016
-- Description:	Load MOR header/trailer data to the DV from Staging 
-- =============================================
CREATE PROCEDURE [dbo].[prDV_MOR_LoadHubs]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- LOAD MOR HEADER TABLE
	INSERT INTO [dbo].[H_MOR_Header]
	SELECT MOR_Header_RK,RecordTypeCode,ContractNumber,RunDate,PaymentYearandMonth,Filler,LoadDate,RecordSource FROM CHSStaging.dbo.MOR_Header_Stage
	WHERE MOR_Header_RK NOT IN (SELECT MOR_Header_RK FROM H_MOR_Header)

	-- LOAD MOR TRAILER TABLE
	INSERT INTO [dbo].[H_MOR_Trailer]
	SELECT MOR_Trailer_RK,RecordTypeCode,ContractNumber,TotalRecordCount,Filler,LoadDate,RecordSource FROM CHSStaging.dbo.MOR_Trailer_Stage
	WHERE MOR_Trailer_RK NOT IN (SELECT MOR_Trailer_RK FROM H_MOR_Trailer)

	
END
GO
