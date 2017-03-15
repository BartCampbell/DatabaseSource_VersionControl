SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevSV3]
AS
select *
from [dbo].[SV3] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[SV3] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
