function love.load()
	math.randomseed(os.time())
	variables={
		x=5
	}

	var={
		x="x"
	}

	sliders={

	}
end

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

function newSlider(xPos,yPos,width,height,varName,lowerBound,upperBound,step)
	local curID=idGenerator()
	if not step then
		step = 0.1
	end
	sliders[curID]={
		xPos=xPos,
		yPos=yPos,
		width=width,
		height=height,

	}
	return curID
end

function love.update(dt)

end

function love.draw()
	love.graphics.print(idGenerator(), 300, 300)
end