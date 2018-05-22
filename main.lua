function idGenerator()
	local gened
	local chars={"1","2","3","4","5","6","7","8","9","0","a","b","c","d","e","f"}
	if generated==nil then
		generated={}
	end

	local contLoop=true
	while contLoop do
		gened=""
		for _=1,8 do
			gened=gened..chars[math.random(1,#chars)]
		end
		for i=1,#generated do
			if generated[i]==gened then
				contLoop=false
			end
		end
		contLoop=not contLoop
	end
	generated[#generated+1]=gened
	return gened
end

function roundToNearest( number, multiple )
  half = multiple/2
  return number+half - (number+half) % multiple;
end

slider={}
function slider.new(xPos,yPos,width,height,varName,lowerBound,upperBound,step,offset)
	local curID=idGenerator()
	if not offset then
		offset=0
	end
	if not step then
		step = 0.1
	end
	sliders[curID]={
		ID=ID,
		xPos=xPos,
		yPos=yPos,
		width=width,
		height=height,
		varName=varName,
		lowerBound=lowerBound-1,
		upperBound=upperBound-1,
		step=step,
		offset=offset
	}
	return curID
end

function distance ( x1, y1, x2, y2 )
	local dx = x1 - x2
	local dy = y1 - y2
 	return math.sqrt ( dx * dx + dy * dy )
end

function love.load()
	inch=0.0254
	currentText=""
	typed=false
	lastSlider=nil
	lastX=0
	lastY=0
	selectedSlider=nil
	winWidth,winHeight=love.graphics.getDimensions()
	math.randomseed(os.time())
	variables={
		r=50,
		b=128,
		g=1400000,
		test=750
	}

	var={}

	for k,v in pairs(variables) do
		var[k]=k
	end

	sliders={

	}

	sliderID={}
	sliderID.r    =slider.new(100,200,161,050,var.r   ,-50,0075,1)
	sliderID.g    =slider.new(100,275,161,050,var.g   ,000,2800000,1)
	sliderID.b    =slider.new(100,350,161,050,var.b   ,000,0255,1)
	sliderID.test =slider.new(400,100,375,050,var.test,500,1000,1)

	--PHYSICS START
	love.physics.setMeter(50)
	world=love.physics.newWorld(0,9.81*100,true)

	objects={}


	objects.ground={}
	objects.ground.body=love.physics.newBody(world,winWidth/2,winHeight-50/2)
	objects.ground.shape=love.physics.newRectangleShape(winWidth,50)
	objects.ground.fixture=love.physics.newFixture(objects.ground.body,objects.ground.shape)
	objects.ground.fixture:setFriction(0.95)



	objects.block={}
	objects.block.body=love.physics.newBody(world,winWidth/4*3,winHeight-50-74/2*inch*love.physics.getMeter()-25,"dynamic")
	objects.block.shape=love.physics.newRectangleShape( 1, 1, 81*inch*love.physics.getMeter(),130*inch*love.physics.getMeter(), math.rad(0) )
	objects.block.fixture=love.physics.newFixture(objects.block.body,objects.block.shape,5)
	blockX,blockY,blockMass,blockInertia=objects.block.body:getMassData( )
	objects.block.body:setMassData( blockX, blockY, 2656, 4289434 )
	blockX,blockY,blockMass,blockInertia=objects.block.body:getMassData( )
	objects.block.fixture:setFriction(0.95)
	objects.block.fixture:setRestitution(0)



	--PHYSICS END
end

function love.update(dt)
	if selectedSlider then
		local mouseX, mouseY = love.mouse.getPosition()
		if mouseX<sliders[selectedSlider].xPos+10 then
			mouseX=sliders[selectedSlider].xPos+10
		elseif mouseX>sliders[selectedSlider].xPos+sliders[selectedSlider].width-10 then
			mouseX=sliders[selectedSlider].xPos+sliders[selectedSlider].width-10
		end
		variables[sliders[selectedSlider].varName]=1+(mouseX-sliders[selectedSlider].xPos-10)*sliders[selectedSlider].pixVal+sliders[selectedSlider].lowerBound+1
	end

	--PHYSICS START
	world:update(dt*1)
	if love.keyboard.isDown("space") then
		objects.block.body:applyForce( variables.g, 0, objects.block.body:getX()-50, objects.block.body:getY()-25+variables.r-1 )
	end



	--PHYSICS END
end

function drawSliders()
	for k,v in pairs(sliders) do
		local currentID = k
		local currentSlider=sliders[currentID]
		love.graphics.setColor(255,255,255)
		if currentSlider.varName==var.r then
			love.graphics.setColor(variables.r,0,0)
		elseif currentSlider.varName==var.g then
			love.graphics.setColor(0,variables.g,0)
		elseif currentSlider.varName==var.b then
			love.graphics.setColor(0,0,variables.b)
		end
		
		love.graphics.rectangle("fill", sliders[currentID].xPos, sliders[currentID].yPos, sliders[currentID].width, sliders[currentID].height)
		love.graphics.setColor(255,0,0)
		local pcent=(variables[sliders[currentID].varName]-sliders[currentID].lowerBound)/(sliders[currentID].upperBound-sliders[currentID].lowerBound)
		love.graphics.circle("fill",sliders[currentID].xPos+10+pcent*(sliders[currentID].width-20) , sliders[currentID].yPos+sliders[currentID].height/2, 10)
		sliders[currentID].circX=sliders[currentID].xPos+10+pcent*(sliders[currentID].width-20)
		sliders[currentID].circY=sliders[currentID].yPos+sliders[currentID].height/2
		sliders[currentID].pixVal=(sliders[currentID].upperBound-sliders[currentID].lowerBound)/(sliders[currentID].width-20)
		variables[sliders[currentID].varName]=roundToNearest(variables[sliders[currentID].varName],sliders[currentID].step) --what is wrong
	end
	love.graphics.setColor(255,255,255)
end

function love.draw()
	drawSliders()
	
	if selectedSlider then
		love.graphics.print(selectedSlider,400,315)
	end
	cnt=1
	for k,v in pairs(variables) do
		love.graphics.print(k..": "..(v-1), 400, 315+15*cnt)
		cnt=cnt+1
	end--if love.keyboard.isDown("space")
	cenX,cenY=objects.block.body:getWorldCenter()
	love.graphics.print("lastX: "..lastX,400,315+15*(cnt)) cnt=cnt+1
	love.graphics.print("lastY: "..lastY,400,315+15*(cnt)) cnt=cnt+1
	love.graphics.print("winWidth: "..winWidth,400,315+15*(cnt)) cnt=cnt+1
	love.graphics.print("winHeight: "..winHeight,400,315+15*(cnt)) cnt=cnt+1
	love.graphics.print("cenX: "..cenX,400,315+15*(cnt)) cnt=cnt+1
	love.graphics.print("cenY: "..cenY,400,315+15*(cnt)) cnt=cnt+1
	if love.keyboard.isDown("space") then
		love.graphics.print("space",400,315+15*(cnt)) cnt=cnt+1
	end
	if blockInertia then
		love.graphics.print("blockInertia: "..blockInertia,400,315+15*(cnt)) cnt=cnt+1
	end
	love.graphics.setColor(255,255,255)

	--PHYSICS START
	love.graphics.setColor(math.floor(0.28*255+0.5), math.floor(0.63*255+0.5), math.floor(0.05*255+0.5)) 
	love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))

	love.graphics.setColor(255,255,255)
	love.graphics.polygon("fill", objects.block.body:getWorldPoints(objects.block.shape:getPoints()))
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("fill", cenX-2, cenY-2, 4, 4)
	love.graphics.setColor(0,255,0)
	love.graphics.rectangle("fill",objects.block.body:getX()-50-2,objects.block.body:getY()-25+variables.r-1,4,4)

	--PHYSICS END
end

function love.mousepressed(x,y,button)
	for k,v in pairs(sliders) do
		if distance(x,y,v.circX,v.circY) <= 10 then
			selectedSlider=k
			lastSlider=k
			typed=false
			break
		end
	end
end

function love.mousereleased(x,y,button)
	selectedSlider=nil
	lastX=x
	lastY=y
end

function love.keypressed(key)
	if key == "0" or key == "1" or key == "2" or key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" or key == "9" then
		if lastSlider then
			if typed==false then
				currentText=""
				typed=true
			end
			currentText=currentText..key
		end
	end
	if key=="return" then
		if typed then
			if tonumber(currentText)>=sliders[lastSlider].lowerBound and tonumber(currentText)<=sliders[lastSlider].upperBound then
				variables[sliders[lastSlider].varName]=currentText+1
			end
			currentText=""
			typed=false
		end
	end
end