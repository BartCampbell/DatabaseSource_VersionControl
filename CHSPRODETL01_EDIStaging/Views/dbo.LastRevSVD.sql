SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[LastRevSVD]
AS
select *
from [dbo].[SVD] a
where RevisionId = (select max([RevisionId])
                    from [dbo].[SVD] b 
                    where a.InterchangeId = b.InterchangeId 
                      and a.PositionInInterchange = b.PositionInInterchange
                    )
GO
