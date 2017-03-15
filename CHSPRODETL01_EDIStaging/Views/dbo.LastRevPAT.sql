SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevPAT]
AS
select *
from [dbo].[PAT] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[PAT] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
