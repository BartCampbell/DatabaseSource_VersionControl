SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Insert / Update CentauriClient from CHSDV.dbo.R_Client c
Use:
	
	UPDATE dbo.CentauriClient SET ClientHashKey = 'Test update' WHERE CentauriClientID = 100001;
	SELECT * FROM CentauriClient;
	EXEC dbo.spCentauriClientUpsert;
	SELECT * FROM CentauriClient;


Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-09-12	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [dbo].[spCentauriClientUpsert] 
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE cc
	SET
		cc.ClientName = c.ClientName
		,cc.ClientDesc = c.ClientName
		,cc.ClientHashKey = c.ClientHashKey
		,cc.LastUpdated = GETDATE()
	FROM
		dbo.CentauriClient cc
	INNER JOIN
		CHSDV.dbo.R_Client c
		ON c.CentauriClientID = cc.CentauriClientID
	WHERE 1=1
		-- AND -- UpdateDate field should be added to the Source table
		AND (	cc.ClientName <> c.ClientName
				OR  cc.ClientDesc <> c.ClientName
				OR  cc.ClientHashKey <> c.ClientHashKey
				)

	--

	INSERT INTO dbo.CentauriClient (
		CentauriClientID
		,ClientName
		,ClientDesc
		,StagingTargetServer 
		,StagingTargetDB 
		,DVTagetServer 
		,DVTargetDB 
		,DWTagetServer 
		,DWTagetDB 
		,LoadDate
		,ClientHashKey
		)
	SELECT 
		c.CentauriClientID
		,c.ClientName
		,c.[Description]
		,@@SERVERNAME AS StagingTargetServer 
		,NULL AS StagingTargetDB 
		,'CHSPRODDB01' AS DVTagetServer 
		,'CHSDV_' + CAST(c.CentauriClientID AS VARCHAR) AS DVTargetDB 
		,'CHSPRODDB02' AS DWTagetServer 
		,'CHSDW' AS DWTagetDB 
		,c.LoadDate
		,c.ClientHashKey
	FROM 
		CHSDV.dbo.R_Client c
	LEFT OUTER JOIN
		dbo.CentauriClient cc
		ON cc.CentauriClientID = c.CentauriClientID
	WHERE 1=1
		AND cc.CentauriClientID IS NULL


END -- Procedure


GO
