# keyboard & mouse callbacks for controls
const mov_forward = Ref(false)
const mov_left = Ref(false)
const mov_right = Ref(false)
const mov_back = Ref(false)
const mov_up = Ref(false)
const mov_down = Ref(false)
const mov_boost = Ref(false)

function key_cb_fun(window, key, _, action)
    if key == MiniFB.KB_KEY_W # up
        mov_forward[] = action
    elseif key == MiniFB.KB_KEY_A # left
        mov_left[] = action
    elseif key == MiniFB.KB_KEY_D # right
        mov_right[] = action
    elseif key == MiniFB.KB_KEY_S # down
        mov_back[] = action
    elseif key == MiniFB.KB_KEY_SPACE # space
        mov_up[] = action
    elseif key == MiniFB.KB_KEY_LEFT_CONTROL # l-ctrl
        mov_down[] = action
    elseif key == MiniFB.KB_KEY_LEFT_SHIFT # l-shift
        mov_boost[] = action
    elseif key == MiniFB.KB_KEY_ESCAPE
        mfb_close(window)
    end
    return nothing
end


const mouse_pos = Int32[0,0]
const mouse_mov = Int32[0,0]

function mouse_cb_fun(window, x, y)
    mouse_mov .= (x,y) .- mouse_pos
    mouse_pos .= (x,y)
    return nothing
end


function compute_movement!(θ)
    # mouse
    dθ = -mouse_mov[1]*1f-2
    fill!(mouse_mov, zero(Int32))
    # keyboard; signs empirically adjusted...
    sθ, cθ = sincos(θ)
    dx = (mov_right[]-mov_left[])*cθ - (mov_forward[]-mov_back[])*sθ
    dy = -(mov_right[]-mov_left[])*sθ - (mov_forward[]-mov_back[])*cθ
    dz = (mov_up[]-mov_down[])
    n = dx>0 ? 1f0/hypot(dx,dy) : 1f0
    return dx*n*(1 + mov_boost[]), dy*n*(1 + mov_boost[]), dz, dθ
end
