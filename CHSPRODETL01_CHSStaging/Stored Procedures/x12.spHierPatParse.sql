SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Parse the 2000C - PATIENT HIERARCHICAL LOOP
Use:

	SELECT * FROM x12.Shred
	WHERE 1=1 
		AND FileLogID = 1
		--AND TransactionControlNumber IN ('000000013') -- '000000001'
		AND LoopID = '2000C'
	ORDER BY TransactionControlNumber, RowID -- LoopID LoopSegment RowID

	TRUNCATE TABLE x12.HierPat

	EXEC x12.spHierPatParse
		@FileLogID = 1 -- INT
		,@Debug = 0 -- 0:None 1:Min 2:Verbose/Restricted

	SELECT * FROM x12.Shred WHERE LoopID = '2000C' AND TransactionControlNumber IN ('0003') 
	SELECT * FROM x12.HierPat WHERE HierPat_TransactionControlNumber IN ('0003') 
		
Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
2016-11-14	Michael Vlk			- Update varchar() to actual sizes rather than default 50 
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spHierPatParse] (
	@FileLogID INT 
	,@Debug INT = 0 -- 0:None 1:Min 2:Verbose
	)

AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO x12.HierPat (
		HierPat_RowID
		,HierPat_RowIDParent
		,HierPat_CentauriClientID
		,HierPat_FileLogID
		,HierPat_TransactionImplementationConventionReference
		,HierPat_TransactionControlNumber
		,HierPat_LoopID

		,HierPat_HierarchicalIDNumber_HL01
		,HierPat_HierarchicalParentIDNumber_HL02
		,HierPat_HierarchicalLevelCode_HL03
		,HierPat_HierarchicalChildCode_HL04

		,HierPat_IndividualRelationshipCode_PAT01
		,HierPat_PatientLocationCode_PAT02
		,HierPat_EmploymentStatusCode_PAT03
		,HierPat_StudentStatusCode_PAT04
		,HierPat_DateTimePeriodFormatQualifier_PAT05
		,HierPat_DateTimePeriod_PAT06
		,HierPat_UnitOrBasisforMeasurementCode_PAT07
		,HierPat_Weight_PAT08
		,HierPat_YesNoConditionOrResponseCode_PAT09
		)
	SELECT
		x.RowID
		,x.RowIDParent
		,x.CentauriClientID
		,x.FileLogID
		,x.TransactionImplementationConventionReference
		,x.TransactionControlNumber
		,x.LoopID
		-- 2000C - HL - PATIENT HIERARCHICAL LEVEL
		,h.b.value('(HL/HL01/text())[1]', 'varchar(12)') AS 'HierPat_HierarchicalIDNumber_HL01'
		,h.b.value('(HL/HL02/text())[1]', 'varchar(12)') AS 'HierPat_HierarchicalParentIDNumber_HL02'
		,h.b.value('(HL/HL03/text())[1]', 'varchar(2)') AS 'HierPat_HierarchicalLevelCode_HL03'
		,h.b.value('(HL/HL04/text())[1]', 'varchar(1)') AS 'HierPat_HierarchicalChildCode_HL04'
		-- 2000C - PAT- PATIENT INFORMATION
		,h.b.value('(PAT/PAT01/text())[1]', 'varchar(2)') AS 'HierPat_IndividualRelationshipCode_PAT01'
		,h.b.value('(PAT/PAT02/text())[1]', 'varchar(1)') AS 'HierPat_PatientLocationCode_PAT02'
		,h.b.value('(PAT/PAT03/text())[1]', 'varchar(2)') AS 'HierPat_EmploymentStatusCode_PAT03'
		,h.b.value('(PAT/PAT04/text())[1]', 'varchar(1)') AS 'HierPat_StudentStatusCode_PAT04'
		,h.b.value('(PAT/PAT05/text())[1]', 'varchar(3)') AS 'HierPat_DateTimePeriodFormatQualifier_PAT05'
		,h.b.value('(PAT/PAT06/text())[1]', 'varchar(35)') AS 'HierPat_DateTimePeriod_PAT06'
		,h.b.value('(PAT/PAT07/text())[1]', 'varchar(2)') AS 'HierPat_UnitOrBasisforMeasurementCode_PAT07'
		,h.b.value('(PAT/PAT08/text())[1]', 'varchar(10)') AS 'HierPat_Weight_PAT08'
		,h.b.value('(PAT/PAT09/text())[1]', 'varchar(1)') AS 'HierPat_Yes/NoConditionOrResponseCode_PAT09'
	FROM 
		x12.shred x
	OUTER APPLY 
		x.LoopXML.nodes('HierarchicalLoop') AS h(b)
	WHERE 1=1
		AND x.FileLogID = @FileLogID
		AND x.LoopID = '2000C'
		-- Test Only Below
			AND (@Debug < 2 OR (@Debug >= 2 AND x.TransactionControlNumber IN ('000000001')))
			--ORDER BY x.FileLogID, x.TransactionControlNumber

END -- Procedure
GO
