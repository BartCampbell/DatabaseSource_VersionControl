SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Report].[GetPayerList]
AS
    BEGIN
        WITH    PayerProductLines
                  AS ( SELECT   SUM(PPL.BitValue) AS BitProductLines ,
                                PPPL.PayerID
                       FROM     Product.PayerProductLines AS PPPL
                                INNER JOIN Product.ProductLines AS PPL ON PPPL.ProductLineID = PPL.ProductLineID
                       GROUP BY PayerID
                     )
            SELECT  PP.PayerID AS [Payer ID] ,
                    PP.Abbrev AS [Payer] ,
                    PP.Descr AS [Payer Description] ,
                    PPT.Descr AS [Product Type] ,
                    PPC.Descr AS [Product Class] ,
                    REPLACE(Product.ConvertBitProductLinesToDescrs(PPL.BitProductLines),
                            ' :: ', '/') AS [Product Lines]
            FROM    Product.Payers AS PP
                    LEFT OUTER JOIN PayerProductLines AS PPL ON PP.PayerID = PPL.PayerID
                    INNER JOIN Product.ProductTypes AS PPT ON PP.ProductTypeID = PPT.ProductTypeID
                    INNER JOIN Product.ProductClasses AS PPC ON PPT.ProductClassID = PPC.ProductClassID
    END
GO
GRANT EXECUTE ON  [Report].[GetPayerList] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetPayerList] TO [Reports]
GO
