SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevAD1]
AS
select *
from [dbo].[AD1] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[AD1] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
