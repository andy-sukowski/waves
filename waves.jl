# See LICENSE file for copyright and license details.

import DSP

struct Field
	kernel::Array{Float64}
	deflection::Array{Float64}
	velocity::Array{Float64}
	resistence::Array{Float64}
end

# using inverse (n − 1)th power law
function gen_kernel(kdims::Int, sim_dims::Int, size::Int, σ::Float64)::Array{Float64}
	@assert size % 2 == 1
	# indices, with (0, 0, ...) as the center
	indices = Iterators.product(fill(-size÷2:size÷2, kdims)...)
	kernel = 1 ./ (xs -> sum(xs .^ 2)^(sim_dims-3)).(indices)
	center = fill(size ÷ 2 + 1, kdims)
	kernel[center...] = 0
	kernel[center...] = -sum(kernel)
	kernel ./= -kernel[center...]
	return kernel
end

# same convolution using DSP.conv()
function same_conv(a::Array{Float64}, k::Array{Float64})
	pad = (size(k) .- 1) .÷ 2
	region = range.(1 .+ pad, size(a) .+ pad)
	return DSP.conv(a, k)[region...]
end

function update!(field::Field)
	field.velocity .+= same_conv(field.deflection, field.kernel)
	field.deflection .+= field.velocity
	field.deflection .*= 1 .- field.resistence
	return nothing
end

# minimize border reflections
function dampen_border!(field::Field, margin::Int)
	for index in Iterators.product(range.(1, size(field.resistence))...)
		distance = min(index..., (size(field.resistence) .- index)...)
		if distance < margin
			# 0.995 was arbitrarily chosen
			field.resistence[index...] = 1 - 0.995^(margin - distance)
		end
	end
end
