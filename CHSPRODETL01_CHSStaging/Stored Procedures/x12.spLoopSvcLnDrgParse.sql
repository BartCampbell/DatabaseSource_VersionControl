SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Parse all Entity type loops and their repeated segments: Ref
Use:

	SELECT * FROM x12.Shred
	WHERE 1=1 
		AND FileLogID = 1
		AND TransactionControlNumber IN ('000000013') -- '000000001'
		AND LoopID = '2410'
	ORDER BY TransactionControlNumber, RowID -- LoopID LoopSegment RowID

	TRUNCATE TABLE x12.LoopSvcLnDrg
	TRUNCATE TABLE x12.SegREF

	EXEC stage.spX12LoopSvcLnDrgParse
		@FileLogID = 1 -- INT
		,@Debug = 0 -- 0:None 1:Min 2:Verbose/Restricted

	SELECT * FROM x12.Shred WHERE TransactionControlNumber IN ('000000013') AND LoopID = '2410'
	SELECT * FROM x12.LoopSvcLnDrg WHERE SvcLnDrg_TransactionControlNumber IN ('000000013') -- ORDER BY SvcLnDrg_LoopID
	SELECT * FROM x12.SegREF WHERE REF_TransactionControlNumber IN ('000000013') -- ORDER BY SvcLnDrg_LoopID
		
Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
2016-11-14	Michael Vlk			- Update varchar() to actual sizes rather than default 50 
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spLoopSvcLnDrgParse] (
	@FileLogID INT 
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose
	)

AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO x12.LoopSvcLnDrg (
		SvcLnDrg_RowID
		,SvcLnDrg_RowIDParent
		,SvcLnDrg_CentauriClientID
		,SvcLnDrg_FileLogID
		,SvcLnDrg_TransactionImplementationConventionReference
		,SvcLnDrg_TransactionControlNumber
		,SvcLnDrg_LoopID

		,SvcLnDrg_AssignedIdentification_LIN01
		,SvcLnDrg_ProductServiceIDQualifier_LIN02
		,SvcLnDrg_ProductServiceID_LIN03
		,SvcLnDrg_ProductServiceIDQualifier_LIN04
		,SvcLnDrg_ProductServiceID_LIN05
		,SvcLnDrg_ProductServiceIDQualifier_LIN06
		,SvcLnDrg_ProductServiceID_LIN07
		,SvcLnDrg_ProductServiceIDQualifier_LIN08
		,SvcLnDrg_ProductServiceID_LIN09
		,SvcLnDrg_ProductServiceIDQualifier_LIN10
		,SvcLnDrg_ProductServiceID_LIN11
		,SvcLnDrg_ProductServiceIDQualifier_LIN12
		,SvcLnDrg_ProductServiceID_LIN13
		,SvcLnDrg_ProductServiceIDQualifier_LIN14
		,SvcLnDrg_ProductServiceID_LIN15
		,SvcLnDrg_ProductServiceIDQualifier_LIN16
		,SvcLnDrg_ProductServiceID_LIN17
		,SvcLnDrg_ProductServiceIDQualifier_LIN18
		,SvcLnDrg_ProductServiceID_LIN19
		,SvcLnDrg_ProductServiceIDQualifier_LIN20
		,SvcLnDrg_ProductServiceID_LIN21
		,SvcLnDrg_ProductServiceIDQualifier_LIN22
		,SvcLnDrg_ProductServiceID_LIN23
		,SvcLnDrg_ProductServiceIDQualifier_LIN24
		,SvcLnDrg_ProductServiceID_LIN25
		,SvcLnDrg_ProductServiceIDQualifier_LIN26
		,SvcLnDrg_ProductServiceID_LIN27
		,SvcLnDrg_ProductServiceIDQualifier_LIN28
		,SvcLnDrg_ProductServiceID_LIN29
		,SvcLnDrg_ProductServiceIDQualifier_LIN30
		,SvcLnDrg_ProductServiceID_LIN31

		,SvcLnDrg_ClassOfTradeCode_CTP01
		,SvcLnDrg_PriceIdentifierCode_CTP02
		,SvcLnDrg_UnitPrice_CTP03
		,SvcLnDrg_Quantity_CTP04
		,SvcLnDrg_UnitOrBasisForMeasurementCode_CTP05
		,SvcLnDrg_UnitOrBasisForMeasurementCode_CTP0501
		,SvcLnDrg_Exponent_CTP0502
		,SvcLnDrg_Multiplier_CTP0503
		,SvcLnDrg_UnitOrBasisForMeasurementCode_CTP0504
		,SvcLnDrg_Exponent_CTP0505
		,SvcLnDrg_Multiplier_CTP0506
		,SvcLnDrg_UnitOrBasisForMeasurementCode_CTP0507
		,SvcLnDrg_Exponent_CTP0508
		,SvcLnDrg_Multiplier_CTP0509
		,SvcLnDrg_UnitOrBasisForMeasurementCode_CTP0510
		,SvcLnDrg_Exponent_CTP0511
		,SvcLnDrg_Multiplier_CTP0512
		,SvcLnDrg_UnitOrBasisForMeasurementCode_CTP0513
		,SvcLnDrg_Exponent_CTP0514
		,SvcLnDrg_Multiplier_CTP0515
		,SvcLnDrg_PriceMultiplierQualifier_CTP06
		,SvcLnDrg_Multiplier_CTP07
		,SvcLnDrg_MonetaryAmount_CTP08
		,SvcLnDrg_BasisOfUnitPriceCode_CTP09
		,SvcLnDrg_ConditionValue_CTP10
		,SvcLnDrg_MultiplePriceQuantity_CTP11
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID
		-- SvcLnDrg - 2410 - LIN -DRUG IDENTIFICATION
		,h.b.value('(LIN/LIN01/text())[1]', 'varchar(20)') AS 'SvcLnDrg_AssignedIdentification_LIN01'
		,h.b.value('(LIN/LIN02/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN02'
		,h.b.value('(LIN/LIN03/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN03'
		,h.b.value('(LIN/LIN04/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN04'
		,h.b.value('(LIN/LIN05/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN05'
		,h.b.value('(LIN/LIN06/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN06'
		,h.b.value('(LIN/LIN07/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN07'
		,h.b.value('(LIN/LIN08/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN08'
		,h.b.value('(LIN/LIN09/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN09'
		,h.b.value('(LIN/LIN10/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN10'
		,h.b.value('(LIN/LIN11/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN11'
		,h.b.value('(LIN/LIN12/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN12'
		,h.b.value('(LIN/LIN13/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN13'
		,h.b.value('(LIN/LIN14/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN14'
		,h.b.value('(LIN/LIN15/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN15'
		,h.b.value('(LIN/LIN16/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN16'
		,h.b.value('(LIN/LIN17/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN17'
		,h.b.value('(LIN/LIN18/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN18'
		,h.b.value('(LIN/LIN19/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN19'
		,h.b.value('(LIN/LIN20/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN20'
		,h.b.value('(LIN/LIN21/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN21'
		,h.b.value('(LIN/LIN22/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN22'
		,h.b.value('(LIN/LIN23/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN23'
		,h.b.value('(LIN/LIN24/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN24'
		,h.b.value('(LIN/LIN25/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN25'
		,h.b.value('(LIN/LIN26/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN26'
		,h.b.value('(LIN/LIN27/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN27'
		,h.b.value('(LIN/LIN28/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN28'
		,h.b.value('(LIN/LIN29/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN29'
		,h.b.value('(LIN/LIN30/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ProductServiceIDQualifier_LIN30'
		,h.b.value('(LIN/LIN31/text())[1]', 'varchar(48)') AS 'SvcLnDrg_ProductServiceID_LIN31'
		-- SvcLnDrg - 2410 - CTP - Drug Quantity
		,h.b.value('(CTP/CTP01/text())[1]', 'varchar(2)') AS 'SvcLnDrg_ClassOfTradeCode_CTP01'
		,h.b.value('(CTP/CTP02/text())[1]', 'varchar(3)') AS 'SvcLnDrg_PriceIdentifierCode_CTP02'
		,h.b.value('(CTP/CTP03/text())[1]', 'varchar(17)') AS 'SvcLnDrg_UnitPrice_CTP03'
		,h.b.value('(CTP/CTP04/text())[1]', 'varchar(15)') AS 'SvcLnDrg_Quantity_CTP04'
		,h.b.value('(CTP/CTP05/text())[1]', 'varchar(2)') AS 'SvcLnDrg_UnitOrBasisForMeasurementCode_CTP05'
		-- SvcLnDrg - 2410 - CTP/CTP05 - COMPOSITE UNIT OF MEASURE
		,h.b.value('(CTP/CTP05/CTP0501/text())[1]', 'varchar(2)') AS 'SvcLnDrg_UnitOrBasisForMeasurementCode_CTP0501'
		,h.b.value('(CTP/CTP05/CTP0502/text())[1]', 'varchar(15)') AS 'SvcLnDrg_Exponent_CTP0502'
		,h.b.value('(CTP/CTP05/CTP0503/text())[1]', 'varchar(10)') AS 'SvcLnDrg_Multiplier_CTP0503'
		,h.b.value('(CTP/CTP05/CTP0504/text())[1]', 'varchar(2)') AS 'SvcLnDrg_UnitOrBasisForMeasurementCode_CTP0504'
		,h.b.value('(CTP/CTP05/CTP0505/text())[1]', 'varchar(15)') AS 'SvcLnDrg_Exponent_CTP0505'
		,h.b.value('(CTP/CTP05/CTP0506/text())[1]', 'varchar(10)') AS 'SvcLnDrg_Multiplier_CTP0506'
		,h.b.value('(CTP/CTP05/CTP0507/text())[1]', 'varchar(2)') AS 'SvcLnDrg_UnitOrBasisForMeasurementCode_CTP0507'
		,h.b.value('(CTP/CTP05/CTP0508/text())[1]', 'varchar(15)') AS 'SvcLnDrg_Exponent_CTP0508'
		,h.b.value('(CTP/CTP05/CTP0509/text())[1]', 'varchar(10)') AS 'SvcLnDrg_Multiplier_CTP0509'
		,h.b.value('(CTP/CTP05/CTP0510/text())[1]', 'varchar(2)') AS 'SvcLnDrg_UnitOrBasisForMeasurementCode_CTP0510'
		,h.b.value('(CTP/CTP05/CTP0511/text())[1]', 'varchar(15)') AS 'SvcLnDrg_Exponent_CTP0511'
		,h.b.value('(CTP/CTP05/CTP0512/text())[1]', 'varchar(10)') AS 'SvcLnDrg_Multiplier_CTP0512'
		,h.b.value('(CTP/CTP05/CTP0513/text())[1]', 'varchar(2)') AS 'SvcLnDrg_UnitOrBasisForMeasurementCode_CTP0513'
		,h.b.value('(CTP/CTP05/CTP0514/text())[1]', 'varchar(15)') AS 'SvcLnDrg_Exponent_CTP0514'
		,h.b.value('(CTP/CTP05/CTP0515/text())[1]', 'varchar(10)') AS 'SvcLnDrg_Multiplier_CTP0515'
		,h.b.value('(CTP/CTP06/text())[1]', 'varchar(3)') AS 'SvcLnDrg_PriceMultiplierQualifier_CTP06'
		,h.b.value('(CTP/CTP07/text())[1]', 'varchar(10)') AS 'SvcLnDrg_Multiplier_CTP07'
		,h.b.value('(CTP/CTP08/text())[1]', 'varchar(18)') AS 'SvcLnDrg_MonetaryAmount_CTP08'
		,h.b.value('(CTP/CTP09/text())[1]', 'varchar(2)') AS 'SvcLnDrg_BasisOfUnitPriceCode_CTP09'
		,h.b.value('(CTP/CTP10/text())[1]', 'varchar(10)') AS 'SvcLnDrg_ConditionValue_CTP10'
		,h.b.value('(CTP/CTP11/text())[1]', 'varchar(2)') AS 'SvcLnDrg_MultiplePriceQuantity_CTP11'
	FROM 
		x12.shred x
	OUTER APPLY 
		x.LoopXML.nodes('Loop') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2410'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- REF

	INSERT INTO x12.SegREF (
		Ref_RowID
		,Ref_RowIDParent
		,REF_CentauriClientID
		,Ref_FileLogID
		,Ref_TransactionImplementationConventionReference
		,Ref_TransactionControlNumber
		,Ref_LoopID
		,Ref_ReferenceIdentificationQualifier_REF01
		,Ref_ReferenceIdentification_REF02
		,Ref_Description_REF03
		,Ref_ReferenceIdentifier_REF04
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(REF01/text())[1]', 'varchar(3)') AS 'REF_ReferenceIdentificationQualifier_REF01'
		,h.b.value('(REF02/text())[1]', 'varchar(50)') AS 'REF_ReferenceIdentification_REF02'
		,h.b.value('(REF03/text())[1]', 'varchar(80)') AS 'REF_Description_REF03'
		,h.b.value('(REF04/text())[1]', 'varchar(1)') AS 'REF_ReferenceIdentifier_REF04'
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/REF') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2410'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

END -- Procedure
GO
