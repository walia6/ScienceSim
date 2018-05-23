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
	debug=false
	if not bHeight then
		love.window.setMode(1920, 1080,{fullscreen=true})
	end
	inch=0.0254
	bHeight=bHeight or 161
	bWidth=bWidth or 100
	bCOM=bCOM or 90

	cHeight=bHeight
	cWidth=bWidth
	cCOM=bCOM

	currentText=""
	typed=false
	lastSlider=nil
	lastX=0
	lastY=0
	selectedSlider=nil
	winWidth,winHeight=love.graphics.getDimensions()
	math.randomseed(os.time())
	variables={
		impactPoint=50,
		impactForce=1400000,
		Height=bHeight,
		Width=bWidth,
		centerOfMass=bCOM
	}

	var={}

	for k,v in pairs(variables) do
		var[k]=k
	end

	sliders={

	}

	sliderID={}
	sliderID.impactPoint    =slider.new(winWidth-200,050,161,030,var.impactPoint,  0,     99,1)
	sliderID.impactForce    =slider.new(winWidth-200,100,161,030,var.impactForce,  0,5250000,1)
	sliderID.Width          =slider.new(winWidth-200,150,161,030,var.Width,       30,    300,1)
	sliderID.Height         =slider.new(winWidth-200,200,161,030,var.Height,      30,    300,1)
	sliderID.centerOfMass   =slider.new(winWidth-200,250,161,030,var.centerOfMass,10,     90,1)



	--PHYSICS START
	beginTime=false

	love.physics.setMeter(50)
	world=love.physics.newWorld(0,9.81*100,true)

	objects={}


	objects.ground={}
	objects.ground.body=love.physics.newBody(world,winWidth/2,winHeight-50/2)
	objects.ground.shape=love.physics.newRectangleShape(winWidth,50)
	objects.ground.fixture=love.physics.newFixture(objects.ground.body,objects.ground.shape)
	objects.ground.fixture:setFriction(5)



	objects.block={}
	objects.block.body=love.physics.newBody(world,winWidth/4*1,cHeight*inch*love.physics.getMeter(),"dynamic")
	objects.block.shape=love.physics.newRectangleShape( 1, 1, cWidth*inch*love.physics.getMeter(),cHeight*inch*love.physics.getMeter(), math.rad(0) )
	objects.block.fixture=love.physics.newFixture(objects.block.body,objects.block.shape,5)
	blockX,blockY,blockMass,blockInertia=objects.block.body:getMassData( )
	love.system.setClipboardText((winWidth/4*1)..", "..(cHeight*inch*love.physics.getMeter())..("\n"..blockX..", "..(blockY-(cCOM/100-0.5)*cHeight*inch*love.physics.getMeter())..", "..2560))
	objects.block.body:setMassData( blockX, blockY-(cCOM/100-0.5)*cHeight*inch*love.physics.getMeter(), 0.08*cWidth*cHeight, 42894000*1.5*(0.5*cHeight+0.5*cWidth)/110 )
	blockX,blockY,blockMass,blockInertia=objects.block.body:getMassData( )
	objects.block.fixture:setFriction(5)
	objects.block.fixture:setRestitution(0)



	--PHYSICS END
end

function love.update(dt)
	bHeight,bWidth,bCOM=variables.Height,variables.Width,variables.centerOfMass
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
		objects.block.body:applyForce( variables.impactForce, 0, objects.block.body:getX()-cWidth/2*1.25, objects.block.body:getY()-(variables.impactPoint/100-0.5)*cHeight*inch*love.physics.getMeter() )
	end



	--PHYSICS END
end

function drawSliders()
	for k,v in pairs(sliders) do
		local currentID = k
		local currentSlider=sliders[currentID]
		love.graphics.setColor(255,255,255)
		
		love.graphics.rectangle("fill", sliders[currentID].xPos, sliders[currentID].yPos, sliders[currentID].width, sliders[currentID].height)
		love.graphics.setColor(255,0,0)
		local pcent=(variables[sliders[currentID].varName]-sliders[currentID].lowerBound)/(sliders[currentID].upperBound-sliders[currentID].lowerBound)
		love.graphics.circle("fill",sliders[currentID].xPos+10+pcent*(sliders[currentID].width-20) , sliders[currentID].yPos+sliders[currentID].height/2, 10)
		sliders[currentID].circX=sliders[currentID].xPos+10+pcent*(sliders[currentID].width-20)
		sliders[currentID].circY=sliders[currentID].yPos+sliders[currentID].height/2
		sliders[currentID].pixVal=(sliders[currentID].upperBound-sliders[currentID].lowerBound)/(sliders[currentID].width-20)
		variables[sliders[currentID].varName]=roundToNearest(variables[sliders[currentID].varName],sliders[currentID].step) --what is wrong
		love.graphics.setColor(255,255,255)
		love.graphics.printf(sliders[currentID].varName..": "..(variables[sliders[currentID].varName]-1), sliders[currentID].xPos, sliders[currentID].yPos-15, sliders[currentID].width, "center")
	end
	love.graphics.setColor(255,255,255)
end

function love.draw()
	drawSliders()
	
	if selectedSlider then
		love.graphics.print(selectedSlider,15,10)
	end
	if not debug then
		TEMPPRINT=love.graphics.print
		function love.graphics.print()
		end
	end
	cnt=1
	for k,v in pairs(variables) do
		love.graphics.print(k..": "..(v-1), 15,10+15*cnt)
		cnt=cnt+1
	end--if love.keyboard.isDown("space")
	cenX,cenY=objects.block.body:getWorldCenter()
	love.graphics.print("lastX: "..lastX,15,10+15*(cnt)) cnt=cnt+1
	love.graphics.print("lastY: "..lastY,15,10+15*(cnt)) cnt=cnt+1
	love.graphics.print("winWidth: "..winWidth,15,10+15*(cnt)) cnt=cnt+1
	love.graphics.print("winHeight: "..winHeight,15,10+15*(cnt)) cnt=cnt+1
	love.graphics.print("cenX: "..cenX,15,10+15*(cnt)) cnt=cnt+1
	love.graphics.print("cenY: "..cenY,15,10+15*(cnt)) cnt=cnt+1
	if love.keyboard.isDown("space") then
		love.graphics.print("space",15,10+15*(cnt)) cnt=cnt+1
	end
	if blockInertia then
		love.graphics.print("blockInertia: "..blockInertia,15,10+15*(cnt)) cnt=cnt+1
	end
	love.graphics.print("time: "..(os.clock()),15,10+15*(cnt)) cnt=cnt+1
	love.graphics.print(130*inch*love.physics.getMeter(),15,10+15*(cnt)) cnt=cnt+1
	if not debug then
		love.graphics.print=TEMPPRINT
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
	love.graphics.line(objects.block.body:getX()-cWidth/2*1.25-2-50, objects.block.body:getY()-(variables.impactPoint/100-0.5)*cHeight*inch*love.physics.getMeter()-2, objects.block.body:getX()-cWidth/2*1.25-2, objects.block.body:getY()-(variables.impactPoint/100-0.5)*cHeight*inch*love.physics.getMeter()-2)
	love.graphics.line(objects.block.body:getX()-cWidth/2*1.25,objects.block.body:getY()-(variables.impactPoint/100-0.5)*cHeight*inch*love.physics.getMeter(),objects.block.body:getX()-cWidth/2*1.25-15,objects.block.body:getY()-(variables.impactPoint/100-0.5)*cHeight*inch*love.physics.getMeter()-15)
	love.graphics.line(objects.block.body:getX()-cWidth/2*1.25,objects.block.body:getY()-(variables.impactPoint/100-0.5)*cHeight*inch*love.physics.getMeter(),objects.block.body:getX()-cWidth/2*1.25-15,objects.block.body:getY()-(variables.impactPoint/100-0.5)*cHeight*inch*love.physics.getMeter()+15)
	love.graphics.setColor(0,0,255)
	love.graphics.rectangle("fill",objects.block.body:getX()-2,objects.block.body:getY()-2,4,4)

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

	if key=="r" then
		love.load()
	end
end