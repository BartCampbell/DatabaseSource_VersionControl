SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RetrieveAdministrativeChartData]
    @MemberID int,
    @MeasureID int = NULL
AS 
SELECT  AdministrativeEventID,
        CustomerAdministrativeEventID,
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
FROM    dbo.AdministrativeEvent
WHERE   MemberID = @MemberID AND
        MeasureID = ISNULL(@MeasureID, MeasureID)


GO
