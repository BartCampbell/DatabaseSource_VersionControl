CREATE TABLE [Batch].[Batches]
(
[BatchGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Batches_BatchGuid] DEFAULT (newid()),
[BatchID] [int] NOT NULL IDENTITY(1, 1),
[BatchStatusID] [smallint] NOT NULL CONSTRAINT [DF_Batches_BatchStatusID] DEFAULT ((-1)),
[ConfirmedDate] [datetime] NULL,
[CountClaimCodes] [bigint] NOT NULL CONSTRAINT [DF_Batches_CountClaimCodes] DEFAULT ((0)),
[CountClaimLines] [bigint] NOT NULL CONSTRAINT [DF_Batches_CountClaimLines] DEFAULT ((0)),
[CountEnrollment] [bigint] NOT NULL CONSTRAINT [DF_Batches_CountEnrollment] DEFAULT ((0)),
[CountItems] [bigint] NOT NULL CONSTRAINT [DF_Batches_RecordCnt] DEFAULT ((0)),
[CountMeasures] [bigint] NOT NULL CONSTRAINT [DF_Batches_MeasureCnt] DEFAULT ((0)),
[CountMembers] [bigint] NOT NULL CONSTRAINT [DF_Batches_MemberCnt] DEFAULT ((0)),
[CountProviders] [bigint] NOT NULL CONSTRAINT [DF_Batches_CountProviders] DEFAULT ((0)),
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[IsConfirmed] [bit] NOT NULL CONSTRAINT [DF_Batches_IsConfirmed] DEFAULT ((0)),
[IsRetrieved] [bit] NOT NULL CONSTRAINT [DF_Batches_IsRetrieved] DEFAULT ((0)),
[IsSubmitted] [bit] NOT NULL CONSTRAINT [DF_Batches_IsSubmitted] DEFAULT ((0)),
[RetrievedDate] [datetime] NULL,
[SourceGuid] [uniqueidentifier] NULL,
[SubmittedDate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/20/2012
-- Description:	Logs status changes of batches.
-- =============================================
CREATE TRIGGER [Batch].[Batches_LogBatchStatusChanges_IU]
   ON  [Batch].[Batches] 
   AFTER INSERT, UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

    INSERT INTO Log.BatchStatuses
			(BatchID,
			BatchStatusID)
    SELECT	i.BatchID,
			i.BatchStatusID
	FROM	INSERTED AS i
			LEFT OUTER JOIN DELETED AS d
					ON i.BatchID = d.BatchID
	WHERE	(d.BatchStatusID IS NULL) OR
			(d.BatchStatusID <> i.BatchStatusID)
	ORDER BY BatchStatusID, BatchID;
	
	--UPDATE	BDR
	--SET		BatchStatusID = t.BatchStatusID
	--FROM	Batch.DataRuns AS BDR
	--		CROSS APPLY (SELECT MIN(BatchStatusID) AS BatchStatusID FROM Batch.[Batches] AS i WHERE i.DataRunID = BDR.DataRunID) AS t
	--WHERE	(t.BatchStatusID IS NOT NULL);
	
END
GO
ALTER TABLE [Batch].[Batches] ADD CONSTRAINT [PK_Batches] PRIMARY KEY CLUSTERED  ([BatchID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Batches_BatchGuid] ON [Batch].[Batches] ([BatchGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Batches_DataRunID] ON [Batch].[Batches] ([DataRunID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Batches_DataSetID] ON [Batch].[Batches] ([DataSetID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Batches_SourceGuid] ON [Batch].[Batches] ([SourceGuid]) WHERE ([SourceGuid] IS NOT NULL) ON [PRIMARY]
GO
ALTER TABLE [Batch].[Batches] SET ( LOCK_ESCALATION = DISABLE )
GO
