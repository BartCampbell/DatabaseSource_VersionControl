SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[prLoadAdministrativeEvent]
--***********************************************************************
--***********************************************************************
/*
Loads ChartNet Application table: AdministrativeEvent, 
from Client Import table: AdministrativeEvent
*/
--select * from AdministrativeEvent
--***********************************************************************
--***********************************************************************
AS 
INSERT  INTO AdministrativeEvent
        (CustomerAdministrativeEventID,
         MeasureID,
         HEDISSubMetricID,
         MemberID,
         ProviderID,
         ServiceDate,
         ProcedureCode,
         DiagnosisCode,
         LOINC,
         LabResult,
         NDCCode,
         NDCDescription,
         CPT_IICode,
         Data_Source
		)
        SELECT  CustomerAdministrativeEventID = AdministrativeEventID,
                MeasureID = d.MeasureID,
                HEDISSubMetricID = e.HEDISSubMetricID,
                MemberID = b.MemberID,
                ProviderID = ISNULL(c.ProviderID,
                                    (SELECT MIN(c2.ProviderID)
                                     FROM   Providers c2
                                     WHERE  c2.CustomerProviderID = ''
                                    )),
                ServiceDate = ServiceDate,
                ProcedureCode = ProcedureCode,
                DiagnosisCode = DiagnosisCode,
                LOINC = LOINC,
                LabResult = ISNULL(CASE WHEN ISNUMERIC(LabResult) = 1
                                        THEN LabResult
                                        ELSE NULL
                                   END, 0.0),
                NDCCode = NDCCode,
                NDCDescription = LEFT(NDCDescription, 30),
                CPT_IICode = CPT_IICode,
                Data_Source = LEFT(Data_Source, 50)
        FROM    RDSM.AdministrativeEvent a
                LEFT JOIN Member b ON a.CustomerMemberID = b.CustomerMemberID
                LEFT JOIN Providers c ON a.CustomerProviderID = c.CustomerProviderID
                INNER JOIN Measure d ON a.HEDISMeasure = d.HEDISMeasure
                LEFT JOIN HEDISSubMetric e ON a.HEDISSubMetric = e.HEDISSubMetricCode
        WHERE   ISNULL(LabResult, '') <> '.'










GO
