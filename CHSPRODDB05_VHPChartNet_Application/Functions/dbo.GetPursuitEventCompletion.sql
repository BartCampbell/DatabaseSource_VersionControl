SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/4/2014
-- Description:	Returns the ratio of completed (or equivalen status) pursuit events to total pursuit events.
-- =============================================
CREATE FUNCTION [dbo].[GetPursuitEventCompletion]
(
	@PursuitID int
)
RETURNS varchar(32)
AS
BEGIN
	RETURN (
				SELECT TOP 1 
						CONVERT(varchar(32), SUM(CASE WHEN A.IsCompleted = 1 THEN 1 ELSE 0 END)) + ' / ' + 
						CONVERT(varchar(32), SUM(1))
				FROM	dbo.PursuitEvent AS RV 
						LEFT OUTER JOIN dbo.AbstractionStatus AS A WITH(NOLOCK) 
								ON RV.AbstractionStatusID = A.AbstractionStatusID 
				WHERE	(PursuitID = @PursuitID)
			);
END
GO
