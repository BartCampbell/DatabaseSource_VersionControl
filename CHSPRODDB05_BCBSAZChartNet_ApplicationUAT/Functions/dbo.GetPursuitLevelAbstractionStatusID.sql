SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/4/2014
-- Description:	Returns the "minimum" status value of child pursuit events, as the overall pursuit-level status
-- =============================================
CREATE FUNCTION [dbo].[GetPursuitLevelAbstractionStatusID]
(
	@PursuitID int
)
RETURNS int
AS
BEGIN
	RETURN (SELECT TOP 1 MIN(AbstractionStatusID) FROM dbo.PursuitEvent WHERE (PursuitID = @PursuitID));
END
GO
