canvasWidth = love.graphics.getWidth()
canvasHeigth = love.graphics.getHeight()

anim = require("anim8")

function love.load()
	-- ship
	imgShip = love.graphics.newImage("img/ship.png")

	ship = {
		posX = canvasWidth / 2,
		posY = canvasHeigth / 2,
		speed = 200
	}
	-- ship

	-- shots
	shoot = true
	delayShot = 0.5
	tempoShot = delayShot
	shots = {}
	imgShot = love.graphics.newImage("img/shot.png")
	-- shots

	--enemies
	delayEnemy = 0.4
	timeCreateEnemy = delayEnemy
	imgEnemy = love.graphics.newImage("img/enemy.png")
	enemies = {}
	--enemies

	-- lives
	live = true
	points = 0
	lives = 5
	gameOver = false
	transparency = 0
	imgGameOver = love.graphics.newImage("img/gameover.png")
	-- lives

	--background
	background = love.graphics.newImage("img/background.png") 
	backgroundTwo = love.graphics.newImage("img/background.png")

	positionBg = {
		x = 0,
		y = 0,
		y2 = 0 - background:getHeight(),
		ve1 = 30
	}
	--background

	--font
	font = love.graphics.newImageFont("img/font.png", " abcdefghijklmnopqrstuvwxyz" .. "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" .. "123456789.,!?-+/():;%&`'*#=[]\"")
	fontTwo = love.graphics.newFont("font/fontExample.ttf", 30)
	--font

	--sound
	shootingSound = love.audio.newSource("sound/shooting.wav", "static")
	explodeShip = love.audio.newSource("sound/explodeShip.mp3", "static")
	explodeEnemy = love.audio.newSource("sound/explodeEnemy.wav", "static")
	music = love.audio.newSource("sound/music.mp3")
	soundGameOver = love.audio.newSource("sound/GameOver1.mp3")
	music:play()
	music:setLooping(true)
	--sound

	--punctuation effects
	scaleX = 1
	scaleY = 1
	--punctuation effects

	--Screen Title
	openScreen = false
	screenTitle = love.graphics.newImage("img/screenTitle.png")
	inOutX = 0
	inOutY = 0
	--Screen title

	--pause
	pause = false
	--pause

		--mega bomba
	bombaEmpty = love.graphics.newImage("img/BombaEmpty.png")
	bombaFull = love.graphics.newImage("img/BombaFull.png")
	bombaFullVision = love.graphics.newImage("img/BombaFullVision.png")
	explosion = love.graphics.newImage("img/Explosion.png")
	musicExplosion = love.audio.newSource("sound/Explosion.mp3")

	explode = {}
	canExplode = false
	loader = 0
	showNotice = 0.8

	local g = anim.newGrid(192, 192, explosion:getWidth(), explosion:getHeight())
	animation = anim.newAnimation(g('1-5', 2, '1-5', 3, '1-5', 4, '1-4', 5), 0.09, destroy)	
	--mega bomba

	--destroy enemy
		expEnemy = {}
		destructionEnemy = love.graphics.newImage("img/ExplosionEnemy.png")
		expEnemy.x = 0
		expEnemy.y = 0
		local gride = anim.newGrid(64, 64, destructionEnemy:getWidth(), destructionEnemy:getHeight())
		destroyEnemy = anim.newAnimation(gride('1-5', 1, '1-5', 2, '1-5', 3, '1-5', 4, '1-3', 5), 0.01, destroyTwo)
	--destroy enemy
end

function love.update(dt)
	if not pause then
		movements(dt)
		shooting(dt)
		enemy(dt)
		hits()
		reset()
		positionBgScrolling(dt)
		effect(dt)
		startGame(dt)
		controlsExplosion(dt)
		bombaReady(dt)
		controlsExplosionTwo(dt)
	end
	if gameOver then
		endGame(dt)
	end
end

function love.draw()
	if not gameOver then
		-- background
		love.graphics.draw(background, positionBg.x, positionBg.y)
		love.graphics.draw(backgroundTwo, positionBg.x, positionBg.y2)
		-- background

		-- shots
		for i, shot in ipairs(shots) do
			love.graphics.draw(shot.img, shot.x, shot.y, 0, 1, 1, imgShot:getWidth() / 2, imgShot:getHeight())
			if points > 50 then
				love.graphics.draw(shot.img, shot.x - 10, shot.y + 15, 0, 1, 1, imgShot:getWidth() / 2, imgShot:getHeight())
				love.graphics.draw(shot.img, shot.x + 10, shot.y + 15, 0, 1, 1, imgShot:getWidth() / 2, imgShot:getHeight())
				delayShot = 0.4
				if points > 200 then
					love.graphics.draw(shot.img, shot.x - 20, shot.y + 30, 0, 1, 1, imgShot:getWidth() / 2, imgShot:getHeight())
					love.graphics.draw(shot.img, shot.x + 20, shot.y + 30, 0, 1, 1, imgShot:getWidth() / 2, imgShot:getHeight())
					delayShot = 0.3
					if points > 500 then
						delayShot = 0.2
					end
				end
			end
		end
		-- shots

		--enemies
		for i, enemy in ipairs(enemies) do
			love.graphics.draw(enemy.img, enemy.x, enemy.y)
		end
		--enemies

		--destroy enemy
		for i, _ in ipairs(expEnemy) do
			destroyEnemy:draw(destructionEnemy, expEnemy.x, expEnemy.y)
		end 
		--destroy enemy

		-- pointsScreen
		love.graphics.setFont(font)
		love.graphics.print("Killed: ", 10, 10, 0, 1, 1, 0, 2, 0, 0)
		love.graphics.print(points, 80, 14, 0, scaleX, scaleY, 5, 5, 0, 0)
		love.graphics.print("Lives: " .. lives, 400, 15)
		-- pointsScreen

		--mega bomba
		for i, _ in ipairs(explode) do
			animation:draw(explosion, canvasWidth / 2, canvasHeigth / 2, 0, 4, 4, 96, 96)
		end
		love.graphics.draw(bombaEmpty, canvasWidth / 2, 50, 0, 1, 1, bombaEmpty:getWidth() / 2, bombaEmpty:getHeight() / 2)
		love.graphics.draw(bombaFull, canvasWidth / 2, 50, 0, loader, loader, bombaFull:getWidth() / 2, bombaFull:getHeight() / 2)
		if canExplode then
			love.graphics.draw(bombaFullVision, canvasWidth / 2, 50, 0, showNotice, showNotice, bombaFullVision:getWidth() / 2, bombaFullVision:getHeight() / 2)
		end
		--mega bomba
	end

	--game over reset
	if live then
		love.graphics.draw(imgShip, ship.posX, ship.posY, 0, 1, 1, imgShip:getWidth() / 2, imgShip:getHeight() / 2)
	elseif gameOver then
		love.graphics.setColor(255, 255, 255, transparency)
		love.graphics.draw(imgGameOver, 0, 0)
		love.graphics.setFont(fontTwo)
		love.graphics.print("Killed ships: " .. points, canvasWidth / 4, 50)
	else
		love.graphics.draw(screenTitle, inOutX, inOutY)
	end
	--game over reset
end

function movements(dt)
	if love.keyboard.isDown("right") then
		if ship.posX < (canvasWidth - imgShip:getWidth() / 2) then
			ship.posX = ship.posX + ship.speed * dt
		end
	end

	if love.keyboard.isDown("left") then
		if ship.posX > (0 + imgShip:getWidth() / 2) then
			ship.posX = ship.posX - ship.speed * dt
		end
	end

	if love.keyboard.isDown("up") then
		if ship.posX > (0 + imgShip:getHeight() / 2) then
			ship.posY = ship.posY - ship.speed * dt
		end
	end

	if love.keyboard.isDown("down") then
		if ship.posY < (canvasHeigth - imgShip:getHeight() / 2) then
			ship.posY = ship.posY + ship.speed * dt
		end
	end
end

function shooting(dt)
	tempoShot = tempoShot - (1 * dt)
	if tempoShot < 0 then
		shoot = true
	end
	if live then
		if love.keyboard.isDown("space") and shoot then
			newShot = {x = ship.posX, y = ship.posY, img = imgShot}
			table.insert(shots, newShot)
			shootingSound:stop()
			shootingSound:play()
			shoot = false
			tempoShot = delayShot
		end
	end
	for i,shot in ipairs(shots) do
		shot.y = shot.y - (500 * dt)

		if (shot.y < 0) then
			table.remove(shots, i)
		end
	end 
end

function enemy(dt)
	timeCreateEnemy = timeCreateEnemy - (1 * dt)
	if timeCreateEnemy < 0 then
		timeCreateEnemy = delayEnemy
		randomNumber = math.random(10, love.graphics.getWidth() - ( (imgEnemy:getWidth() / 2) + 10 ) )
		newEnemy = { x = randomNumber, y = -imgEnemy:getWidth(), img = imgEnemy}
		table.insert(enemies, newEnemy)
	end

	for i, enemy in ipairs(enemies) do
		enemy.y = enemy.y + (200 * dt)

		if enemy.y > 850 then
			table.remove(enemies, 1)
		end
	end
end

function hits()
	for i, enemy in ipairs(enemies) do
		for j, shot in ipairs(shots) do
			if checkHit(enemy.x, enemy.y, imgEnemy:getWidth(), imgEnemy:getHeight(), shot.x, shot.y, imgEnemy:getWidth(), imgEnemy:getHeight()) then
				table.remove(shots, j)
				expEnemy.x = enemy.x
				expEnemy.y = enemy.y
				table.insert(expEnemy, destroyEnemy)
				table.remove(enemies, i)
				explodeEnemy:stop()
				explodeEnemy:play()
				scaleX = 1.5
				scaleY = 1.5
				points = points + 1
				loader = loader + 0.1
				if loader >= 1 then
					loader = 1
					canExplode = true
				end
			end
		end
		if checkHit(enemy.x, enemy.y, imgEnemy:getWidth(), imgEnemy:getHeight(), ship.posX - (imgShip:getWidth() / 2), ship.posY, imgShip:getWidth(), imgShip:getHeight() ) and live
			then
			table.remove(enemies, i)
			explodeShip:play()
			live = false
			openScreen = false
			lives = lives - 1
			if lives < 0 then
				gameOver = true
				soundGameOver:play()
				soundGameOver:setLooping(false)
			end
		end
	end
end

function checkHit(x1, y1, w1, h1, x2, y2, w2, h2)

	return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function reset() 
	if not live and inOutY == 0 and love.keyboard.isDown('return') then
		shots = {}
		enemies = {}

		shoot = tempoShot
		timeCreateEnemy = delayEnemy

		ship.posX = canvasWidth / 2
		ship.posY = canvasHeigth / 2

		openScreen = true
	end
end

function positionBgScrolling(dt)
	positionBg.y = positionBg.y + positionBg.ve1 * dt
	positionBg.y2 = positionBg.y2 + positionBg.ve1 * dt

	if positionBg.y > canvasHeigth then
		positionBg.y = positionBg.y2 - backgroundTwo:getHeight()
	end
	if positionBg.y2 > canvasHeigth then
		positionBg.y2 = positionBg.y - background:getHeight()
	end
end

function effect(dt)
	scaleX = scaleX - 3 * dt 
	scaleY = scaleY - 3 * dt

	if scaleX <= 1 then
		scaleX = 1
		scaleY = 1 
	end
end

function startGame(dt)
	if openScreen and not live then
		inOutX = inOutX + 800 * dt
		if inOutX > 481 then 
			inOutY = -701
			inOutX = 0
			live = true
		end
		elseif not openScreen then
			live = false
			inOutY = inOutY + 1000 * dt
			if inOutY > 0 then
			inOutY = 0
		end
	end
end

function love.keyreleased(key)
	if key == "p" and openScreen then
		pause = not pause
	end
	if pause then
		music:pause()
	else
		love.audio.resume(music)
	end
	if key == "b" and not gameOver and canExplode then 
		newExplosion = {}
		table.insert(explode, newExplosion)
		musicExplosion:play()
		loader = 0
		for i, _ in ipairs(enemies) do
			points = points + 1
		end
		enemies = {}
		canExplode = false
	end
end

function endGame(dt)
	pause = true
	music:stop()
	transparency = transparency + 100 * dt
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
end

function controlsExplosion(dt)
	for i, _ in ipairs(explode) do
		animation:update(dt)
	end
end

function bombaReady(dt)
	showNotice = showNotice + 0.5 * dt
	if showNotice >= 1 then
		showNotice = 0.8
	end
end

function destroy()
	for i, _ in ipairs (explode) do
		table.remove(explode, i)
	end
end

function controlsExplosionTwo(dt)
	for i, _ in ipairs(expEnemy) do
		destroyEnemy:update(dt)
	end
end

function destroyTwo()
	for i, _ in ipairs(expEnemy) do
		table.remove(expEnemy, i)
	end
end



