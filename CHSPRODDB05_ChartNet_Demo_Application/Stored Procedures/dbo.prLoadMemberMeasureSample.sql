SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[prLoadMemberMeasureSample]
--***********************************************************************
--***********************************************************************
/*
Loads ChartNet Application table: MemberMeasureSample, 
from Client Import table: MemberMeasureSample
*/
--select * from MemberMeasureSample
--***********************************************************************
--***********************************************************************
AS 
INSERT  INTO MemberMeasureSample
        (ProductLine,
         Product,
         MemberID,
         MeasureID,
         EventDate,
         SampleType,
         SampleDrawOrder,
         PPCPrenatalCareStartDate,
         PPCPrenatalCareEndDate,
         PPCPostpartumCareStartDate,
         PPCPostpartumCareEndDate,
         PPCEnrollmentCategoryID,
		 DiabetesDiagnosisDate)
        SELECT  ProductLine = a.ProductLine,
                Product = a.Product,
                MemberID = b.MemberID,
                MeasureID = c.MeasureID,
                EventDate = EventDate,
                SampleType = SampleType,
                SampleDrawOrder = SampleDrawOrder,
                PPCPrenatalCareStartDate = PPCPrenatalCareStartDate,
                PPCPrenatalCareEndDate = PPCPrenatalCareEndDate,
                PPCPostpartumCareStartDate = PPCPostpartumCareStartDate,
                PPCPostpartumCareEndDate = PPCPostpartumCareEndDate,
                PPCEnrollmentCategoryID = d.PPCEnrollmentCategoryID,
				DiabetesDiagnosisDate = a.DiabetesDiagnosisDate
        FROM    RDSM.MemberMeasureSample a
                INNER JOIN Member b ON a.CustomerMemberID = b.CustomerMemberID AND
                                       a.ProductLine = b.ProductLine AND
                                       a.Product = b.Product
                INNER JOIN Measure c ON a.HEDISMeasure = c.HEDISMeasure
                LEFT JOIN PPCEnrollmentCategory d ON a.PPCEnrollmentCategory = d.PPCEnrollmentCategory OR (ISNUMERIC(a.PPCEnrollmentCategory) = 1 AND CONVERT(int, a.PPCEnrollmentCategory) = d.PPCEnrollmentCategoryID)










GO
