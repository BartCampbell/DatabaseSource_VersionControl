SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevINV]
AS
select *
from [dbo].[INV] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[INV] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
