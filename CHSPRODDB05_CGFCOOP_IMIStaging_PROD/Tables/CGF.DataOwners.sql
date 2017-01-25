CREATE TABLE [CGF].[DataOwners]
(
[Descr] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EDCombineDays] [smallint] NOT NULL,
[EventTypeID] [tinyint] NOT NULL,
[LabLagDays] [smallint] NULL,
[LabLagMonths] [smallint] NULL,
[OwnerGuid] [uniqueidentifier] NOT NULL,
[OwnerID] [int] NOT NULL
) ON [PRIMARY]
GO
