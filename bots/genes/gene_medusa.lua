local gene = {
    ----hunt----
    enemyHealth = 41.516000,
    enemyDistance = 7.455550,
    isUnderTower = 28.701540,
    weDisabled = 28.926920,
    eUnderTower = 8.100130,
    EnemyDisabled = 11.954010,
    allyInFight = 22.012600,

	enemyHealthMax = 44.478670,
	perfectAttackRange = 120.286620,
    huntMinHealth = 86.261470,
	huntMaxHealth = 122.371040,
	PowerMinConsider = -50.0,
	PowerMaxConsider = 50.0,
	PowerMaxMult = 150.0,
	PowerMinMult = 50.0,

    ----retreat----
    willEnemyTowerTargetMe = 37.174510,
    isEnemyTowerTargetingMeNoAlly = 23.625380,
    hasEnemyCreepsNearby = 32.108010,
    hardRetreat = 50.728640,
    enemyRetreat = 109.691220,
    FountainMana = 49.440210,
    AreThereDangerPings = 16.957400,

	creepCount = 83.612340,
	hardHealth = 27.418500,
	dangerTime = 50.248600,
	dangerDistance = 916.133870,
	PowerMaxFlee = 200.0,
	FleeMinMult = 100.0,
	FleeMaxMult = 200.0,

    ----farm----
    creepsAround = 6.063640,
    calcEnemyCreepHealth = 58.637560,
    calcEnemyCreepDist = 105.489170,

	creepHealthMaxClamp = 14.716870,

	----finish him----
	timeToFinish = 2.791050,
	chaseWeight = 53.255240,
    chaseDistance = 509.824540,
    
    retreatEarly = 98.998330,
	retreatLate = 112.104330,
	farmEarly = 141.209630,
	farmLate = 79.511630,
	huntEarly = 91.072500,
    huntLate = 147.506370,
    
    towerWeight = 10.734390,
    buildingWeight = 27.788720
}

return gene
