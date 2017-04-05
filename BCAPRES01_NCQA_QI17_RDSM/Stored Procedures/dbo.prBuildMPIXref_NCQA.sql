SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







/*************************************************************************************
Procedure:	prBuildMPIXref_NCQA
Author:		Dennis Deming
Copyright:	© 2007
Date:		2007.10.19
Purpose:	To load MPI cross reference tables in the IMIDataStore with NCQA 
		data
Parameters:	@iLoadInstanceID	int.........IMIAdmin..CustomerProcessInstance.LoadInstanceID
Depends On:	dbo.dw_xref_ihds_member_id
		dbo.dw_xref_ihds_prov_id
		dbo.member
		dbo.provider
Calls:		None
Called By:	dbo.prBuildMPIXref
Returns:	None
Notes:		None
Process:	1.	Load dw_xref_ihds_member_id and dw_xref_ihds_prov_id from mpi.
Test Script:	exec prBuildMPIXref_NcQA 105
ToDo:		

Modifications: script has been modified to use:

		ncqa_qi10_rdsm..mpi_master_entity

instead of:

		ncqa_mpi..mpi_master_entity

create index ix_fk_soureentityid on mpi_master_entity (sourceentityid)

*************************************************************************************/
CREATE PROCEDURE [dbo].[prBuildMPIXref_NCQA]
	@iLoadInstanceID	int	-- IMIAdmin..CustomerProcessInstance.LoadInstanceID
AS
BEGIN TRY
	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, 'prBuildMPIXref_NCQA', 'Started'

	SET NOCOUNT ON

	/*************************************************************************************
		1.	Load dw_xref_ihds_member_id and dw_xref_ihds_provider_id from
			mpi .
	*************************************************************************************/
	--	Members
	INSERT INTO dbo.dw_xref_ihds_member_id( ihds_mpi_id, create_datetime, update_datetime, legacy_ihds_member_id, ClientID )
	SELECT	DISTINCT b.MasterEntityID, GETDATE(), GETDATE(), NULL, 'NCQA' 
	  FROM import.Members a
		INNER JOIN dbo.mpi_master_entity b
			on RTRIM(a.memid)+'_'+RTRIM(a.measureset) = b.sourceentityid
--		left JOIN dbo.dw_xref_ihds_member_id c
--			on b.MasterEntityID = c.ihds_mpi_id
--		where c.ihds_mpi_id is null
		WHERE b.MasterEntityID NOT IN (SELECT ihds_mpi_id FROM dbo.dw_xref_ihds_member_id )

	-- Providers
	INSERT INTO dbo.dw_xref_ihds_provider_id( ihds_mpi_id, create_datetime, update_datetime, ClientID )
	SELECT	DISTINCT b.MasterEntityID, GETDATE(), GETDATE(), 'NCQA' 
	  FROM import.Providers a
		INNER JOIN dbo.mpi_master_entity b
			on RTRIM(a.provid)+'_'+RTRIM(a.measureset) = b.sourceentityid
		WHERE b.MasterEntityID NOT IN (SELECT ihds_mpi_id FROM dbo.dw_xref_ihds_provider_id )
	UNION
	SELECT	DISTINCT b.MasterEntityID, GETDATE(), GETDATE(), 'NCQA' 
	  FROM import.ProvidersHAI a
		INNER JOIN dbo.mpi_master_entity b
			on RTRIM(a.provid)+'_'+RTRIM(a.measureset) = b.sourceentityid
		WHERE b.MasterEntityID NOT IN (SELECT ihds_mpi_id FROM dbo.dw_xref_ihds_provider_id )

	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, 'prBuildMPIXref_NCQA', 'Completed'
END TRY

BEGIN CATCH
	DECLARE	@iErrorLine		int, 
		@iErrorNumber		int,
		@iErrorSeverity		int,
		@iErrorState		int,
		@nvcErrorMessage	nvarchar( 4000 ), 
		@nvcErrorProcedure	nvarchar( 126 )

	-- capture error info so we can fail it up the line
	SELECT	@iErrorLine = ERROR_LINE(),
		@iErrorNumber = ERROR_NUMBER(),
		@iErrorSeverity = ERROR_SEVERITY(),
		@iErrorState = ERROR_STATE(),
		@nvcErrorMessage = ERROR_MESSAGE(),
		@nvcErrorProcedure = ERROR_PROCEDURE()
		
	INSERT INTO IMIAdmin..ErrorLog( ErrorLine, ErrorMessage, ErrorNumber, ErrorProcedure, ErrorSeverity,
		ErrorState, ErrorTime, InstanceID, UserName )
	SELECT	@iErrorLine, @nvcErrorMessage, @iErrorNumber, @nvcErrorProcedure, @iErrorSeverity,
		@iErrorState, GETDATE(), InstanceID, SUSER_SNAME()
	FROM	IMIAdmin..ClientProcessInstance
	WHERE	LoadInstanceID = @iLoadInstanceID
	
	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, 'prBuildMPIXref_NCQA', 'Failed'
	
	RAISERROR( @nvcErrorMessage, @iErrorSeverity, @iErrorState );
END CATCH



GO
