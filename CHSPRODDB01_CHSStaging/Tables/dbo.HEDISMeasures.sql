CREATE TABLE [dbo].[HEDISMeasures]
(
[RecID] [bigint] NOT NULL IDENTITY(1, 1),
[MemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullMeasureDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Numerator] [int] NULL CONSTRAINT [DF__HEDISMeas__Numer__3DC0748A] DEFAULT ((0)),
[Denominator] [int] NULL CONSTRAINT [DF__HEDISMeas__Denom__3EB498C3] DEFAULT ((0)),
[MeasureCompliant] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeasureYear] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HEDISMeasures] ADD CONSTRAINT [UQ__HEDISMea__360414FE22087A84] UNIQUE NONCLUSTERED  ([RecID]) ON [PRIMARY]
GO
