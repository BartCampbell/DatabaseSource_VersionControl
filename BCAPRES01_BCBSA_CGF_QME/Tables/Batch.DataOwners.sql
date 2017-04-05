CREATE TABLE [Batch].[DataOwners]
(
[Descr] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EDCombineDays] [smallint] NOT NULL CONSTRAINT [DF_DataOwners_EDCombineDays] DEFAULT ((1)),
[EventTypeID] [tinyint] NOT NULL CONSTRAINT [DF_DataOwners_EventTypeID] DEFAULT ((1)),
[LabLagDays] [smallint] NULL CONSTRAINT [DF_DataOwners_LabLagDays] DEFAULT ((7)),
[LabLagMonths] [smallint] NULL CONSTRAINT [DF_DataOwners_LabLagMonths] DEFAULT ((0)),
[MaxProviderRanks] [smallint] NOT NULL CONSTRAINT [DF_DataOwners_MaxProviderRanks] DEFAULT ((5)),
[OfficialName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficialRefNbr] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OwnerGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_DataOwners_OwnerGuid] DEFAULT (newid()),
[OwnerID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Batch].[DataOwners] ADD CONSTRAINT [PK_DataOwners] PRIMARY KEY CLUSTERED  ([OwnerID]) ON [PRIMARY]
GO
