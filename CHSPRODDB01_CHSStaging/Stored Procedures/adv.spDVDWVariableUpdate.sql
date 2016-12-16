SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 12/12/2016
-- Description:	Update variables for Advance DVDW  Load
-- =============================================
CREATE PROCEDURE [adv].[spDVDWVariableUpdate]
	@CCI INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    TRUNCATE TABLE [adv].[AdvanceVariableLoad]

	INSERT INTO [adv].[AdvanceVariableLoad] (VariableLoadKey) 
	SELECT AVKEY FROM adv.AdvanceVariables 
	WHERE ClientID=@CCI

END
GO
