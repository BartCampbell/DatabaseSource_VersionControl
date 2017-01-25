SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	prCreateProcedureCodeBETOS
Author:		Leon Dowling
Copyright:	© 2016
Date:		2016.10.24
Purpose:	
Parameters: 
Depends On:	
Calls:		
Called By:	
Returns:	None
Notes:		
Update Log:

Test Script: 

*/

--/*
CREATE PROC [dbo].[prCreateProcedureCodeBETOS]

	@iLoadInstanceID INT = 1,
	@bDebug BIT = 0

AS
--*/
/*--------------------------------
DECLARE @iLoadInstanceID INT = 1,
	@bDebug BIT = 1

--*/------------------------------


DECLARE @vcCmd VARCHAR(8000),
	@vcCmd2 VARCHAR(8000),
	@nvCmd NVARCHAR(4000),
	@nvCmd2 NVARCHAR(4000),
	@i INT



-- only pull BETOS data with the last code_set_version for every betos_cd

IF OBJECT_ID('tempdb..#betos') IS NOT NULL
	DROP TABLE #betos

SELECT a.*
	INTO #betos
	FROM IMICodeStore..BETOS a
		INNER JOIN (SELECT betos_cd, MAX(code_set_version) code_set_version
						FROM IMICodeStore..BETOS b
						GROUP BY BETOS_CD) b
			ON a.BETOS_CD = b.BETOS_CD		
			AND a.CODE_SET_VERSION = b.code_set_version	


-- add a rowid to IMICodeStore..BETOS_2_HCPCS_Crosswalk	
IF OBJECT_ID('tempdb..#BETOS_2_HCPCS_Crosswalk') IS NOT NULL
	DROP TABLE #BETOS_2_HCPCS_Crosswalk	

SELECT *, 
	rowid = IDENTITY(INT,1,1)
INTO #BETOS_2_HCPCS_Crosswalk	
FROM IMICodeStore..BETOS_2_HCPCS_Crosswalk	
ORDER BY CODE_SET_VERSION


-- First pull records that have a character in the 5th position

IF OBJECT_ID('tempdb..#hcpcs') IS NOT NULL 
	DROP TABLE #hcpcs 

SELECT a.hcpcs_cd,
		hcpcs_section,
		hcpcs_subsection ,
		rowid = IDENTITY(INT,1,1)
	INTO #hcpcs
	FROM #BETOS_2_HCPCS_Crosswalk a
		-- filter #betow_2_hcpcs_cross to last row for each hcpcs_cd
		INNER JOIN (SELECT hcpcs_cd, rowid = MAX(rowid) 
					FROM #BETOS_2_HCPCS_Crosswalk	
					GROUP BY hcpcs_cd) B
			ON a.hcpcs_cd = b.hcpcs_cd
			AND a.rowid = b.rowid
		INNER JOIN IMICodeStore.dbo.HCPCS_Header c 
			ON LEFT(a.hcpcs_cd,4) BETWEEN LEFT(c.HCPCS_STARTCODE,4)
											AND LEFT(c.HCPCS_ENDCODE,4)
			AND RIGHT(a.hcpcs_cd,1) = RIGHT(c.HCPCS_STARTCODE,1)
			AND RIGHT(a.hcpcs_cd,1) = RIGHT(c.HCPCS_ENDCODE,1)											
	WHERE RIGHT(HCPCS_STARTCODE,1) NOT BETWEEN '0' and '9' 
			AND RIGHT(HCPCS_ENDCODE,1) NOT BETWEEN '0' and '9' 
			
-- now add records that do not hvae a character in the 5th position
INSERT INTO #hcpcs
SELECT DISTINCT a.hcpcs_cd,
		hcpcs_section,
		hcpcs_subsection 
--select a.*		
	FROM #BETOS_2_HCPCS_Crosswalk a
		INNER JOIN (SELECT hcpcs_cd, rowid = MAX(rowid) --code_set_version = MAX(code_set_version)
					FROM #BETOS_2_HCPCS_Crosswalk		
					GROUP BY hcpcs_cd) B
			ON a.hcpcs_cd = b.hcpcs_cd
			AND a.rowid = b.rowid
			--AND a.code_set_version = b.code_set_version
		INNER JOIN IMICodeStore.dbo.HCPCS_Header c 
			ON a.hcpcs_cd BETWEEN c.HCPCS_STARTCODE
								AND c.HCPCS_ENDCODE
	WHERE RIGHT(HCPCS_STARTCODE,1) BETWEEN '0' and '9' 
			AND RIGHT(HCPCS_ENDCODE,1) BETWEEN '0' and '9' 

-- Delete duplicates				
DELETE a
FROM #hcpcs a
	LEFT JOIN (SELECT hcpcs_cd, MAX(rowid) rowid
				FROM #hcpcs
				GROUP BY hcpcs_cd
				) b
		ON a.hcpcs_cd = b.hcpcs_cd
		AND a.rowid = b.rowid
WHERE b.hcpcs_cd IS NULL
					

IF OBJECT_ID('ProcedureCodeBETOS') IS NOT NULL 
	DROP TABLE ProcedureCodeBETOS

SELECT ProcedureCode = a.hcpcs_cd,
		a.HCPCS_CD,
		a.BETOS_CD,
		c.betos_category_cd,
		c.betos_category_desc,
		c.betos_desc,
		hcpc_section = ISNULL(d.hcpcs_section,''),
		hcpc_subsection = ISNULL(d.hcpcs_subsection,'')
	INTO ProcedureCodeBETOS
	FROM IMICodeStore..BETOS_2_HCPCS_Crosswalk a
		INNER JOIN (SELECT hcpcs_cd, code_set_version = MAX(code_set_version)
					FROM IMICodeStore..BETOS_2_HCPCS_Crosswalk	
					GROUP BY hcpcs_cd) B
			ON a.hcpcs_cd = b.hcpcs_cd
			AND a.code_set_version = b.code_set_version
		INNER JOIN #betos c
			ON a.BETOS_CD = c.BETOS_CD			
		LEFT JOIN #hcpcs d
			ON a.HCPCS_CD = d.hcpcs_cd			

GO
