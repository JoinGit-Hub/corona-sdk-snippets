---

--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

-- Standard library imports --
local exit = os.exit

-- Modules --
local common = require("editor.Common")
local dispatch_list = require("game.DispatchList")
local layout = require("ui.Layout")
local scenes = require("game.Scenes")

-- Corona globals --
local system = system

-- Corona modules --
local storyboard = require("storyboard")

-- Use graceful exit method on Android.
if system.getInfo("platformName") == "Android" then
	exit = native.requestExit
end

-- Title scene --
local Scene = storyboard.newScene()

-- Samples names --
local Names = {
	"Curves",
	"Hilbert",
	"Marching",
	"Nodes",
	"SlowMo",
	"Thoughts",
	"Tiling",
	"Timers",
	"Game",
	"Editor"
}

--
local function SetCurrent (current, index)
	current.text = "Current: " .. Names[index]

	current.m_id = index
end

--
function Scene:createScene ()
	local Choices = common.Listbox(self.view, 20, 20)
	local Current = display.newText(self.view, "", 480, 50, native.systemFont, 35)

	local add_row = common.ListboxRowAdder(function(index)
		SetCurrent(Current, index)
	end, nil, function(index)
		return Names[index]
	end)

	for _ = 1, #Names do
		Choices:insertRow(add_row)
	end

	SetCurrent(Current, 1)

	layout.VBox(self.view, nil, false, display.contentCenterY, 400, 50, 25,
		function()
			local name = Names[Current.m_id]

			if name == "Game" then
				storyboard.gotoScene("scene.Level", { params = 1 })
			elseif name == "Editor" then
				storyboard.gotoScene("scene.EditorSetup", "fade") -- Corona bug? Without some effect, doesn't work on second try...
			else
				storyboard.gotoScene("samples." .. name)
			end
		end, "Launch",
		scenes.Opener{ name = "scene.Options", "zoomInOutFadeRotate", "fade", "fromTop" }, "Options",
		function()
			if system.getInfo("environment") == "device" then
				exit()
			end
		end, "Exit"
	)
end

Scene:addEventListener("createScene")

--
function Scene:enterScene ()
	-- First time on title screen, this session?
	local prev = storyboard.getPrevious()

	if prev == "scene.Intro" or prev == "scene.Level" then
		dispatch_list.CallList("enter_menus")
		-- ????
	end
end

Scene:addEventListener("enterScene")

return Scene