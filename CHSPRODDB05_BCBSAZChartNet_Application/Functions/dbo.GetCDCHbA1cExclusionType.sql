SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/2/2012
-- Description:	Returns the ExclusionType description for HbA1c <7 Exclusions
-- =============================================
CREATE FUNCTION [dbo].[GetCDCHbA1cExclusionType] 
(
	@ExclusionTypeID int
)
RETURNS nvarchar(300)
AS
BEGIN
	
	DECLARE @Result nvarchar(300);
	
	SELECT	@Result = [Description]
	FROM	dbo.DropDownValues_CDCHbA1cExclusionType
	WHERE	ExclusionTypeID = @ExclusionTypeID;

	RETURN @Result;

END
GO
