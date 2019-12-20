-- Edge Detection

function average(gradX, gradY, rows, cols)
	local resImg = {}
	for i = 1, rows do
		resImg[i] = {}
		for j = 1, cols do
			local lum = math.sqrt(gradX[i][j].lum*gradX[i][j].lum + gradY[i][j].lum*gradY[i][j].lum)
			r, g, b, a, _ = unpack(gradX[i][j])
			
			resImg[i][j] = {red=r, green=g, blue=b, alpha=a, lum=lum}
		end
	end
	return resImg
end

function weightedSum(cutout, kernel)
	local lum = 0
	for i = 1, 3 do
		for j = 1, 3 do
			lum = lum + cutout[i][j]*kernel[i][j]
		end
	end
	return lum
end

function convolve(image, kernel, rows, cols)
	local gradImg = {}
	local crop = #kernel - 1
	local kRadius = math.floor(kRadius/2.0)
	
	for i = 1, rows-crop do
		gradImg[i] = {}
		for j = 1, cols-crop do
		
			local cutout = {}
			for r = 0, crop do
				cutout[r+1] = {}
				for c = 0, crop do
					cutout[r+1][c+1] = image[i+r][j+c].lum
				end
			end
			
			r, g, b, a, _ = unpack(image[i+kRadius][j+kRadius])
			gradImg[i][j] = {red=r, green=g, blue=b, alpha=a, lum=weightedSum(cutout, kernel)}
		end
	end
	return gradImg
end

function generateGaussian(kernel, dim, radius)
	stdev = 1.0
	pi = 355.0/113.0
	constant = 1.0/(2.0*pi*math.pow(stdev, 2))
	
	for i = -radius, radius do
		kernel[i+radius+1] = {}
		for j = -radius, radius do
			kernel[i+radius+1][j+radius+1] = constant*(1.0/math.exp( (math.pow(i,2)+math.pow(j,2)) / (2*math.pow(stdev,2)) ))
		end
	end
end

function love.load()
	love.window.setMode(400, 600)
	
	kGaussian = {}
	kDim = 3
	kRadius = math.floor(kDim/2.0)
	generateGaussian(kGaussian, kDim, kRadius)

	kX = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}}
	kY = {{1, 2, 1}, {0, 0, 0}, {-1, -2, -1}}

	origImg = love.image.newImageData("rose.png") -- w=400 h=600
	rows = origImg:getHeight() - 1
	cols = origImg:getWidth() - 1
	
	arrImg = {}
	for i = 1, rows do
		arrImg[i] = {}
		for j = 1, cols do
			r, g, b, a = origImg:getPixel(j-1, i-1) -- LOVE2D uses (x,y) coords, not row-major order
			if a  == 0 then
				r = 0
				g = 0
				b = 0
			end
			local lum = 0.2126*r + 0.7152*g + 0.0722*b
			arrImg[i][j] = {red=r, green=g, blue=b, alpha=a, lum=lum}
		end
	end
	
	blurImg = convolve(arrImg, kGaussian, rows, cols)
	rows = #blurImg - 1
	cols = #blurImg[1] - 1
	
	gradX = convolve(blurImg, kX, rows, cols)
	gradY = convolve(blurImg, kY, rows, cols)
	rows = #gradX - 1
	cols = #gradX[1] - 1
	
	resImg = average(gradX, gradY, rows, cols)
	
	points = {}
	for i = 1, rows do
		for j = 1, cols do
			local lum = resImg[i][j].lum
			table.insert(points, {j-1, i-1, lum, lum, lum, a})
		end
	end
end

function love.draw()
	love.graphics.points(points)
end

function love.conf(t)
	t.console = true
end