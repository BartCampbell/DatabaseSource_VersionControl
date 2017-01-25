SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/5/2012
-- Description:	Refreshes all data from ChartNet by running all related procedures.
-- =============================================
CREATE PROCEDURE [ChartNet].[RefreshAllData]
(
	@DataRunID int,
	@FlexDaysforFPCPPC tinyint = 30,
	@FlexDaysForMRP tinyint = 7,
	@IgnoreValidation bit = 0,
	@IncludeEnrollGroup bit = 0,
	@ProductPrefix varchar(32) = NULL,
	@ProductSuffix varchar(32) = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	EXEC ChartNet.RefreshResults	@DataRunID = @DataRunID, 
									@FlexDaysforFPCPPC = @FlexDaysforFPCPPC, 
									@FlexDaysForMRP = @FlexDaysForMRP,
									@IncludeEnrollGroup = @IncludeEnrollGroup,
									@IgnoreValidation = @IgnoreValidation,
									@ProductPrefix = @ProductPrefix,
									@ProductSuffix = @ProductSuffix;
	;
    EXEC ChartNet.RefreshEvents		@DataRunID = @DataRunID,
									@FlexDaysforFPCPPC = @FlexDaysforFPCPPC, 
									@FlexDaysForMRP = @FlexDaysForMRP;
        
    RETURN 0;
END

GO
GRANT EXECUTE ON  [ChartNet].[RefreshAllData] TO [Processor]
GO
