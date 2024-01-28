class cv.core.cv_ToolTip
{
    var toolTipLabel, _dBg, _dShdw, _tF, _mseLnr, _twnLnr, _ttMC, _twnBg, _t, _l, _wInt;
    function cv_ToolTip(_local, msg)
    {
        var _loc5 = _local.getNextHighestDepth();
        toolTipLabel = msg;
        _dBg = new cv.core.cv_Draw(0, 1, 100, 16645608, 100);
        _dShdw = new cv.core.cv_Draw(0, 0, 0, 0, 30);
        _tF = new TextFormat();
        _mseLnr = new Object();
        _twnLnr = new Object();
        _ttMC = _local.createEmptyMovieClip("_toolTip_" + _loc5, _loc5);
        var _loc3 = _ttMC.createEmptyMovieClip("_shdwMC", 9);
        _loc3._x = _loc3._y = 3;
        var _loc4 = _ttMC.createEmptyMovieClip("_bgMC", 10);
        _ttMC.createTextField("_label_txt", 11, 0, 0, 9, 9);
        var _loc2 = _ttMC._label_txt;
        _loc2._x = 2;
        _tF.align = "Left";
        _tF.font = "_sans";
        _tF.size = 12;
        _tF.indent = 1;
        _loc2.autoSize = "left";
        _loc2.multiline = true;
        _loc2.selectable = false;
        _loc2.text = toolTipLabel;
        _loc2.setTextFormat(_tF);
        var _loc7 = _loc2._width + 5;
        var _loc6 = _loc2._height;
        _dBg.drawBox(_loc4, _loc7, _loc6);
        _dShdw.drawBox(_loc3, _loc7, _loc6);
        _loc4._alpha = _loc3._alpha = 0;
        _ttMC._visible = false;
        _twnBg = new cv.core.cv_Tween(_loc4);
        _twnBg.addTween("_alpha", 100, 1.000000E-001, "regular", {damp: 7.000000E-001});
        _twnLnr.onTweenStart = function (evt)
        {
            evt.target._parent._visible = true;
            evt.target._parent._shdwMC._alpha = evt.target._alpha;
        };
        _twnLnr.onTween = function (evt)
        {
            evt.target._parent._shdwMC._alpha = evt.target._alpha;
        };
        _twnLnr.onTweenComplete = function (evt)
        {
            evt.target._parent._shdwMC._alpha = evt.target._alpha;
        };
        _twnBg.addEventListener("onTweenStart", _twnLnr);
        _twnBg.addEventListener("onTween", _twnLnr);
        _twnBg.addEventListener("onTweenComplete", _twnLnr);
        _mseLnr._l = _local;
        _mseLnr._t = _ttMC;
        _mseLnr.onMouseMove = function ()
        {
            _t._x = _l._xmouse;
            _t._y = _l._ymouse + 20;
            updateAfterEvent();
        };
    } // End of the function
    function show()
    {
        clearInterval(_wInt);
        Mouse.addListener(_mseLnr);
        _t = getTimer();
        _wInt = setInterval(tooltipInterval, 10, this);
    } // End of the function
    function hide()
    {
        _twnBg.stop();
        _ttMC._bgMC._alpha = _ttMC._shdwMC._alpha = 0;
        _ttMC._visible = false;
        Mouse.removeListener(_mseLnr);
        _t = 0;
        clearInterval(_wInt);
    } // End of the function
    function tooltipInterval(inst)
    {
        if (!inst._ttMC._visible && getTimer() - inst._t > 500)
        {
            inst._twnBg.start();
            inst._t = 0;
            clearInterval(inst._wInt);
        } // end if
    } // End of the function
} // End of Class