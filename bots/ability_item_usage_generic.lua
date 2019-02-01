local Ability = {

}

function AbilityLevelUpThink()
	local npcBot = GetBot()

	if (#Ability == 0) then
		return
	end

	local list = Ability[1]

	if (list == "nil")
		table.remove(Ability, 1)
		return
	end

	if (npcBot:GetAbilityPoints() >= 1) then
		npcBot:ActionImmediate_LevelAbility(list)
		table.remove(Ability, 1)
	end
end