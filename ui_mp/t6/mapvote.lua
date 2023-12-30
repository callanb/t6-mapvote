Engine.SetDvar("mapvote_client_vote_time", 0)
Engine.SetDvar("mapvote_client_end_time", 0)
Engine.SetDvar("mapvote_client_option_0", "")
Engine.SetDvar("mapvote_client_option_1", "")
Engine.SetDvar("mapvote_client_option_2", "")

LUI.createMenu.mapvote = function (_)
    local mapvoteMenu = CoD.Menu.NewFromState("mapvote", LUI.UIElement.ContainerState)
    mapvoteMenu:setBackOutSFX("cac_cmn_backout")
    Engine.PlaySound("cac_main_exit_cac") --TODO: What sound is played when ingame menus open?

    mapvoteMenu.title = LUI.UIText.new()
    mapvoteMenu.title:setLeftRight(false, false, -457, 175)
	mapvoteMenu.title:setTopBottom(true, false, 122, 166)
    mapvoteMenu.title:setText(UIExpression.ToUpper(nil, Engine.Localize("MPUI_MAPVOTINGPROGRESS")))
    mapvoteMenu.title:setFont(CoD.fonts.Morris)
    mapvoteMenu.title:setAlignment(LUI.Alignment.Left)

    mapvoteMenu.timer = LUI.UIText.new()
    mapvoteMenu.timer:setLeftRight(false, false, 175, 457)
	mapvoteMenu.timer:setTopBottom(true, false, 122, 166)
	mapvoteMenu.timer:setFont(CoD.fonts.Morris)
	mapvoteMenu.timer:setAlignment(LUI.Alignment.Right)
	CoD.CountdownTimer.Setup(mapvoteMenu.timer, 0, true)
	mapvoteMenu.timer:setTimeLeft(tonumber(UIExpression.DvarInt(nil, "mapvote_client_vote_time")))

    mapvoteMenu.buttons = {
        [1] = CreateMapvoteButton(mapvoteMenu, "mapvote_left_pressed", 0, -457),
        [2] = CreateMapvoteButton(mapvoteMenu, "mapvote_middle_pressed", 1, -141),
        [3] = CreateMapvoteButton(mapvoteMenu, "mapvote_right_pressed", 2, 175)
    }

    mapvoteMenu:addElement(mapvoteMenu.title)
    mapvoteMenu:addElement(mapvoteMenu.timer)
    mapvoteMenu:addElement(mapvoteMenu.buttons[1])
    mapvoteMenu:addElement(mapvoteMenu.buttons[2])
    mapvoteMenu:addElement(mapvoteMenu.buttons[3])

    mapvoteMenu:registerEventHandler("mapvote_state", MapvoteStateHandler)
    mapvoteMenu:registerEventHandler("mapvote_complete", MapvoteCompleteHandler)

    return mapvoteMenu
end

function CreateMapvoteButton(menu, event, index, left)
    local map = UIExpression.DvarString(nil, "mapvote_client_option_" .. index)

    local button = LUI.UIButton.new(menu, event)
    button.left = left
	button:setLeftRight(false, false, left, left + 282)
    button:setTopBottom(true, false, 200, 632)

    button.imageStencil = LUI.UIElement.new()
    button.imageStencil:setLeftRight(true, true, 0, 0)
    button.imageStencil:setTopBottom(true, true, 0, 0)
    button.imageStencil:setUseStencil(true)
    button:addElement(button.imageStencil)

    button.image = LUI.UIImage.new()
    button.image:setLeftRight(true, false, -256, 512)
	button.image:setTopBottom(true, false, 0, 432)
    button.image:setImage(RegisterMaterial("loadscreen_" .. map))
    button.imageStencil:addElement(button.image)

    button.nameBackground = LUI.UIImage.new()
    button.nameBackground:setLeftRight(true, true, 0, 0)
	button.nameBackground:setTopBottom(false, true, -66, -22)
    button.nameBackground:setRGB(0, 0, 0)
    button.nameBackground:setAlpha(0.8)
    button:addElement(button.nameBackground)

    button.votesBackground = LUI.UIImage.new()
    button.votesBackground:setLeftRight(true, true, 0, 0)
	button.votesBackground:setTopBottom(false, true, -22, 0)
    button.votesBackground:setRGB(CoD.trueOrange.r, CoD.trueOrange.g, CoD.trueOrange.b, 0)
    button.votesBackground:setAlpha(0.8)
    button:addElement(button.votesBackground)

    button.name = LUI.UIText.new()
    button.name:setLeftRight(true, true, 0, 0)
	button.name:setTopBottom(false, true, -66, -22)
    button.name:setFont(CoD.fonts.Morris)
    button.name:setText(UIExpression.ToUpper(nil, Engine.Localize(UIExpression.TableLookup(nil, UIExpression.GetCurrentMapTableName(), 0, map, 3))))
    button:addElement(button.name)

    button.votes = LUI.UIText.new()
    button.votes:setLeftRight(true, true, 0, 0)
	button.votes:setTopBottom(false, true, -22, 0)
    button.votes:setFont(CoD.fonts.Morris)
    button.votes:setText("0%")
    button:addElement(button.votes)

	button.border = CoD.Border.new(1, CoD.trueOrange.r, CoD.trueOrange.g, CoD.trueOrange.b, 0)
	button:addElement(button.border)

    button.highlight = CoD.Border.new(1, CoD.trueOrange.r, CoD.trueOrange.g, CoD.trueOrange.b, 0)
	button:addElement(button.highlight)

    button.blackout = LUI.UIImage.new()
    button.blackout:setLeftRight(true, true, 0, 0)
    button.blackout:setTopBottom(true, true, 0, 0)
    button.blackout:setRGB(0, 0, 0)
    button.blackout:setAlpha(0)
    button:addElement(button.blackout)

    button:registerEventHandler("button_over", MapvoteButtonOverHandler)
    button:registerEventHandler("button_up", MapvoteButtonUpHandler)
    menu:registerEventHandler(event, MapvoteButtonPressedHandler(index))

    return button
end

function MapvoteButtonOverHandler(button, _)
    button.border:setAlpha(0.8)
    button.nameBackground:setLeftRight(true, true, 2, -2)
    button.votesBackground:setLeftRight(true, true, 2, -2)
	button.votesBackground:setTopBottom(false, true, -22, -2)
end

function MapvoteButtonUpHandler(button, _)
    button.border:setAlpha(0)
    button.nameBackground:setLeftRight(true, true, 0, 0)
    button.votesBackground:setLeftRight(true, true, 0, 0)
	button.votesBackground:setTopBottom(false, true, -22, 0)
end

function MapvoteButtonPressedHandler(index)
    return function(_, _)
        Engine.SendMenuResponse(0, "mapvote", index)
    end
end

function MapvoteStateHandler(menu, clientInstance)
    menu.buttons[1].votes:setText(clientInstance.data[1] .. "%")
    menu.buttons[2].votes:setText(clientInstance.data[2] .. "%")
    menu.buttons[3].votes:setText(clientInstance.data[3] .. "%")
end

function MapvoteCompleteHandler(menu, clientInstance)
    menu.title:setText(UIExpression.ToUpper(nil, Engine.Localize("MENU_MATCH_WILL_BEGIN")))

    MapvoteButtonDisable(menu.buttons[1])
    MapvoteButtonDisable(menu.buttons[2])
    MapvoteButtonDisable(menu.buttons[3])

    local votedMapIndex = clientInstance.data[1]

    menu.buttons[votedMapIndex]:processEvent({name = "button_over"})
    menu.buttons[votedMapIndex]:registerEventHandler("button_over", nil)
    menu.buttons[votedMapIndex]:registerEventHandler("button_up", nil)

    if votedMapIndex ~= 2 then
        MapvoteButtonSwap(menu.buttons[votedMapIndex], menu.buttons[2])
    end

    for index, button in pairs(menu.buttons) do
        if index ~= votedMapIndex then
            MapvoteButtonBlackout(button)
        end
    end

    menu:registerEventHandler("mapvote_close", MapvoteClose)
    menu:addElement(LUI.UITimer.new(tonumber(UIExpression.DvarInt(nil, "mapvote_client_end_time")), {name = "mapvote_close"}, true))
end

function MapvoteButtonDisable(button)
    button:processEvent({name = "disable"})
	button.m_focusable = nil
	-- if button.navigation.up then
	-- 	button.navigation.up:setLayoutCached(false)
	-- end
	-- if button.navigation.down then
	-- 	button.navigation.down:setLayoutCached(false)
	-- end
end

function MapvoteButtonBlackout(button)
    button.blackout:beginAnimation("button_blackout", 250)
    button.blackout:setAlpha(0.5)
end

function MapvoteButtonSwap(button1, button2)
    local left1 = button1.left
    button1.left = button2.left
    button2.left = left1
    button1:beginAnimation("button_swap", 250)
    button2:beginAnimation("button_swap", 250)
    button1:setLeftRight(false, false, button1.left, button1.left + 282)
    button2:setLeftRight(false, false, button2.left, button2.left + 282)
end

function MapvoteClose(menu, _)
    CoD.Menu.animateOutAndGoBack(menu)
end