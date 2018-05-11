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

slider={}
function slider.new(xPos,yPos,width,height,varName,lowerBound,upperBound,step)
	local curID=idGenerator()
	if not step then
		local step = 0.1
	end
	sliders[curID]={
		ID=ID,
		xPos=xPos,
		yPos=yPos,
		width=width,
		height=height,
		varName=varName,
		lowerBound=lowerBound,
		upperBound=upperBound,
		step=step
	}
	return curID
end

function love.load()
	math.randomseed(os.time())
	variables={
		x=50
	}

	var={}

	for k,v in pairs(variables) do
		var[k]=k
	end

	sliders={

	}

	sliderID={}

	sliderID.x=slider.new(100,200,161,50,var.x,1,100)
end

function love.update(dt)

end

function drawSliders()
	for k,v in pairs(sliders) do
		local currentID = k
		local currentSlider=sliders[currentID]
		love.graphics.setColor(255,255,255)
		love.graphics.rectangle("fill", currentSlider.xPos, currentSlider.yPos, currentSlider.width, currentSlider.height)
		love.graphics.setColor(255,0,0) 
		local pcent=(variables[currentSlider.varName]-currentSlider.lowerBound)/(currentSlider.upperBound-currentSlider.lowerBound)
		love.graphics.circle("fill",currentSlider.xPos+10+pcent*(currentSlider.width-20) , currentSlider.yPos+currentSlider.height/2, 10)
	end
	love.graphics.setColor(255,255,255)
end

function love.draw()
	love.graphics.print(variables.x, 400, 300)
	drawSliders()
end

function love.mouse