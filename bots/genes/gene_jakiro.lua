local gene = {
    ----hunt----
    enemyHealth = 9.662120,
    enemyDistance = 10.602630,
    isUnderTower = 21.699410,
    weDisabled = 48.543300,
    eUnderTower = 26.766860,
    EnemyDisabled = 19.724300,
    allyInFight = 26.287880,

	enemyHealthMax = 195.889400,
	perfectAttackRange = 101.080200,
    huntMinHealth = 163.122540,
	huntMaxHealth = 114.841480,
	PowerMinConsider = -50.0,
	PowerMaxConsider = 50.0,
	PowerMaxMult = 150.0,
	PowerMinMult = 50.0,

    ----retreat----
    willEnemyTowerTargetMe = 48.066490,
    isEnemyTowerTargetingMeNoAlly = 43.552270,
    hasEnemyCreepsNearby = 25.111860,
    hardRetreat = 97.893690,
    enemyRetreat = 35.230050,
    FountainMana = 13.073580,
    AreThereDangerPings = 64.584940,

	creepCount = 54.575980,
	hardHealth = 8.384930,
	dangerTime = 26.831180,
	dangerDistance = 1221.652890,
	PowerMaxFlee = 200.0,
	FleeMinMult = 100.0,
	FleeMaxMult = 200.0,

    ----farm----
    creepsAround = 39.093300,
    calcEnemyCreepHealth = 138.264130,
    calcEnemyCreepDist = 55.110740,

	creepHealthMaxClamp = 18.423810,

	----finish him----
	timeToFinish = 4.345920,
	chaseWeight = 46.406270,
    chaseDistance = 493.087330,
    
    retreatEarly = 122.548070,
	retreatLate = 113.798870,
	farmEarly = 81.846010,
	farmLate = 87.979430,
	huntEarly = 102.684300,
    huntLate = 127.383920,
    
    towerWeight = 18.496950,
    buildingWeight = 37.126646
}

return gene
