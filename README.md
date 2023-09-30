# Wave simulation

An n-dimensional wave simulator, written in Julia. Try it, by running
[`examples/interference.jl`][1].

## Usage

First, fill the `Field` structure with a kernel, as well as an array for
the deflection, velocity and resistance.

```julia
include("waves.jl")

height = 512
width = 512
field = Field(
	gen_kernel(2, 3, 5, 1.0),
	zeros(height, width),
	zeros(height, width),
	fill(0.005, height, width)
)
```

Optionally, to minimize border reflections, the `dampen_border!()`
function can be called, which adds an exponential gradient to the edge
of the resistance field.

```julia
dampen_border!(field, 40)
```

Then modify `field.deflection` and `field.resistance` to add waves and
obsticals. You might want to save the simulation to a video, as is the
case in [`examples/interference.jl`][1].

```julia
field.resistance[256:320, 256:320] .= 1

for t in 0:500
	field.deflection[128, 128] = sin(t / 8)
	update!(field)
end
```

[1]: ./examples/interference.jl
