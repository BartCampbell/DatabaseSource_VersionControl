SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetReviewSets]
AS
BEGIN

	SET NOCOUNT ON

    SELECT  AbstractionReviewSetID,
			Description,
			StartDate,
            EndDate,
            SelectionPercentage,
            CASE Finalized
              WHEN 1 THEN 'Yes'
              ELSE 'No'
            END AS [Finalized],
            CreatedUser AS [CreatedBy],
            CreatedDate AS [CreatedDate]
    FROM    dbo.AbstractionReviewSet
    ORDER BY EndDate DESC
END

GO
