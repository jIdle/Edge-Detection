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

-- New weightedSum function
function weightedSum(cutout, kernel)
	local kRows, kCols = #kernel, #kernel[1]
	local r, g, b, lum = 0, 0, 0, 0
	
	for i = 1, kRows do
		for j = 1, kCols do
			r = r + cutout[i][j].red * kernel[i][j]
			g = g + cutout[i][j].green * kernel[i][j]
			b = b + cutout[i][j].blue * kernel[i][j]
			lum = lum + cutout[i][j].lum * kernel[i][j]
		end
	end
	
	local center = (#cutout-1)/2
	return {red=r, green=g, blue=b, alpha=cutout[center][center].alpha, lum=lum}
end

-- New convolve function
function convolve(image, kernel)
	local rows, cols = #image - 1, #image[1] - 1
	local toCrop = #kernel - 1
	local kRadius = toCrop/2
	
	local result = {}
	
	for i = 1, (rows - toCrop) do
		result[i] = {}
		for j = 1, (cols - toCrop) do
			local cutout = {}
			for h = 1, #kernel do
				cutout[h] = {}
				for k = 1, #kernel do
					cutout[h][k] = image[i+(h-1)][j+(k-1)] -- Image offset is -1
				end
			end
			result[i][j] = weightedSum(cutout, kernel)
		end
	end
	return result
end

function generateGaussian(kernel, radius)
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
	generateGaussian(kGaussian, kRadius)

	kX = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}}
	kY = {{1, 2, 1}, {0, 0, 0}, {-1, -2, -1}}

	origImg = love.image.newImageData("rose.png") -- w=400 h=600
	rows = origImg:getHeight() - 1
	cols = origImg:getWidth() - 1
	
	-- Initialize image matrix
	arrImg = {}
	for i = 1, rows do
		arrImg[i] = {}
		for j = 1, cols do
			r, g, b, a = origImg:getPixel(j-1, i-1) -- LOVE2D uses (x,y) coords, not row-major order
			if a == 0 then
				r = 0
				g = 0
				b = 0
			end
			local lum = 0.2126*r + 0.7152*g + 0.0722*b
			arrImg[i][j] = {red=r, green=g, blue=b, alpha=a, lum=lum}
		end
	end
	
	blurImg = convolve(arrImg, kGaussian)
	
	gradX = convolve(blurImg, kX)
	gradY = convolve(blurImg, kY)
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