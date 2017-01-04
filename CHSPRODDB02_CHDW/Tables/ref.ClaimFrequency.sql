CREATE TABLE [ref].[ClaimFrequency]
(
[ClaimFrequencyID] [int] NOT NULL IDENTITY(1, 1),
[ClaimFrequencyCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClaimFrequency] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[ClaimFrequency] ADD CONSTRAINT [PK_ClaimFrequency] PRIMARY KEY CLUSTERED  ([ClaimFrequencyID]) ON [PRIMARY]
GO
