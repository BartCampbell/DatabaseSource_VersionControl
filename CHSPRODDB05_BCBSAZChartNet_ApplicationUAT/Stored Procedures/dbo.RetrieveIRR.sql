SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RetrieveIRR]
	@AbstractorID int = null,
	@ReviewerID int = null,
	@MeasureID int = null
AS
BEGIN
	SET NOCOUNT ON;

SELECT mc.Measure                                                  ,
       mc.Abstractions                                             ,
       COALESCE(rt.AbstractionsReviewed, 0) AS AbstractionsReviewed,
	   cast(COALESCE(rt.AbstractionsReviewed, 0) as float)/mc.Abstractions as ReviewPercentage,
       ReviewPointsAvailable,
	   case when rc.ReviewPointsAvailable is null then null else coalesce(rc.ReviewPointsMissed, 0) end  AS ReviewPointsMissed  ,
       case when rc.ReviewPointsAvailable is null then null when rc.ReviewPointsAvailable=0 then 1 else cast(COALESCE(ReviewPointsAvailable, 0)-COALESCE(rc.ReviewPointsMissed, 0) as float)/COALESCE(ReviewPointsAvailable, 0) end as Accuracy 
FROM   (SELECT  m.HEDISMeasure AS              Measure,
                COUNT(1)       AS              Abstractions
       FROM     Measure   AS m
                inner JOIN PursuitEvent   AS pe ON       pe.MeasureID = m.MeasureID
                inner JOIN Pursuit AS p ON       pe.PursuitID = p.PursuitID
			where (@AbstractorID is null or p.AbstractorID=@AbstractorID)
				and (@MeasureID is null or m.MeasureID = @MeasureID)
       GROUP BY m.HEDISMeasure
       ) AS mc
	   LEFT JOIN
              (SELECT  m.HEDISMeasure             AS Measure              ,
                       COUNT(1)                   AS AbstractionsReviewed 
              FROM     PursuitEvent               AS pe
                       JOIN Measure               AS m  ON       pe.MeasureID = m.MeasureID
                       JOIN Pursuit AS p  on	p.pursuitID = pe.pursuitID
						where exists (select 1 from AbstractionReview AS r 
										where r.PursuitEventID = pe.PursuitEventID 
										and (@ReviewerID is null or r.ReviewerID=@ReviewerID)
									)
						and (@AbstractorID is null or p.AbstractorID=@AbstractorID)
						and (@MeasureID is null or m.MeasureID = @MeasureID)
	              GROUP BY m.HEDISMEasure
              ) AS rt ON     mc.Measure = rt.Measure
       LEFT JOIN
              (SELECT  m.HEDISMeasure             AS Measure              ,
                       SUM(ReviewPointsAvailable) AS ReviewPointsAvailable,
                       SUM(rdt.Deductions)        AS ReviewPointsMissed
              FROM     PursuitEvent               AS pe
                       JOIN Measure               AS m  ON       pe.MeasureID = m.MeasureID
                       JOIN Pursuit AS p ON       pe.PursuitID = p.PursuitID
                       JOIN AbstractionReview AS r ON       r.PursuitEventID = pe.PursuitEventID
                       LEFT JOIN
                                (SELECT  rd.AbstractionReviewID,
                                         SUM(rd.Deductions)      AS Deductions
                                FROM     AbstractionReviewDetail AS rd
                                GROUP BY rd.AbstractionReviewID
                                ) AS rdt
                       ON r.AbstractionReviewID = rdt.AbstractionReviewID
				where  (@ReviewerID is null or r.ReviewerID=@ReviewerID)
					and (@AbstractorID is null or p.AbstractorID=@AbstractorID)
					and (@MeasureID is null or m.MeasureID = @MeasureID)
              GROUP BY m.HEDISMEasure
              ) AS rc
       ON     rt.Measure = rc.Measure
order by Measure
END
GO
