SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Truncate all X12 Parse Tables
Use:

	EXEC x12.spParseTableTruncate

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spParseTableTruncate]

AS
BEGIN
	SET NOCOUNT ON;

	TRUNCATE TABLE x12.TR;
	TRUNCATE TABLE x12.HierPrv;
	TRUNCATE TABLE x12.HierSbr;
	TRUNCATE TABLE x12.HierPat;
	TRUNCATE TABLE x12.LoopClaim;
	TRUNCATE TABLE x12.LoopEntity;
	TRUNCATE TABLE x12.LoopFormIdent;
	TRUNCATE TABLE x12.LoopOthSubInfo;
	TRUNCATE TABLE x12.LoopSvcLn;
	TRUNCATE TABLE x12.LoopSvcLnAdj;
	TRUNCATE TABLE x12.LoopSvcLnDrg;
	TRUNCATE TABLE x12.SegAMT;
	TRUNCATE TABLE x12.SegCAS;
	TRUNCATE TABLE x12.SegCRC;
	TRUNCATE TABLE x12.SegDTP;
	TRUNCATE TABLE x12.SegFRM;
	TRUNCATE TABLE x12.SegHI;
	TRUNCATE TABLE x12.SegK3;
	TRUNCATE TABLE x12.SegMEA;
	TRUNCATE TABLE x12.SegNTE;
	TRUNCATE TABLE x12.SegPER;
	TRUNCATE TABLE x12.SegPWK;
	TRUNCATE TABLE x12.SegQTY;
	TRUNCATE TABLE x12.SegREF;
	TRUNCATE TABLE x12.SegTOO;

END -- Procedure
GO
