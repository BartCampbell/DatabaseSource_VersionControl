SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevK3]
AS
select *
from [dbo].[K3] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[K3] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
