SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/14/2014
-- Description:	This proc duplicates the functionality of the script file I use to import sample/test decks from NCQA.
-- =============================================
CREATE PROCEDURE [import].[LoadNewDecksIntoStaging]
AS
BEGIN

-- IMPORT AVAILABLE DECKS
EXEC	[dbo].[usp_load_ncqa_datasets]

--------------------------------COMMENTED OUT SECTION IS NOW PART OF usp_load_ncqa_datasets-------------------------------------------------------------------
---- CLEAR IHDS_MEMBER_IDs
--/**/
--truncate table dw_xref_ihds_member_id
--truncate table dw_xref_ihds_provider_id
--truncate table mpi_master_entity

--UPDATE import.Enrollment SET ihds_member_id = NULL
--UPDATE import.Labs SET ihds_member_id = NULL
--UPDATE import.Members SET ihds_member_id = NULL
--UPDATE import.Pharmacy SET ihds_member_id = NULL
--UPDATE import.Providers SET ihds_provider_id = NULL
--UPDATE import.Visits SET ihds_member_id = NULL, ihds_provider_id_servicing = NULL


----- POPULATE IHDS/DW MEMBER AND PROVIDER TABLES
--DECLARE @client varchar(255)
--DECLARE @enddate char(8)
--DECLARE @year int
--SET @year = YEAR(GETDATE())

--IF MONTH(GETDATE()) < 9
--	SET @year = @year - 1

--SET @client = 'NCQA' + CAST(@year AS varchar(255))
--SET @enddate = CAST(@year AS varchar(4)) + '1231'

----- Moved here by Mike Kriz
--EXECUTE dbo.prPopulateMPITables
--EXECUTE dbo.prCreateInstanceAndLoadData @client, @enddate
---------------------------END: COMMENTED OUT SECTION IS NOW PART OF usp_load_ncqa_datasets-------------------------------------------------------------------

-- COPY DATA TO STAGING
EXEC NCQA_QI17_Staging.dbo.prLoadDataStoreWithTestDeck

END
GO
GRANT EXECUTE ON  [import].[LoadNewDecksIntoStaging] TO [IMIHEALTH\IMI.SQL.Developers]
GO
