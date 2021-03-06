function render!(fbuffer, hbuffer, cmap, hmap::Matrix{T}, pos::Tuple{T,T,T}, θ::T) where T<:Real
    # draw background (light blue sky)
    fill!(fbuffer, RGB24(0.529f0, 0.808f0, 0.980f0))
    fill!(hbuffer, WIN_HEIGHT)
    # precompute some constants
    w = Base.multiplicativeinverse(MAP_WIDTH%UInt)
    h = Base.multiplicativeinverse(MAP_HEIGHT%UInt)
    # compute orientation angle θ sine and cosine
    sθ, cθ = sincos(θ)
    # draw from front to back (low z coordinate to high z coordinate)
    @inbounds for z in 1 : VIEW_DIST
        # find view-line on map, this calculation corresponds to a field of view of 90°
        px = pos[1] - (cθ+sθ)*z; py = pos[2] - (cθ-sθ)*z
        # segment the line in equal increments
        dx = 2z*cθ/WIN_WIDTH; dy = -2z*sθ/WIN_WIDTH
        # compute local z-scale factor
        scale = ZSCALE/z
        # raster horizontal view-line and draw the vertical for each segment
        for j in 1 : WIN_WIDTH
            # compute map indices from px & py
            pxi = UInt(1) + rem(unsafe_trunc(Int, px)%UInt, w)
            pyi = UInt(1) + rem(unsafe_trunc(Int, py)%UInt, h)
            # compute the on-screen height of the feature
            height = unsafe_trunc(Int, muladd(pos[3]-hmap[pxi,pyi], scale, HORIZON))
            # assign color to column in framebuffer
            color = cmap[pxi,pyi]
            for i in max(height,1) : hbuffer[j]
                fbuffer[j,i] = color
            end
            # keep track of feature height
            hbuffer[j] = min(height, hbuffer[j])
            # move to next view-line feature position
            px += dx; py += dy
        end
    end
end

# "fisheye camera"
#ϕ = range(-π/4,π/4,length=WIN_WIDTH)
# compute position of feature
#if z > VIEW_DIST÷2
#    sθ, cθ = sincos(θ-ϕ[j])
#    px = pos[1] - sθ*z; py = pos[2] - cθ*z
#end
