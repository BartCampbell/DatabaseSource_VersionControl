SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevCLM]
AS
select *
from [dbo].[CLM] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[CLM] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
