function GetDesire()

	local npcBot = GetBot();

	local desire = 0.0;

	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() )		--不应打断持续施法
	then
		return 0
	end

	if ( npcBot:GetGold() >= 6000) then
		local d=npcBot:DistanceFromSecretShop()
		if d<7000
		then
			desire = 100;				--根据离边路商店的距离返回欲望值
		end
	end

	return desire

end
