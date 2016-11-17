SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prCCAIMemberElig]
	-- Add the parameters for the stored procedure here
	--@MemberType varchar(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
select	RecordID,
		CustomerName,
		MemberID,
		HICN,
		convert(date,cast(EligBeginDate as varchar(8))) as EligBeginDate,
		convert(date,cast(EligEndDate as varchar(8))) as EligEndDate,
		MemberType,
		ProviderID
from CHSStaging.dbo.Test_CCAIMembershipReport

END
GO
