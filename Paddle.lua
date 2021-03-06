--[[
    This is CS50 2019.
    Games Track
    Pong

    -- Paddle Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a paddle that can move up and down. Used in the main
    program to deflect the ball back toward the opponent.
]]

Paddle = Class{}

--[[
    The `init` function on our class is called just once, when the object
    is first created. Used to set up all variables in the class and get it
    ready for use.

    Our Paddle should take an X and a Y, for positioning, as well as a width
    and height for its dimensions.

    Note that `self` is a reference to *this* object, whichever object is
    instantiated at the time this function is called. Different objects can
    have their own x, y, width, and height values, thus serving as containers
    for data. In this sense, they're very similar to structs in C.
]]
function Paddle:init(x, y, width, height, side)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
    self.ai = false
    self.ai_difficulty = 'easy'  -- 'easy', 'hard', 'impossible'
    self.side = side  -- 'left' or 'right'
end

--[[
    difficulty  description                 speed
    easy        tracks ball                 PADDLE_SPEED / 2
    med         computes ball position      PADDLE_SPEED / 2
                without bounce
    hard        computes ball position      PADDLE_SPEED / 2
                with bounce
    impossible  computes ball position      PADDLE_SPEED
                with bounce
 ]]
function Paddle:next_ai_state()
    if not self.ai then
        self.ai = true
        self.ai_difficulty = 'easy'
    elseif self.ai_difficulty == 'easy' then
        self.ai_difficulty = 'med'
    elseif self.ai_difficulty == 'med' then
        self.ai_difficulty = 'hard'
    elseif self.ai_difficulty == 'hard' then
        self.ai_difficulty = 'impossible'
    elseif self.ai_difficulty == 'impossible' then
        self.ai = false
    end
end

function Paddle:ai_update(ball)
    SET_SPEED = PADDLE_SPEED
    if self.ai_difficulty ~= 'impossible' then
        SET_SPEED = PADDLE_SPEED / 2
    end
    if self.ai_difficulty == 'easy' then
        -- track ball
        if self.y + self.height / 2 + 2 < ball.y + ball.height / 2 then
            self.dy = SET_SPEED
        elseif self.y + self.height / 2 - 2 > ball.y + ball.height / 2 then
            self.dy = -SET_SPEED
        else
            self.dy = 0
        end
    else  -- ai_difficulty is 'med', 'hard' or 'impossible'
        mult = self.side == 'left' and 1 or -1
        if (mult * ball.dx > 0) then
            -- go to middle
            if self.y + self.height / 2 + 2 < VIRTUAL_HEIGHT / 2 then
                self.dy = SET_SPEED
            elseif self.y + self.height / 2 - 2 > VIRTUAL_HEIGHT / 2 then
                self.dy = -SET_SPEED
            else
                self.dy = 0
            end
        else
            -- compute ball destination and go there
            -- uses slope-point equation of a line
            y_dest = (ball.dy / ball.dx) * (self.x - ball.x) + ball.y
            if self.ai_difficulty ~= 'med' then
                -- check bounce
                if y_dest < 0 then
                    y_dest = -y_dest
                    if y_dest > VIRTUAL_HEIGHT then
                        y_dest = 2 * VIRTUAL_HEIGHT - y_dest - ball.height
                    end
                end
                if y_dest > VIRTUAL_HEIGHT then
                    y_dest = 2 * VIRTUAL_HEIGHT - y_dest - ball.height
                    if y_dest < 0 then
                        y_dest = -y_dest
                    end
                end
            end
            -- center the paddle
            y_dest = y_dest - self.height / 2 + 1
            -- set speed
            if self.y + 2 < y_dest then
                self.dy = SET_SPEED
            elseif self.y - 2 > y_dest then
                self.dy = -SET_SPEED
            else
                self.dy = 0
            end
        end
    end
end

function Paddle:update(dt)
    -- math.max here ensures that we're the greater of 0 or the player's
    -- current calculated Y position when pressing up so that we don't
    -- go into the negatives; the movement calculation is simply our
    -- previously-defined paddle speed scaled by dt
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    -- similar to before, this time we use math.min to ensure we don't
    -- go any farther than the bottom of the screen minus the paddle's
    -- height (or else it will go partially below, since position is
    -- based on its top left corner)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

--[[
    To be called by our main function in `love.draw`, ideally. Uses
    LÖVE2D's `rectangle` function, which takes in a draw mode as the first
    argument as well as the position and dimensions for the rectangle. To
    change the color, one must call `love.graphics.setColor`. As of the
    newest version of LÖVE2D, you can even draw rounded rectangles!
]]
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end