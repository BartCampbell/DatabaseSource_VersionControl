SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Parse the 2400 Service Line Number loops and their repeated segments.
Use:

	SELECT * FROM x12.Shred
	WHERE 1=1 
		AND FileLogID = 1
		AND TransactionControlNumber IN ('000000003') -- 000000001 000000003 000002175
		AND LoopID = '2400'
	ORDER BY TransactionControlNumber, RowID -- LoopID LoopSegment RowID

	TRUNCATE TABLE x12.LoopSvcLnAdj
		TRUNCATE TABLE x12.SegCAS
		TRUNCATE TABLE x12.SegDTP
		TRUNCATE TABLE x12.SegAMT	

	EXEC x12.spLoopSvcLnAdjParse
		@FileLogID = 1 -- INT
		,@Debug = 0 -- 0:None 1:Min 2:Verbose/Restricted

	SELECT * FROM x12.Shred WHERE TransactionControlNumber IN ('000002175') AND LoopID = '2430'
	SELECT * FROM x12.LoopSvcLnAdj WHERE SvcLnAdj_TransactionControlNumber IN ('000002175') ORDER BY SvcLnAdj_LoopID
		SELECT * FROM x12.SegCAS WHERE CAS_TransactionControlNumber IN ('000002277') ORDER BY CAS_LoopID
		SELECT * FROM x12.SegDTP WHERE DTP_TransactionControlNumber IN ('000002175') ORDER BY DTP_LoopID
		SELECT * FROM x12.SegAMT WHERE AMT_TransactionControlNumber IN ('000002175') ORDER BY AMT_LoopID

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
2016-11-14	Michael Vlk			- Update varchar() to actual sizes rather than default 50 
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spLoopSvcLnAdjParse] (
	@FileLogID INT 
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose
	)

AS
BEGIN
	SET NOCOUNT ON;

INSERT INTO x12.LoopSvcLnAdj (
		SvcLnAdj_RowID
		,SvcLnAdj_RowIDParent
		,SvcLnAdj_CentauriClientID
		,SvcLnAdj_FileLogID
		,SvcLnAdj_TransactionImplementationConventionReference
		,SvcLnAdj_TransactionControlNumber
		,SvcLnAdj_LoopID
		,SvcLnAdj_IdentificationCode_SVD01
		,SvcLnAdj_MonetaryAmount_SVD02
		,SvcLnAdj_ProductServiceIDQualifier_SVD0301
		,SvcLnAdj_ProductServiceID_SVD0302
		,SvcLnAdj_ProcedureModifier_SVD0303
		,SvcLnAdj_ProcedureModifier_SVD0304
		,SvcLnAdj_ProcedureModifier_SVD0305
		,SvcLnAdj_ProcedureModifier_SVD0306
		,SvcLnAdj_Description_SVD0307
		,SvcLnAdj_ProductServiceID_SVD0308
		,SvcLnAdj_ProductServiceID_SVD04
		,SvcLnAdj_Quantity_SVD05
		,SvcLnAdj_AssignedNumber_SVD06
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID
		-- SvcLnAdj - 2430 - LINE ADJUDICATION INFORMATION
		,h.b.value('(SVD/SVD01/text())[1]', 'varchar(80)') AS 'SvcLnAdj_IdentificationCode_SVD01'
		,h.b.value('(SVD/SVD02/text())[1]', 'varchar(18)') AS 'SvcLnAdj_MonetaryAmount_SVD02'
		-- SvcLnAdj - 2430 - SVD/SVD03
		,h.b.value('(SVD/SVD03/SVD0301/text())[1]', 'varchar(2)') AS 'SvcLnAdj_ProductServiceIDQualifier_SVD0301'
		,h.b.value('(SVD/SVD03/SVD0302/text())[1]', 'varchar(48)') AS 'SvcLnAdj_ProductServiceID_SVD0302'
		,h.b.value('(SVD/SVD03/SVD0303/text())[1]', 'varchar(2)') AS 'SvcLnAdj_ProcedureModifier_SVD0303'
		,h.b.value('(SVD/SVD03/SVD0304/text())[1]', 'varchar(2)') AS 'SvcLnAdj_ProcedureModifier_SVD0304'
		,h.b.value('(SVD/SVD03/SVD0305/text())[1]', 'varchar(2)') AS 'SvcLnAdj_ProcedureModifier_SVD0305'
		,h.b.value('(SVD/SVD03/SVD0306/text())[1]', 'varchar(2)') AS 'SvcLnAdj_ProcedureModifier_SVD0306'
		,h.b.value('(SVD/SVD03/SVD0307/text())[1]', 'varchar(80)') AS 'SvcLnAdj_Description_SVD0307'
		,h.b.value('(SVD/SVD03/SVD0308/text())[1]', 'varchar(48)') AS 'SvcLnAdj_ProductServiceID_SVD0308'
		,h.b.value('(SVD/SVD04/text())[1]', 'varchar(48)') AS 'SvcLnAdj_ProductServiceID_SVD04'
		,h.b.value('(SVD/SVD05/text())[1]', 'varchar(15)') AS 'SvcLnAdj_Quantity_SVD05'
		,h.b.value('(SVD/SVD06/text())[1]', 'varchar(6)') AS 'SvcLnAdj_AssignedNumber_SVD06'
	FROM 
		x12.shred x
	OUTER APPLY 
		x.LoopXML.nodes('Loop') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2430'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- CAS

	INSERT INTO x12.SegCAS (
		CAS_RowID
		,CAS_RowIDParent
		,CAS_CentauriClientID
		,CAS_FileLogID
		,CAS_TransactionImplementationConventionReference
		,CAS_TransactionControlNumber
		,CAS_LoopID

		,CAS_ClaimAdjustmentGroupCode_CAS01
		,CAS_ClaimAdjustmentReasonCode_CAS02
		,CAS_MonetaryAmount_CAS03
		,CAS_Quantity_CAS04
		,CAS_ClaimAdjustmentReasonCode_CAS05
		,CAS_MonetaryAmount_CAS06
		,CAS_Quantity_CAS07
		,CAS_ClaimAdjustmentReasonCode_CAS08
		,CAS_MonetaryAmount_CAS09
		,CAS_Quantity_CAS10
		,CAS_ClaimAdjustmentReasonCode_CAS11
		,CAS_MonetaryAmount_CAS12
		,CAS_Quantity_CAS13
		,CAS_ClaimAdjustmentReasonCode_CAS14
		,CAS_MonetaryAmount_CAS15
		,CAS_Quantity_CAS16
		,CAS_ClaimAdjustmentReasonCode_CAS17
		,CAS_MonetaryAmount_CAS18
		,CAS_Quantity_CAS19
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(CAS01/text())[1]', 'varchar(2)') AS 'CAS_ClaimAdjustmentGroupCode_CAS01'
		,h.b.value('(CAS02/text())[1]', 'varchar(5)') AS 'CAS_ClaimAdjustmentReasonCode_CAS02'
		,h.b.value('(CAS03/text())[1]', 'varchar(18)') AS 'CAS_MonetaryAmount_CAS03'
		,h.b.value('(CAS04/text())[1]', 'varchar(15)') AS 'CAS_Quantity_CAS04'
		,h.b.value('(CAS05/text())[1]', 'varchar(5)') AS 'CAS_ClaimAdjustmentReasonCode_CAS05'
		,h.b.value('(CAS06/text())[1]', 'varchar(18)') AS 'CAS_MonetaryAmount_CAS06'
		,h.b.value('(CAS07/text())[1]', 'varchar(15)') AS 'CAS_Quantity_CAS07'
		,h.b.value('(CAS08/text())[1]', 'varchar(5)') AS 'CAS_ClaimAdjustmentReasonCode_CAS08'
		,h.b.value('(CAS09/text())[1]', 'varchar(18)') AS 'CAS_MonetaryAmount_CAS09'
		,h.b.value('(CAS10/text())[1]', 'varchar(15)') AS 'CAS_Quantity_CAS10'
		,h.b.value('(CAS11/text())[1]', 'varchar(5)') AS 'CAS_ClaimAdjustmentReasonCode_CAS11'
		,h.b.value('(CAS12/text())[1]', 'varchar(18)') AS 'CAS_MonetaryAmount_CAS12'
		,h.b.value('(CAS13/text())[1]', 'varchar(15)') AS 'CAS_Quantity_CAS13'
		,h.b.value('(CAS14/text())[1]', 'varchar(5)') AS 'CAS_ClaimAdjustmentReasonCode_CAS14'
		,h.b.value('(CAS15/text())[1]', 'varchar(18)') AS 'CAS_MonetaryAmount_CAS15'
		,h.b.value('(CAS16/text())[1]', 'varchar(15)') AS 'CAS_Quantity_CAS16'
		,h.b.value('(CAS17/text())[1]', 'varchar(5)') AS 'CAS_ClaimAdjustmentReasonCode_CAS17'
		,h.b.value('(CAS18/text())[1]', 'varchar(18)') AS 'CAS_MonetaryAmount_CAS18'
		,h.b.value('(CAS19/text())[1]', 'varchar(15)') AS 'CAS_Quantity_CAS19'
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/CAS') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2430'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- DTP

	INSERT INTO x12.SegDTP (
		DTP_RowID
		,DTP_RowIDParent
		,DTP_CentauriClientID
		,DTP_FileLogID
		,DTP_TransactionImplementationConventionReference
		,DTP_TransactionControlNumber
		,DTP_LoopID

		,DTP_DateTimeQualifier_DTP01
		,DTP_DateTimePeriodFormatQualifier_DTP02
		,DTP_DateTimePeriod_DTP03
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(DTP01/text())[1]', 'varchar(3)') AS DTP_DateTimeQualifier_DTP01
		,h.b.value('(DTP02/text())[1]', 'varchar(3)') AS DTP_DateTimePeriodFormatQualifier_DTP02
		,h.b.value('(DTP03/text())[1]', 'varchar(35)') AS DTP_DateTimePeriod_DTP03
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/DTP') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2430'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

	-- AMT - CLAIM SUPPLEMENTAL INFORMATION 

	INSERT INTO x12.SegAMT (
		AMT_RowID
		,AMT_RowIDParent
		,AMT_CentauriClientID
		,AMT_FileLogID
		,AMT_TransactionImplementationConventionReference
		,AMT_TransactionControlNumber
		,AMT_LoopID

		,AMT_AmountQualifierCode_AMT01
		,AMT_MonetaryAmount_AMT02
		,AMT_CreditDebitFlagCode_AMT03
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID		

		,h.b.value('(AMT01/text())[1]', 'varchar(3)') AS 'AMT_AmountQualifierCode_AMT01'
		,h.b.value('(AMT02/text())[1]', 'varchar(18)') AS 'AMT_MonetaryAmount_AMT02'
		,h.b.value('(AMT03/text())[1]', 'varchar(1)') AS 'AMT_CreditDebitFlagCode_AMT03'
	FROM 
		x12.shred x
	CROSS APPLY 
		x.LoopXML.nodes('Loop/AMT') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2430'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

END -- Procedure
GO
