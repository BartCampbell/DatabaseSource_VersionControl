SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevPRV]
AS
select *
from [dbo].[PRV] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[PRV] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
