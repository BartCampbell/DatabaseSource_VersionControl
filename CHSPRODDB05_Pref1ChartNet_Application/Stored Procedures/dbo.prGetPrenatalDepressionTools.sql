SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jason Franks - jbfranks@gmail.com
-- Create date: 1/25/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[prGetPrenatalDepressionTools] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [ToolDBID] as ToolID
      ,[ToolDesc]
  FROM dbo.[PrenatalDepressionScreeningTools]
  where IsActive=1
END
GO
GRANT EXECUTE ON  [dbo].[prGetPrenatalDepressionTools] TO [ChartNet_AppUser_Custom]
GO
