SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[prPopulateMPITables]
/*
This is a replacement procedure for MPI processes.  It is to be used
only on NCQA datasets where we are insured that one row in the member/provider
tables is one unique member/provider.

It is being used temporarily to save processing time.

Modified by Mike Kriz on 12/8/2010
*/

AS
--select	top 10 *
--from	ncqa_mpi..mpi_master_entity
--
--
--select	top 10 *
--from	ncqa_mpi..mpi_entity_type
--
--select	top 10 *
--from	ncqa_mpi..mpi_source_data

--select	top 10 *
--from	ncqa_mpi..mpi_source_data_load
/*
insert into	ncqa_rdsm..mpi_master_entity
select	*
from	ncqa_mpi..mpi_master_entity
*/


--*******************************************************************************
--*******************************************************************************
/*
member_gm
*/
--*******************************************************************************
--*******************************************************************************
declare @EntityTypeID uniqueidentifier,
		@DateCreated datetime,
		@SourceID uniqueidentifier
		
		
--set	@EntityTypeID	= (	select	top 1 EntityTypeID
--						from	ncqa_mpi..mpi_entity_type 
--						where EntityType = 'Healthcare Patient')
--
--set	@DateCreated	= getdate()
--
--set	@SourceID	= (	select	top 1 SourceID 
--						from	ncqa_mpi..mpi_source_data 
--						where	SourceName = 'ncqa_member_gm')

set	@EntityTypeID	= '348CF8D9-3DD2-4C32-8100-142733DB5B88'
set	@DateCreated	= getdate()
set	@SourceID	= '348CF8D9-3DD2-4C32-8100-142733DB5B88'

insert into	dbo.mpi_master_entity
		(EntityTypeID, DateCreated, SourceID, SourceDataLoadID, SourceEntityID)
SELECT DISTINCT
		EntityTypeID			= @EntityTypeID,
		DateCreated				= @DateCreated,
		SourceID				= @SourceID,
		SourceDataLoadID		= NULL,
		SourceEntityID			= RTRIM(memid)+'_'+RTRIM(measureset)
FROM	import.Members 
WHERE	ihds_member_id is NULL
ORDER BY SourceEntityID

--*******************************************************************************
--*******************************************************************************




--*******************************************************************************
--*******************************************************************************
/*
provider
*/
--*******************************************************************************
--*******************************************************************************
--declare @EntityTypeID uniqueidentifier,
--	@DateCreated datetime,
--	@SourceID uniqueidentifier

--set	@EntityTypeID	= (	select	top 1 EntityTypeID
--						from	ncqa_mpi..mpi_entity_type 
--						where EntityType = 'Healthcare Provider')
--
--set	@DateCreated	= getdate()
--
--
--set	@SourceID	= (	select	top 1 SourceID 
--						from	ncqa_mpi..mpi_source_data 
--						where	SourceName = 'ncqa_provider')

set	@EntityTypeID	= '4EDFBE8C-AF3C-4E06-B429-F711380AA0EF'
set	@DateCreated	= getdate()
set	@SourceID	= '044DFF24-EF89-490C-8C8D-E5FFA50033FC'

insert into	dbo.mpi_master_entity
		(EntityTypeID, DateCreated, SourceID, SourceDataLoadID, SourceEntityID)
SELECT DISTINCT
		EntityTypeID			= @EntityTypeID,
		DateCreated				= @DateCreated,
		SourceID				= @SourceID,
		SourceDataLoadID		= NULL,
		SourceEntityID			= RTRIM(provid)+'_'+RTRIM(measureset)
FROM	import.Providers 
WHERE	ihds_provider_id is NULL
UNION
SELECT DISTINCT
		EntityTypeID			= @EntityTypeID,
		DateCreated				= @DateCreated,
		SourceID				= @SourceID,
		SourceDataLoadID		= NULL,
		SourceEntityID			= RTRIM(provid)+'_'+RTRIM(measureset)
FROM	import.ProvidersHAI
WHERE	ihds_provider_id is NULL
ORDER BY SourceEntityID



--*******************************************************************************
--*******************************************************************************


GO
