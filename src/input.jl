# keyboard & mouse callbacks for controls
const mov_forward = Ref(false)
const mov_left = Ref(false)
const mov_right = Ref(false)
const mov_back = Ref(false)
const mov_up = Ref(false)
const mov_down = Ref(false)
const mov_boost = Ref(false)

function key_cb_fun(_, key, scancode, action, mods)
    if key == GLFW.KEY_W # up
        action == GLFW.PRESS   && (mov_forward[] = true)
        action == GLFW.RELEASE && (mov_forward[] = false)
    elseif key == GLFW.KEY_A # left
        action == GLFW.PRESS   && (mov_left[] = true)
        action == GLFW.RELEASE && (mov_left[] = false)
    elseif key == GLFW.KEY_D # right
        action == GLFW.PRESS   && (mov_right[] = true)
        action == GLFW.RELEASE && (mov_right[] = false)
    elseif key == GLFW.KEY_S # down
        action == GLFW.PRESS   && (mov_back[] = true)
        action == GLFW.RELEASE && (mov_back[] = false)
    elseif scancode == 57 # space
        action == GLFW.PRESS   && (mov_up[] = true)
        action == GLFW.RELEASE && (mov_up[] = false)
    elseif scancode == 29 # l-ctrl
        action == GLFW.PRESS   && (mov_down[] = true)
        action == GLFW.RELEASE && (mov_down[] = false)
    elseif scancode == 42 # l-shift
        action == GLFW.PRESS   && (mov_boost[] = true)
        action == GLFW.RELEASE && (mov_boost[] = false)
    end
    return nothing
end

const mouse_pos  = Float32[0,0]
const mouse_move = Float32[0,0]

function mouse_cb_fun(_, x, y)
    mouse_move .= (x,y) .- mouse_pos
    mouse_pos  .= (x,y)
    return nothing
end

function compute_movement!(θ)
    # mouse
    dθ = -mouse_move[1]*1f-2
    mouse_move .= 0f0
    # keyboard; signs empirically adjusted...
    sθ, cθ = sincos(θ)
    dx = (mov_right[]-mov_left[])*cθ - (mov_forward[]-mov_back[])*sθ
    dy = -(mov_right[]-mov_left[])*sθ - (mov_forward[]-mov_back[])*cθ
    dz = (mov_up[]-mov_down[])
    n = dx>0 ? 1f0/hypot(dx,dy) : 1f0
    return dx*n*(1 + mov_boost[]), dy*n*(1 + mov_boost[]), dz, dθ
end
