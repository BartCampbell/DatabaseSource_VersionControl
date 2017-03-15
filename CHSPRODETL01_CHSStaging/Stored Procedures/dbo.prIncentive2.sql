SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








-- =============================================
-- Author:		Brandon Rodman
-- Create date: 09/12/2016
-- Description:	Provides data for the Care Collaboration - Incentive 2 - Provider Payment
-- =============================================
CREATE PROCEDURE [dbo].[prIncentive2] 
	@GroupID varchar(25),
	@ProviderID varchar(25)
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


set ANSI_Warnings OFF;


SELECT RecID, PCPID, PCPName, GroupID, GroupName, LEFT(FullMeasureDescription, CHARINDEX(':', FullMeasureDescription) - 1) AS MeasureCode, DisplayName, Denominator, Numerator, IncentiveAmt, PotentialAmt, LoadDate
FROM   CHSStaging.dbo.FHN_CareCollaboration_IncentivePayment
WHERE GroupID = @GroupID 
AND PCPID = @ProviderID

END






GO
