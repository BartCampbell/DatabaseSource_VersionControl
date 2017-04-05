CREATE TABLE [dbo].[etl_profile_result_hdr]
(
[ProfileResultHdrKey] [int] NOT NULL IDENTITY(1, 1),
[ProfileID] [int] NULL,
[LoadInstanceID] [int] NULL,
[ProfileRunDate] [datetime] NULL,
[ProfileValue1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileValue1Desc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileValue2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfileValue2Desc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfilePercent] [numeric] (5, 2) NULL,
[ExpectedValueFlag] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[etl_profile_result_hdr] ADD CONSTRAINT [PK_etl_profile_result_hdr] PRIMARY KEY CLUSTERED  ([ProfileResultHdrKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[etl_profile_result_hdr] ADD CONSTRAINT [FK_etl_profile_result_hdr_etl_profile_hdr] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[etl_profile_hdr] ([ProfileID])
GO
