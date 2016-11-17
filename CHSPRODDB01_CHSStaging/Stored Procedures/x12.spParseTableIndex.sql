SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Index all X12 Parse Tables
Use:

EXEC x12.spParseTableIndex
	@Drop = 0 -- 0:CREATE, 1:DROP
	,@Mod = NULL -- NULL for actual table, send mod such as 'z' to alter copies with same prefix. E.g. X12TR vs zX12TR
	,@Debug = 0 -- 0 to EXEC, 1 to PRINT only

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spParseTableIndex] (
	@Drop INT = 0
	,@Mod VARCHAR(10) = NULL
	,@Debug INT = 0
	)

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@SQLString NVARCHAR(MAX)
		,@TableName VARCHAR(50) --= 'zX12TR'
		,@TablePrefix VARCHAR(50) --= 'TR'
		,@ListID INT
	
	DECLARE @ParseTableList TABLE (ListID INT,TableName VARCHAR(50),TablePrefix VARCHAR(50))
	INSERT INTO @ParseTableList VALUES(1,'TR','TR');
	INSERT INTO @ParseTableList VALUES(2,'HierPrv','HierPrv');
	INSERT INTO @ParseTableList VALUES(3,'HierSbr','HierSbr');
	INSERT INTO @ParseTableList VALUES(4,'HierPat','HierPat');
	INSERT INTO @ParseTableList VALUES(5,'LoopClaim','Claim');
	INSERT INTO @ParseTableList VALUES(6,'LoopEntity','Entity');
	INSERT INTO @ParseTableList VALUES(7,'LoopFormIdent','FormIdent');
	INSERT INTO @ParseTableList VALUES(8,'LoopOthSubInfo','OthSubInfo');
	INSERT INTO @ParseTableList VALUES(9,'LoopSvcLn','SvcLn');
	INSERT INTO @ParseTableList VALUES(10,'LoopSvcLnAdj','SvcLnAdj');
	INSERT INTO @ParseTableList VALUES(11,'LoopSvcLnDrg','SvcLnDrg');
	INSERT INTO @ParseTableList VALUES(12,'SegAMT','AMT');
	INSERT INTO @ParseTableList VALUES(13,'SegCAS','CAS');
	INSERT INTO @ParseTableList VALUES(14,'SegCRC','CRC');
	INSERT INTO @ParseTableList VALUES(15,'SegDTP','DTP');
	INSERT INTO @ParseTableList VALUES(16,'SegFRM','FRM');
	INSERT INTO @ParseTableList VALUES(17,'SegHI','HI');
	INSERT INTO @ParseTableList VALUES(18,'SegK3','K3');
	INSERT INTO @ParseTableList VALUES(19,'SegMEA','MEA');
	INSERT INTO @ParseTableList VALUES(20,'SegNTE','NTE');
	INSERT INTO @ParseTableList VALUES(21,'SegPER','PER');
	INSERT INTO @ParseTableList VALUES(22,'SegPWK','PWK');
	INSERT INTO @ParseTableList VALUES(23,'SegQTY','QTY');
	INSERT INTO @ParseTableList VALUES(24,'SegREF','REF');
	INSERT INTO @ParseTableList VALUES(25,'SegTOO','TOO');

	IF @Mod IS NOT NULL
		UPDATE @ParseTableList SET TableName = @Mod + TableName;
	
	SELECT @ListID = MIN(ListID) FROM @ParseTableList

	WHILE @ListID IS NOT NULL
	BEGIN
		SELECT @TableName = TableName, @TablePrefix = TablePrefix FROM @ParseTableList WHERE ListID = @ListID

		IF @Drop = 1
			SET @SQLString = '
				DROP INDEX pk_' + @TableName + '_RowID ON x12.' + @TableName + ';
				DROP INDEX idx_' + @TableName + '_RowIDParent ON x12.' + @TableName + ';
				DROP INDEX idx_' + @TableName + '_CentauriClientID ON x12.' + @TableName + ';
				DROP INDEX idx_' + @TableName + '_FileLogID ON x12.' + @TableName + ';
				DROP INDEX idx_' + @TableName + '_TransactionImplementationConventionReference ON x12.' + @TableName + ';
				DROP INDEX idx_' + @TableName + '_TransactionControlNumber ON x12.' + @TableName + ';
				DROP INDEX idx_' + @TableName + '_LoopID ON x12.' + @TableName + ';
			';
		ELSE
			SET @SQLString = '
				CREATE CLUSTERED INDEX pk_' + @TableName + '_RowID ON x12.' + @TableName + ' (' + @TablePrefix + '_RowID);
				CREATE INDEX idx_' + @TableName + '_RowIDParent ON x12.' + @TableName + ' (' + @TablePrefix + '_RowIDParent);
				CREATE INDEX idx_' + @TableName + '_CentauriClientID ON x12.' + @TableName + ' (' + @TablePrefix + '_CentauriClientID);
				CREATE INDEX idx_' + @TableName + '_FileLogID ON x12.' + @TableName + ' (' + @TablePrefix + '_FileLogID);
				CREATE INDEX idx_' + @TableName + '_TransactionImplementationConventionReference ON x12.' + @TableName + ' (' + @TablePrefix + '_TransactionImplementationConventionReference);
				CREATE INDEX idx_' + @TableName + '_TransactionControlNumber ON x12.' + @TableName + ' (' + @TablePrefix + '_RowIDParent);
				CREATE INDEX idx_' + @TableName + '_LoopID ON x12.' + @TableName + ' (' + @TablePrefix + '_LoopID);
			';


		IF @Debug >= 1 PRINT @SQLString;

		IF @Debug = 0 EXECUTE sp_executesql @SQLString;

		SELECT @ListID = MIN(ListID) FROM @ParseTableList WHERE ListID > @ListID
	END -- WHILE

END -- Procedure



GO
