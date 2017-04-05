SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*************************************************************************************
Procedure:	prStainSourceMPI_NCQA
Author:		Lance Dowling
Copyright:	© 2007
Date:		2007.10.22
Purpose:	To stain source content with MPI ids 
Parameters:	@iLoadInstanceID	int.........IMIAdmin..CustomerProcessInstance.LoadInstanceID
Depends On:	dbo.dw_xref_ihds_member_id
		dbo.dw_xref_ihds_provider_id
		ncqa_mpi..mpi_master_entity
Calls:		None
Called By:	dbo.prCreateInstanceandLoadData
Returns:	None
Notes:		None
Process:	1.	Create indexes on source data
			2.	Stain Member id's in source tables
			3.	Stain Provider id's in source tables
			4.	Drop Indexes
Test Script:	EXEC prStainSourceMPI_NCQA 105
ToDo:		

run before:
use ncqa_mpi
		CREATE INDEX idx_mpi_master_entity_sourceentityid ON ncqa_mpi.dbo.mpi_master_entity (sourceentityid)
		CREATE STATISTICS sp_idx_mpi_master_entity_sourceentityid ON mpi_master_entity (sourceentityid)

use ncqa_qi10_rdsm
exec prStainSourceMPI_NCQA 105

run after:

use ncqa_mpi
		DROP INDEX idx_mpi_master_entity_sourceentityid on ncqa_mpi.dbo.mpi_master_entity
		DROP STATISTICS mpi_master_entity.sp_idx_mpi_master_entity_sourceentityid  






*************************************************************************************/
CREATE PROCEDURE [dbo].[prStainSourceMPI_NCQA]
	@iLoadInstanceID	int	-- IMIAdmin..CustomerProcessInstance.LoadInstanceID
AS
BEGIN TRY
	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, 'prStainSourceMPI_NCQA', 'Started'

	SET NOCOUNT ON

	/*************************************************************************************
		1.	Create indexes on source data
	*************************************************************************************/

--		/*
		CREATE INDEX idx_member_en ON import.Enrollment (memid,measureset)
		CREATE STATISTICS sp_idx_member_en ON import.Enrollment (memid,measureset)

		CREATE INDEX idx_visit ON import.Visits (memid,measureset)
		CREATE STATISTICS sp_idx_visit ON import.Visits (memid,measureset)

		CREATE INDEX idx_lab ON import.Labs (memid,measureset)
		CREATE STATISTICS sp_idx_lab ON import.Labs (memid,measureset)

		CREATE INDEX idx_observation ON import.Observation (ptid,measureset)
		CREATE STATISTICS sp_idx_observation ON import.Observation (ptid,measureset)

		CREATE INDEX idx_pharm ON import.Pharmacy (memid,measureset)
		CREATE STATISTICS sp_idx_pharm ON import.Pharmacy (memid,measureset)

		CREATE INDEX idx_pharmacyclinical ON import.PharmacyClinical (ptid,measureset)
		CREATE STATISTICS sp_idx_pharmacyClinical ON import.PharmacyClinical (ptid,measureset)

		CREATE INDEX idx_provider ON import.Providers (provid,measureset)
		CREATE STATISTICS sp_idx_provider ON import.Providers (provid,measureset)

		CREATE INDEX idx_providerhai ON import.ProvidersHAI (provid,measureset)
		CREATE STATISTICS sp_idx_providerhai ON import.ProvidersHAI (provid,measureset)

		CREATE INDEX idx_visit_prov ON import.Visits (memid,measureset)
		CREATE STATISTICS sp_idx_visit_prov ON import.Visits (memid,measureset)

		--CREATE INDEX idx_member_en_measureset_memid ON import.Enrollment (memid,measureset)
		--CREATE STATISTICS sp_idx_member_en_measureset_memid ON import.Enrollment (memid,measureset)


--		*/

	/*************************************************************************************
		2.	Stain Member id's in source tables
	*************************************************************************************/
		

		--SELECT	DISTINCT measureset
		--INTO	#new_measuresets
		--FROM	import.Members
		--WHERE	ihds_member_id is null
		--UNION
		--SELECT	DISTINCT measureset
		--FROM	import.Enrollment
		--WHERE	ihds_member_id is null
		--UNION
		--SELECT	DISTINCT measureset
		--FROM	import.Visits
		--WHERE	ihds_member_id is null
		--UNION
		--SELECT	DISTINCT measureset
		--FROM	import.Labs
		--WHERE	ihds_member_id is null
		--UNION
		--SELECT	DISTINCT measureset
		--FROM	import.Pharmacy
		--WHERE	ihds_member_id is null
		--UNION
		--SELECT	DISTINCT measureset
		--FROM	import.Providers
		--WHERE	ihds_provider_id is null
		--UNION
		--SELECT	DISTINCT measureset
		--FROM	import.Visits
		--WHERE	ihds_provider_id_servicing is null



		update import.Enrollment 
		set [ihds_member_id] = c.ihds_member_id
		  FROM import.Enrollment a
		--inner join #new_measuresets d
		--	on a.measureset = d.measureset
		left join dbo.mpi_master_entity b
			on RTRIM(a.memid)+'_'+RTRIM(a.measureset) = b.sourceentityid
		left join dbo.dw_xref_ihds_member_id c
			on b.MasterEntityID = c.ihds_mpi_id
		WHERE a.ihds_member_id is null


--added step for performance 12/16/08:
--IF OBJECT_ID('tempdb..#memberkeys') is not null
--    DROP TABLE #memberkeys

--select	memberkey = a.id
--into	#memberkeys
--from	import.Members a
--where	a.ihds_member_id is null


		update import.Members 
		set [ihds_member_id] = c.ihds_member_id
		  FROM import.Members a
		--inner join #new_measuresets d
		--	on a.measureset = d.measureset
		--inner join #memberkeys d2
		--	on a.id = d2.id
		left join dbo.mpi_master_entity b
			on RTRIM(a.memid)+'_'+RTRIM(a.measureset) = b.sourceentityid
		left join dbo.dw_xref_ihds_member_id c
			on b.MasterEntityID = c.ihds_mpi_id
		--WHERE a.ihds_member_id is null

--added step for performance 12/16/08:
--IF OBJECT_ID('tempdb..#memberkeys_visit') is not null
--    DROP TABLE #memberkeys_visit

--select	distinct memberkey = RTRIM(a.memid)+'_'+RTRIM(a.measureset)
--into	#memberkeys_visit
--from	import.Visits a
--where	a.ihds_member_id is null

		update import.Visits 
		set [ihds_member_id] = c.ihds_member_id 
		  FROM import.Visits a
		--inner join #new_measuresets d
		--	on a.measureset = d.measureset
		--inner join #memberkeys_visit d2
		--	on RTRIM(a.memid)+'_'+RTRIM(a.measureset) = d2.memberkey
		left join dbo.mpi_master_entity b
			on RTRIM(a.memid)+'_'+RTRIM(a.measureset) = b.sourceentityid
		left join dbo.dw_xref_ihds_member_id c
			on b.MasterEntityID = c.ihds_mpi_id
		--WHERE a.ihds_member_id is null



--added step for performance 12/16/08:
--IF OBJECT_ID('tempdb..#memberkeys_lab') is not null
--    DROP TABLE #memberkeys_lab

--select	distinct memberkey = RTRIM(a.memid)+'_'+RTRIM(a.measureset)
--into	#memberkeys_lab
--from	import.Labs a
--where	a.ihds_member_id is null

		update import.Labs 
		set [ihds_member_id] = c.ihds_member_id
		  FROM import.Labs a
		--inner join #new_measuresets d
		--	on a.measureset = d.measureset
		--inner join #memberkeys_lab d2
		--	on RTRIM(a.memid)+'_'+RTRIM(a.measureset) = d2.memberkey
		left join dbo.mpi_master_entity b
			on RTRIM(a.memid)+'_'+RTRIM(a.measureset) = b.sourceentityid
		left join dbo.dw_xref_ihds_member_id c
			on b.MasterEntityID = c.ihds_mpi_id
		--WHERE a.ihds_member_id is null


		update import.Observation 
		set [ihds_member_id] = c.ihds_member_id
		  FROM import.Observation a
		--inner join #new_measuresets d
		--	on a.measureset = d.measureset
		--inner join #memberkeys_lab d2
		--	on RTRIM(a.memid)+'_'+RTRIM(a.measureset) = d2.memberkey
		left join dbo.mpi_master_entity b
			on RTRIM(a.ptid)+'_'+RTRIM(a.measureset) = b.sourceentityid
		left join dbo.dw_xref_ihds_member_id c
			on b.MasterEntityID = c.ihds_mpi_id
		--WHERE a.ihds_member_id is null


--added step for performance 12/16/08:
--IF OBJECT_ID('tempdb..#memberkeys_pharm') is not null
--    DROP TABLE #memberkeys_pharm

--select	distinct memberkey = RTRIM(a.memid)+'_'+RTRIM(a.measureset)
--into	#memberkeys_pharm
--from	import.Pharmacy a
--where	a.ihds_member_id is null

		update import.Pharmacy 
		set [ihds_member_id] = c.ihds_member_id
		  FROM import.Pharmacy a
		--inner join #new_measuresets d
		--	on a.measureset = d.measureset
		--inner join #memberkeys_pharm d2
		--	on RTRIM(a.memid)+'_'+RTRIM(a.measureset) = d2.memberkey
		left join dbo.mpi_master_entity b
			on RTRIM(a.memid)+'_'+RTRIM(a.measureset) = b.sourceentityid
		left join dbo.dw_xref_ihds_member_id c
			on b.MasterEntityID = c.ihds_mpi_id
		--WHERE a.ihds_member_id is null

		update import.PharmacyClinical
		set [ihds_member_id] = c.ihds_member_id
		  FROM import.PharmacyClinical a
		--inner join #new_measuresets d
		--	on a.measureset = d.measureset
		--inner join #memberkeys_pharm d2
		--	on RTRIM(a.memid)+'_'+RTRIM(a.measureset) = d2.memberkey
		left join dbo.mpi_master_entity b
			on RTRIM(a.ptid)+'_'+RTRIM(a.measureset) = b.sourceentityid
		left join dbo.dw_xref_ihds_member_id c
			on b.MasterEntityID = c.ihds_mpi_id
		--WHERE a.ihds_member_id is null

	/*************************************************************************************
		3.	Stain Provider id's in source tables
	*************************************************************************************/
		update import.Providers 
		set [ihds_provider_id] = c.ihds_provider_id
		  FROM import.Providers a
		left join dbo.mpi_master_entity b
			on rtrim(a.provid)+'_'+rtrim(a.measureset) = b.sourceentityid
		left join dbo.dw_xref_ihds_provider_id c
			on b.MasterEntityID = c.ihds_mpi_id
		WHERE a.ihds_provider_id is null

		update import.ProvidersHAI
		set [ihds_provider_id] = c.ihds_provider_id
		  FROM import.ProvidersHAI a
		left join dbo.mpi_master_entity b
			on rtrim(a.provid)+'_'+rtrim(a.measureset) = b.sourceentityid
		left join dbo.dw_xref_ihds_provider_id c
			on b.MasterEntityID = c.ihds_mpi_id
		WHERE a.ihds_provider_id is null


		update import.Visits 
		set [ihds_provider_id_servicing] = c.ihds_provider_id
		  FROM import.Visits a
		left join dbo.mpi_master_entity b
			on rtrim(a.provid)+'_'+rtrim(a.measureset) = b.sourceentityid
		left join dbo.dw_xref_ihds_provider_id c
			on b.MasterEntityID = c.ihds_mpi_id
		WHERE a.ihds_provider_id_servicing is null

	/*************************************************************************************
		4.	Drop Indexes
	*************************************************************************************/

--		/*
		DROP INDEX import.Enrollment.idx_member_en
		DROP STATISTICS import.Enrollment.sp_idx_member_en

		DROP INDEX import.Visits.idx_visit
		DROP STATISTICS import.Visits.sp_idx_visit

		DROP INDEX import.Labs.idx_lab
		DROP STATISTICS import.Labs.sp_idx_lab

		DROP INDEX import.Observation.idx_observation
		DROP STATISTICS import.Observation.sp_idx_observation

		DROP INDEX import.Pharmacy.idx_pharm
		DROP STATISTICS import.Pharmacy.sp_idx_pharm

		DROP INDEX import.PharmacyClinical.idx_pharmacyclinical
		DROP STATISTICS import.PharmacyClinical.sp_idx_pharmacyclinical

		DROP INDEX import.Providers.idx_provider
		DROP STATISTICS import.Providers.sp_idx_provider

		DROP INDEX import.ProvidersHAI.idx_providerhai
		DROP STATISTICS import.ProvidersHAI.sp_idx_providerhai

		DROP INDEX import.Visits.idx_visit_prov
		DROP STATISTICS import.Visits.sp_idx_visit_prov

		--DROP INDEX import.Enrollment.idx_member_en_measureset_memid
		--DROP STATISTICS import.Enrollment.sp_idx_member_en_measureset_memid


--		*/



	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, 'prStainSourceMPI_NCQA', 'Completed'
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
	
	EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, 'prStainSourceMPI_NCQA', 'Failed'
	
	RAISERROR( @nvcErrorMessage, @iErrorSeverity, @iErrorState );
END CATCH




GO
