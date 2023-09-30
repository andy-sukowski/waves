# See LICENSE file for copyright and license details.

using Images
using ProgressMeter
using VideoIO

include("../waves.jl")

height = 512
width = 512
field = Field(
	gen_kernel(2, 3, 5, 1.0),
	zeros(height, width),
	zeros(height, width),
	fill(0.005, height, width)
)

dampen_border!(field, 40)

σ(x) = 1 / (1 + exp(-x))

open_video_out("interference.mkv", RGB{N0f8}, (height, width)) do writer
	@showprogress "Simulating waves..." for t in 0:1200
		field.deflection[400, 180] = sin(t / 8)
		field.deflection[400, 332] = sin(t / 8)
		update!(field)

		if t % 5 == 0 # only write every 5th iteration to video
			write(writer, RGB{N0f8}.(σ.(field.deflection * 8)))
		end
	end
end
