SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevCAS]
AS
select *
from [dbo].[CAS] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[CAS] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
