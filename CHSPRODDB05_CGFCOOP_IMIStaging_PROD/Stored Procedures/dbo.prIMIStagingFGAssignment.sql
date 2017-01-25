SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
USE [master]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILEGROUP [CLM_1]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILE ( NAME = N'StFran_IMIStaging_PROD_CLM_1', FILENAME = N'e:\IMI.SQL.Data\StFran_IMIStaging_PROD_CLM_1.ndf' , SIZE = 131072KB , FILEGROWTH = 65536KB ) TO FILEGROUP [CLM_1]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILEGROUP [CLM_2]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILE ( NAME = N'StFran_IMIStaging_PROD_CLM_2', FILENAME = N'f:\IMI.SQL.Data\StFran_IMIStaging_PROD_CLM_2.ndf' , SIZE = 131072KB , FILEGROWTH = 65536KB ) TO FILEGROUP [CLM_2]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILEGROUP [MBR]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILE ( NAME = N'StFran_IMIStaging_PROD_MBR', FILENAME = N'H:\IMI.SQL.Data\StFran_IMIStaging_PROD_MBR.ndf' , SIZE = 131072KB , FILEGROWTH = 65536KB ) TO FILEGROUP [MBR]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILEGROUP [ELIG]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILE ( NAME = N'StFran_IMIStaging_PROD_ELIG', FILENAME = N'I:\IMI.SQL.Data\StFran_IMIStaging_PROD_ELIG.ndf' , SIZE = 131072KB , FILEGROWTH = 65536KB ) TO FILEGROUP [ELIG]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILEGROUP [RX]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILE ( NAME = N'StFran_IMIStaging_PROD_RX', FILENAME = N'J:\IMI.SQL.Data\StFran_IMIStaging_PROD_RX.ndf' , SIZE = 131072KB , FILEGROWTH = 65536KB ) TO FILEGROUP [RX]


ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILEGROUP [IDX_1]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILE ( NAME = N'StFran_IMIStaging_PROD_IDX_1', FILENAME = N'J:\IMI.SQL.Data\StFran_IMIStaging_PROD_IDX_1.ndf' , SIZE = 131072KB , FILEGROWTH = 65536KB ) TO FILEGROUP [IDX_1]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILEGROUP [IDX_2]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILE ( NAME = N'StFran_IMIStaging_PROD_IDX_2', FILENAME = N'I:\IMI.SQL.Data\StFran_IMIStaging_PROD_IDX_2.ndf' , SIZE = 131072KB , FILEGROWTH = 65536KB ) TO FILEGROUP [IDX_2]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILEGROUP [IDX_3]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILE ( NAME = N'StFran_IMIStaging_PROD_IDX_3', FILENAME = N'H:\IMI.SQL.Data\StFran_IMIStaging_PROD_IDX_3.ndf' , SIZE = 131072KB , FILEGROWTH = 65536KB ) TO FILEGROUP [IDX_3]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILEGROUP [IDX_4]
GO
ALTER DATABASE [StFran_IMIStaging_PROD] ADD FILE ( NAME = N'StFran_IMIStaging_PROD_IDX_4', FILENAME = N'F:\IMI.SQL.Data\StFran_IMIStaging_PROD_IDX_4.ndf' , SIZE = 131072KB , FILEGROWTH = 65536KB ) TO FILEGROUP [IDX_4]




*/

--/*
CREATE PROC [dbo].[prIMIStagingFGAssignment]

as
--*/

DECLARE @bDebug BIT = 1,
	@bExec BIT = 1


DECLARE @tList TABLE 
	(RowID INT IDENTITY(1,1),
	TabSchema VARCHAR(50),
	TabName VARCHAR(50),
	DataFG VARCHAR(50),
	IndexFG VARCHAR(50))

INSERT INTO @tList (TabSchema,TabName,DataFG,IndexFG)
--SELECT 'dbo','mpi_pre_load_dtl_prov','MPI_1','IDX_1' 
--UNION
--SELECT 'dbo','mpi_pre_load_prov','MPI_2','IDX_1' 
--UNION
--SELECT 'dbo','mpi_output_provider','MPI_3','IDX_2' 
--UNION
--SELECT 'dbo','mpi_pre_load_dtl_Member','MPI_1','IDX_1' 
--UNION
--SELECT 'dbo','mpi_pre_load_member','MPI_2','IDX_1' 
--UNION
--SELECT 'dbo','mpi_output_member','MPI_3','IDX_2' 
--UNION
SELECT 'dbo','Claim','CLM_1','IDX_1' 
UNION
SELECT 'dbo','ClaimLineItem','CLM_2','IDX_2' 
UNION 
SELECT 'dbo','Member','MBR','IDX_3' 
UNION
SELECT 'dbo','Eligibility','ELIG','IDX_4' 
UNION
SELECT 'dbo','PharmacyClaim','RX','IDX_3' 




DECLARE @i INT,
	@vcCmd VARCHAR(2000),
	@vcFG VARCHAR(20)

/*
-- Check to see if FileGroup Exists
SELECT @i = MIN(RowID)
	FROM @tList

WHILE @i IS NOT NULL 
BEGIN

	SELECT @vcFG = DataFG
		FROM @tList
		WHERE RowID = @i
	
	



	SELECT @i = MIN(RowID)
		FROM @tList
		WHERE RowID > @i


END
*/


SELECT @i = MIN(RowID)
	FROM @tList

WHILE @i IS NOT NULL 
BEGIN
	SELECT @vcCmd = 'TRUNCATE TABLE ' + TabSchema + '.' + TabName
		FROM @tList
		WHERE RowID = @i

	IF @bDebug = 1
		PRINT @vcCmd

	IF @bExec = 1
		EXEC (@vcCmd)

	SELECT @vcCmd = 'sp_MoveTablesToFileGroup '  
				+ ' @SchemaFilter = ''' + TabSchema + ''', '
				+ ' @TableFilter = ''' + TabName + ''', '
				+ ' @DataFileGroup = ''' + dataFG + ''', '
				+ ' @IndexFileGroup = ''' + IndexFG  + ''', '
				+ ' @LobFileGroup = NULL, '
				+ ' @FromFileGroup = ''%'','
				+ ' @ClusteredIndexes = 1, ' 
				+ ' @SecondaryIndexes = 1,  '
				+ ' @Heaps  = 1,  '     
				+ ' @Online = 0,  '     
				+ ' @ProduceScript = 0 '
		FROM @tList
		WHERE RowID = @i

	IF @bDebug = 1
		PRINT @vcCmd

	IF @bExec = 1
		EXEC (@vcCmd)

	SELECT @i = MIN(RowID)
		FROM @tList
		WHERE RowID > @i



END

GO
