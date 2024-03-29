local isDebugging = false

-- load debugger
local function startDebugger()
  env.info("attempting to load debugger")
  local json = dofile("C:\\BTI\\TFL\\dkjson.lua")
  local debuggee = dofile("C:\\BTI\\TFL\\vscode-debugee.lua")
  local startResult, breakerType = debuggee.start(json)
  --print('debuggee start ->', startResult, breakerType)
  env.info('debuggee start -> ' .. tostring(startResult) .. ", " .. breakerType)

  -- poll debugger
  function PollDebugger()
      --env.info("poll")
      timer.scheduleFunction(PollDebugger, {}, timer.getTime() + 0.001)    --reschedule first in case of Lua error
      debuggee.poll()
  end

  timer.scheduleFunction(PollDebugger, {}, timer.getTime() + 0.001)    --reschedule first in case of Lua error
end

if isDebugging then
  startDebugger()
end
-- load mission scripts
dofile("C:\\BTI\\TFL\\TFLUtils.lua")
dofile("C:\\BTI\\TFL\\TFLGame.lua")
dofile("C:\\BTI\\TFL\\TFLStore.lua")

-- local function checkLuaMem()
--   env.info("BENCHMARK - MEMORY USAGE: " ..string.format("%.2f MB", collectgarbage("count")/1000))
--   trigger.action.outText("BENCHMARK - MEMORY USAGE: " ..string.format("%.2f MB", collectgarbage("count")/1000), 5)
--   timer.scheduleFunction(checkLuaMem, nil, timer.getTime() + 5)
-- end
-- checkLuaMem()