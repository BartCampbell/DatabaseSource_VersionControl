CREATE TABLE [dbo].[etl_profile_result_hdr_client]
(
[ProfileResultHdrClientKey] [int] NOT NULL IDENTITY(1, 1),
[ProfileID] [int] NULL,
[LoadInstanceID] [int] NULL,
[ProfileRunDate] [datetime] NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorRecordCount] [int] NULL
) ON [PRIMARY]
GO
