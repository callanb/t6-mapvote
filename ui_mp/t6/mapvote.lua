Engine.SetDvar("mapvote_option_0", "")
Engine.SetDvar("mapvote_option_1", "")
Engine.SetDvar("mapvote_option_2", "")

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
	mapvoteMenu.timer:setTimeLeft(5000)

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
    local map = UIExpression.DvarString(nil, "mapvote_option_" .. index)

    local button = LUI.UIButton.new(menu, event)
	button:setLeftRight(false, false, left, left + 282)
    button:setTopBottom(true, false, 200, 632)
	button:setUseStencil(true)

    button:registerEventHandler("button_over", MapvoteButtonOverHandler)
    button:registerEventHandler("button_up", MapvoteButtonUpHandler)

    button.image = LUI.UIImage.new()
    button.image:setLeftRight(true, false, -256, 512)
	button.image:setTopBottom(true, false, 0, 432)
    button.image:setImage(RegisterMaterial("loadscreen_" .. map))
    button:addElement(button.image)

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

function MapvoteCompleteHandler(menu, _)
    menu.title:setText(UIExpression.ToUpper(nil, Engine.Localize("MENU_MATCH_WILL_BEGIN")))
    CoD.Menu.animateOutAndGoBack(menu)
end

-- CoD.MapVoter.FadeAndExpandButton = function (mapButton, fadeTimeMs)
-- 	CoD.MapVoter.DisableButton(mapButton)
-- 	mapButton.image:beginAnimation("default", fadeTimeMs)
-- 	mapButton.image:setAlpha(1)
-- 	CoD.MapVoter.FadeOut(mapButton.countBg, fadeTimeMs)
-- 	CoD.MapVoter.FadeOut(mapButton.count, fadeTimeMs)
-- 	CoD.MapVoter.FadeOut(mapButton.mapTypeLabel, fadeTimeMs)
-- 	CoD.MapVoter.FadeOut(mapButton.imageHighlight, fadeTimeMs)
-- 	CoD.MapVoter.FadeOut(mapButton.disabledImageHighlight, fadeTimeMs)
-- 	if fadeTimeMs and fadeTimeMs > 0 then
-- 		mapButton:addElement(LUI.UITimer.new(fadeTimeMs, {
-- 			name = "expand",
-- 			duration = fadeTimeMs
-- 		}, true))
-- 	else
-- 		CoD.MapVoter.ExpandButton(mapButton)
-- 	end
-- end

-- CoD.MapVoter.ExpandButton = function (menu, event)
-- 	local animationTime = nil
-- 	if event ~= nil then
-- 		animationTime = event.duration
-- 	end
-- 	local mapImageRatio = CoD.MapInfoImage.MapImageWidth / CoD.MapInfoImage.MapImageHeight
-- 	local menuMapVoterWidth = menu.mapVoter.width
-- 	local topBottomOffset = menuMapVoterWidth / mapImageRatio
-- 	menu.image:beginAnimation("expand", animationTime, true, true)
-- 	menu.image:setLeftRight(false, false, -menuMapVoterWidth / 2, menuMapVoterWidth / 2)
-- 	menu.image:setTopBottom(true, false, 0, topBottomOffset)
-- 	menu:beginAnimation("expand", animationTime, true, true)
-- 	menu:setTopBottom(true, false, 0, topBottomOffset + CoD.MapVoter.FooterHeight)
-- 	menu:setLeftRight(true, true, 0, 0)
-- end