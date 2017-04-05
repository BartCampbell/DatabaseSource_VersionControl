SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[mpi_provider]
as


SELECT [provid]
      ,[pcp]
      ,[obgyn]
      ,[mhprov]
      ,[eyecprov]
      ,[dentist]
      ,[neph]
      ,[anes]
      ,[npr]
      ,[pas]
      ,[provpres]
      ,[measureset]
      ,[measure]
      ,[ihds_provider_id]
	, measureset+provid as measureset_provid
  FROM [provider]
GO
