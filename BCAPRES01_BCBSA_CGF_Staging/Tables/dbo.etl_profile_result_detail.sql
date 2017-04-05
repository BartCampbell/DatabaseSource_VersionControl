CREATE TABLE [dbo].[etl_profile_result_detail]
(
[ProfileResultDtlKey] [int] NOT NULL IDENTITY(1, 1),
[ProfileResultHdrKey] [int] NULL,
[RowID] [int] NULL,
[TargetField] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TargetFieldValue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TargetFieldCount] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[etl_profile_result_detail] ADD CONSTRAINT [FK_etl_profile_result_detail_etl_profile_result_hdr] FOREIGN KEY ([ProfileResultHdrKey]) REFERENCES [dbo].[etl_profile_result_hdr] ([ProfileResultHdrKey])
GO
