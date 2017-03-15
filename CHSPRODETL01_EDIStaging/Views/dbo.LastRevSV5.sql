SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevSV5]
AS
select *
from [dbo].[SV5] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[SV5] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
