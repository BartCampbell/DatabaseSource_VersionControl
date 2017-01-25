SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[Report_NumeratorCompliance]
AS 
SELECT  HedisMeasure = mea.HEDISMeasure,
        CustomerMemberID = m.CustomerMemberID,
        HybridHitCount = HybridHitCount,
        ServiceDate = y.servicedate
FROM    dbo.MemberMeasureMetricScoring mmms
        INNER JOIN dbo.MemberMeasureSample mms ON mmms.MemberMeasureSampleID = mms.MemberMeasureSampleID
        INNER JOIN member m ON mms.MemberID = m.MemberID AND
                               mms.Product = m.Product AND
                               mms.ProductLine = m.ProductLine
        INNER JOIN dbo.Measure mea ON mms.MeasureID = mea.MeasureID
        LEFT JOIN (SELECT   p.memberid,
                            x.servicedate,
                            pe.MeasureID
                   FROM     pursuit p
                            INNER JOIN dbo.PursuitEvent pe ON p.PursuitID = pe.PursuitID
                            INNER JOIN (SELECT  'cbp' hedismeasure,
                                                pursuiteventid,
                                                ServiceDate
                                        FROM    dbo.MedicalRecordCBPReading
                                        UNION
                                        SELECT  'mrp',
                                                PursuitEventID,
                                                ServiceDate
                                        FROM    dbo.MedicalRecordMRP
                                       ) x ON pe.PursuiteventID = x.pursuiteventid
                  ) y ON mea.MeasureID = y.MeasureID AND
                         m.memberid = y.memberid
WHERE   mea.HEDISMeasure IN ('mrp', 'cbp') AND
        mmms.HybridHitCount = 1
GO
