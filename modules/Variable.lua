-- TODO:
  -- Magic
  -- Some more magic
  -- even more magic
  
return
{
  function truncatetable(tbl) -- quite gay
    for i in pairs (tbl) do
      tbl[i] = nil
    end
  end
  
  -- useles but yolo
  function insertasset(type, id, player)
    local insertService = game:service'InsertService'
    if type == 'hat' then
      insertService:LoadAsset(id):children''[1].Parent = parent.Character
    elseif type == 'gear' then
      insertService:LoadAsset(id):children''[1].Parent = parent.Backpack
    else
      warn('invalid type: '..type)
  end
  
}
