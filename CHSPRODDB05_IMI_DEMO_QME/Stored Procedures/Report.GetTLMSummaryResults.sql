SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetTLMSummaryResults] ( 
	@DataRunID INT 
)
AS
    BEGIN

------------------------------------------------------------
/*

OUTPUT SSRS COLUMNS SHOULD BE:
- PopulationNum, displayed as "Population"
- PopulationDescr, displayed as "Description"
- ProductLineDescr, displayed as "Product Line"
- ProductTypeAbbrev, displayed as "Product Type"
- ProductTypeDescription, displayed as "Product Type Description"
- CountDenominator, displayed as "Members"

FYI: Report's record sort should match the output of the resultset as is

*/
------------------------------------------------------------

        WITH    TLMBase
                  AS ( SELECT   SUM(CONVERT(INT, RMD.IsDenominator)) AS CountDenominator ,
                                COUNT(DISTINCT RMD.DSMemberID) AS CountMembers ,
                                COUNT(*) AS CountRecords ,
                                MIN(RDSPK.Descr) AS PopulationDescr ,
                                RMD.PopulationID ,
                                MIN(RDSPK.PopulationNum) AS PopulationNum ,
                                MIN(PPL.Abbrev) AS ProductLineAbbrev ,
                                MIN(PPL.Descr) AS ProductLineDescr ,
                                PPL.ProductLineID ,
                                MIN(PPT.Abbrev) AS ProductTypeAbbrev ,
                                MIN(PPT.Descr) AS ProductTypeDescr ,
                                PPT.ProductTypeID
                       FROM     Result.MeasureDetail AS RMD
                                INNER JOIN Result.DataSetPopulationKey AS RDSPK ON RDSPK.DataRunID = RMD.DataRunID
                                                              AND RDSPK.PopulationID = RMD.PopulationID
                                INNER JOIN Result.MeasureXrefs AS MMX ON MMX.MeasureXrefID = RMD.MeasureXrefID
                                INNER JOIN Product.Payers AS PP ON PP.PayerID = RMD.PayerID
                                INNER JOIN Product.ProductTypes AS PPT ON PPT.ProductTypeID = PP.ProductTypeID
                                INNER JOIN Product.ProductLines AS PPL ON RMD.BitProductLines
                                                              & PPL.BitValue > 0
                                INNER JOIN Product.PayerProductLines AS PPPL ON PPPL.PayerID = PP.PayerID
                                                              AND PPPL.ProductLineID = PPL.ProductLineID
                       WHERE    MMX.Abbrev = 'TLM'
                                AND RMD.DataRunID = @DataRunID
                       GROUP BY RMD.PopulationID ,
                                PPL.ProductLineID ,
                                PPT.ProductTypeID
                     )
            --Grand Total
SELECT  SUM(t.CountDenominator) AS CountDenominator ,
        SUM(t.CountMembers) AS CountMembers ,
        SUM(t.CountRecords) AS CountRecords ,
        UPPER('Total') AS PopulationDescr ,
        NULL AS PopulationID ,
        NULL AS PopulationNum ,
        NULL AS ProductLineAbbrev ,
        NULL AS ProductLineDescr ,
        32767 AS ProductLineID ,
        NULL AS ProductTypeAbbrev ,
        NULL AS ProductTypeDescr ,
        32767 AS ProductTypeID ,
        1 AS SortOrder
FROM    TLMBase AS t
UNION ALL --Product Line Totals
SELECT  SUM(t.CountDenominator) AS CountDenominator ,
        SUM(t.CountMembers) AS CountMembers ,
        SUM(t.CountRecords) AS CountRecords ,
        UPPER(t.ProductLineDescr) + ' Total' AS PopulationDescr ,
        NULL AS PopulationID ,
        NULL AS PopulationNum ,
        t.ProductLineAbbrev ,
        t.ProductLineDescr ,
        t.ProductLineID ,
        NULL AS ProductTypeAbbrev ,
        NULL AS ProductTypeDescr ,
        32767 AS ProductTypeID ,
        1 AS SortOrder
FROM    TLMBase AS t
GROUP BY t.ProductLineAbbrev ,
        t.ProductLineDescr ,
        t.ProductLineID
UNION ALL --Population Totals
SELECT  SUM(t.CountDenominator) AS CountDenominator ,
        SUM(t.CountMembers) AS CountMembers ,
        SUM(t.CountRecords) AS CountRecords ,
        UPPER(t.ProductLineDescr + ', ' + t.ProductTypeAbbrev) + ' Sub Total' AS PopulationDescr ,
        NULL AS PopulationID ,
        NULL AS PopulationNum ,
        t.ProductLineAbbrev ,
        t.ProductLineDescr ,
        t.ProductLineID ,
        t.ProductTypeAbbrev ,
        t.ProductTypeDescr ,
        t.ProductTypeID ,
        1 AS SortOrder
FROM    TLMBase AS t
GROUP BY t.ProductLineAbbrev ,
        t.ProductLineDescr ,
        t.ProductLineID ,
        t.ProductTypeAbbrev ,
        t.ProductTypeDescr ,
        t.ProductTypeID
UNION ALL --Original Records
SELECT  t.CountDenominator ,
        t.CountMembers ,
        t.CountRecords ,
        t.PopulationDescr ,
        t.PopulationID ,
        t.PopulationNum ,
        t.ProductLineAbbrev ,
        t.ProductLineDescr ,
        t.ProductLineID ,
        t.ProductTypeAbbrev ,
        t.ProductTypeDescr ,
        t.ProductTypeID ,
        0 AS SortOrder
FROM    TLMBase AS t
ORDER BY ProductLineID ,
        ProductTypeID ,
        SortOrder ,
        PopulationID;

    END
GO
GRANT EXECUTE ON  [Report].[GetTLMSummaryResults] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetTLMSummaryResults] TO [Reports]
GO
