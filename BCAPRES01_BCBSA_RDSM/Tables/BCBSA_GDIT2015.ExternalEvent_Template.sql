CREATE TABLE [BCBSA_GDIT2015].[ExternalEvent_Template]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RowFileID] [int] NULL,
[JobRunTaskFileID] [uniqueidentifier] NULL,
[LoadInstanceID] [int] NULL,
[LoadInstanceFileID] [int] NULL,
[MemberID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDate1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDate2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHSpecialtyID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecificationYear] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReviewerName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReviewDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSourceType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupplementalDataSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AuditorApprovedInd] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AsOfDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
