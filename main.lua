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
	for i = 1, rows-crop do
		gradImg[i] = {}
		for j = 1, cols-crop do
			local cutout = {}
			cutout[1] = {image[i][j].lum, image[i][j+1].lum, image[i][j+2].lum}
			cutout[2] = {image[i+1][j].lum, image[i+1][j+1].lum, image[i+1][j+2].lum}
			cutout[3] = {image[i+2][j].lum, image[i+2][j+1].lum, image[i+2][j+2].lum}
			
			r, g, b, a, _ = unpack(image[i+1][j+1])
			gradImg[i][j] = {red=r, green=g, blue=b, alpha=a, lum=weightedSum(cutout, kernel)}
		end
	end
	return gradImg
end

function love.load()
	love.window.setMode(400, 600)

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
			local lum = 0.2126*r + 0.7152*g + 0.0722*b
			arrImg[i][j] = {red=r, green=g, blue=b, alpha=a, lum=lum}
		end
	end
	
	gradX = convolve(arrImg, kX, rows, cols)
	gradY = convolve(arrImg, kY, rows, cols)
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