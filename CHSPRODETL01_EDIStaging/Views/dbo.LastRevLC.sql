SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevLC]
AS
select *
from [dbo].[LC] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[LC] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
