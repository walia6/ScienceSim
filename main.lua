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
	currentText=""
	typed=false
	lastSlider=nil
	lastX=0
	lastY=0
	selectedSlider=nil
	math.randomseed(os.time())
	variables={
		r=128,
		b=128,
		g=128,
		test=750
	}

	var={}

	for k,v in pairs(variables) do
		var[k]=k
	end

	sliders={

	}

	sliderID={}
	sliderID.r    =slider.new(100,200,161,050,var.r   ,000,0255,1)
	sliderID.g    =slider.new(100,275,161,050,var.g   ,000,0255,1)
	sliderID.b    =slider.new(100,350,161,050,var.b   ,000,0255,1)
	sliderID.test =slider.new(400,100,375,050,var.test,500,1000,1)
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
	end
	love.graphics.print("lastX: "..lastX,400,315+15*(cnt))
	love.graphics.print("lastY: "..lastY,400,315+15*(cnt+1))
	love.graphics.setColor(variables.r-1, variables.g-1, variables.b-1)
	love.graphics.rectangle("fill", 300, 400, 100, 100)
	love.graphics.setColor(255,255,255)
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