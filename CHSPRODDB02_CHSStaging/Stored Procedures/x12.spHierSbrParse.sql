SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Parse the 2000B - SUBSCRIBER HIERARCHICAL LEVEL
Use:

	SELECT * FROM x12.Shred
	WHERE 1=1 
		AND FileLogID = 1
		AND TransactionControlNumber IN ('000000013') -- '000000001'
		AND LoopID = '2000A'
	ORDER BY TransactionControlNumber, RowID -- LoopID LoopSegment RowID

	TRUNCATE TABLE x12.HierSbr

	EXEC x12.spHierSbrParse
		@FileLogID = 1 -- INT
		,@Debug = 0 -- 0:None 1:Min 2:Verbose/Restricted

	SELECT * FROM x12.Shred WHERE LoopID = '2000B' AND TransactionControlNumber IN ('0003') 
	SELECT * FROM x12.HierSbr WHERE HierSbr_TransactionControlNumber IN ('0003') 
		
Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
2016-11-14	Michael Vlk			- Update varchar() to actual sizes rather than default 50 
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spHierSbrParse] (
	@FileLogID INT 
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose
	)

AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO x12.HierSbr (
		HierSbr_RowID
		,HierSbr_RowIDParent
		,HierSbr_CentauriClientID
		,HierSbr_FileLogID
		,HierSbr_TransactionImplementationConventionReference
		,HierSbr_TransactionControlNumber
		,HierSbr_LoopID

		,HierSbr_HierarchicalIDNumber_HL01
		,HierSbr_HierarchicalParentIDNumber_HL02
		,HierSbr_HierarchicalLevelCode_HL03
		,HierSbr_HierarchicalChildCode_HL04

		,HierSbr_PayerResponsibilitySequenceNumberCode_SBR01
		,HierSbr_IndividualRelationshipCode_SBR02
		,HierSbr_ReferenceIdentification_SBR03
		,HierSbr_Name_SBR04
		,HierSbr_InsuranceTypeCode_SBR05
		,HierSbr_CoordinationOfBenefitsCode_SBR06
		,HierSbr_YesNoConditionOrResponseCode_SBR07
		,HierSbr_EmploymentStatusCode_SBR08
		,HierSbr_ClaimFilingIndicatorCode_SBR09

		,HierSbr_IndividualRelationshipCode_PAT01
		,HierSbr_PatientLocationCode_PAT02
		,HierSbr_EmploymentStatusCode_PAT03
		,HierSbr_StudentStatusCode_PAT04
		,HierSbr_DateTimePeriodFormatQualifier_PAT05
		,HierSbr_DateImePeriod_PAT06
		,HierSbr_UnitOrBasisForMeasurementCode_PAT07
		,HierSbr_Weight_PAT08
		,HierSbr_YesNoConditionOrResponseCode_PAT09
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID
		-- 2000B - HL - SUBSCRIBER HIERARCHICAL LEVEL
		,h.b.value('(HL/HL01/text())[1]', 'varchar(12)') AS 'HeirSubsciber_HierarchicalIDNumber_HL01'
		,h.b.value('(HL/HL02/text())[1]', 'varchar(12)') AS 'HeirSubsciber_HierarchicalParentIDNumber_HL02'
		,h.b.value('(HL/HL03/text())[1]', 'varchar(2)') AS 'HeirSubsciber_HierarchicalLevelCode_HL03'
		,h.b.value('(HL/HL04/text())[1]', 'varchar(1)') AS 'HeirSubsciber_HierarchicalChildCode_HL04'
		-- 2000B - SBR - Subscriber Information
		,h.b.value('(SBR/SBR01/text())[1]', 'varchar(1)') AS 'HeirSubsciber_PayerResponsibilitySequenceNumberCode_SBR01'
		,h.b.value('(SBR/SBR02/text())[1]', 'varchar(2)') AS 'HeirSubsciber_IndividualRelationshipCode_SBR02'
		,h.b.value('(SBR/SBR03/text())[1]', 'varchar(50)') AS 'HeirSubsciber_ReferenceIdentification_SBR03'
		,h.b.value('(SBR/SBR04/text())[1]', 'varchar(60)') AS 'HeirSubsciber_Name_SBR04'
		,h.b.value('(SBR/SBR05/text())[1]', 'varchar(3)') AS 'HeirSubsciber_InsuranceTypeCode_SBR05'
		,h.b.value('(SBR/SBR06/text())[1]', 'varchar(1)') AS 'HeirSubsciber_CoordinationOfBenefitsCode_SBR06'
		,h.b.value('(SBR/SBR07/text())[1]', 'varchar(1)') AS 'HeirSubsciber_YesNoConditionOrResponseCode_SBR07'
		,h.b.value('(SBR/SBR08/text())[1]', 'varchar(2)') AS 'HeirSubsciber_EmploymentStatusCode_SBR08'
		,h.b.value('(SBR/SBR09/text())[1]', 'varchar(2)') AS 'HeirSubsciber_ClaimFilingIndicatorCode_SBR09'
		-- 2000B - PAT- PATIENT INFORMATION
		,h.b.value('(PAT/PAT01/text())[1]', 'varchar(2)') AS 'HeirSubsciber_IndividualRelationshipCode_PAT01'
		,h.b.value('(PAT/PAT02/text())[1]', 'varchar(1)') AS 'HeirSubsciber_PatientLocationCode_PAT02'
		,h.b.value('(PAT/PAT03/text())[1]', 'varchar(2)') AS 'HeirSubsciber_EmploymentStatusCode_PAT03'
		,h.b.value('(PAT/PAT04/text())[1]', 'varchar(1)') AS 'HeirSubsciber_StudentStatusCode_PAT04'
		,h.b.value('(PAT/PAT05/text())[1]', 'varchar(3)') AS 'HeirSubsciber_DateTimePeriodFormatQualifier_PAT05'
		,h.b.value('(PAT/PAT06/text())[1]', 'varchar(35)') AS 'HeirSubsciber_DateImePeriod_PAT06'
		,h.b.value('(PAT/PAT07/text())[1]', 'varchar(2)') AS 'HeirSubsciber_UnitOrBasisForMeasurementCode_PAT07'
		,h.b.value('(PAT/PAT08/text())[1]', 'varchar(10)') AS 'HeirSubsciber_Weight_PAT08'
		,h.b.value('(PAT/PAT09/text())[1]', 'varchar(1)') AS 'HeirSubsciber_YesNoConditionOrResponseCode_PAT09'
	FROM 
		x12.shred x
	OUTER APPLY 
		x.LoopXML.nodes('HierarchicalLoop') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2000B'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

END -- Procedure
GO
