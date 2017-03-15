SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevNTE]
AS
select *
from [dbo].[NTE] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[NTE] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
