class cv.core.cv_Draw
{
    var _lineS, _lineC, _lineA, _fillC, _fillA;
    function cv_Draw(lineC, lineS, lineA, fillC, fillA)
    {
        _lineS = lineS;
        _lineC = lineC;
        _lineA = lineA;
        _fillC = fillC;
        _fillA = fillA;
    } // End of the function
    function drawBox(mc, w, h)
    {
        var _loc4 = 0;
        var _loc3 = 0;
        mc.clear();
        mc.lineStyle(_lineS, _lineC, _lineA);
        mc.beginFill(_fillC, _fillA);
        mc.moveTo(_loc4, _loc3);
        mc.lineTo(_loc4 + w, _loc3);
        mc.lineTo(_loc4 + w, _loc3 + h);
        mc.lineTo(_loc4, _loc3 + h);
        mc.lineTo(_loc4, _loc3);
        mc.endFill();
    } // End of the function
    function drawCircle(mc, r)
    {
        var _loc4 = 0;
        var _loc3 = 0;
        mc.clear();
        mc.lineStyle(_lineS, _lineC, _lineA);
        mc.beginFill(_fillC, _fillA);
        mc.moveTo(_loc4 + r, _loc3);
        mc.curveTo(r + _loc4, 4.142136E-001 * r + _loc3, 7.071068E-001 * r + _loc4, 7.071068E-001 * r + _loc3);
        mc.curveTo(4.142136E-001 * r + _loc4, r + _loc3, _loc4, r + _loc3);
        mc.curveTo(-4.142136E-001 * r + _loc4, r + _loc3, -7.071068E-001 * r + _loc4, 7.071068E-001 * r + _loc3);
        mc.curveTo(-r + _loc4, 4.142136E-001 * r + _loc3, -r + _loc4, _loc3);
        mc.curveTo(-r + _loc4, -4.142136E-001 * r + _loc3, -7.071068E-001 * r + _loc4, -7.071068E-001 * r + _loc3);
        mc.curveTo(-4.142136E-001 * r + _loc4, -r + _loc3, _loc4, -r + _loc3);
        mc.curveTo(4.142136E-001 * r + _loc4, -r + _loc3, 7.071068E-001 * r + _loc4, -7.071068E-001 * r + _loc3);
        mc.curveTo(r + _loc4, -4.142136E-001 * r + _loc3, r + _loc4, _loc3);
    } // End of the function
    function drawTriangle(mc, w, h)
    {
        var _loc4 = 0;
        var _loc3 = 0;
        mc.clear();
        mc.lineStyle(_lineS, _lineC, _fillA);
        mc.beginFill(_fillC, _fillA);
        mc.moveTo(_loc4, _loc3);
        mc.lineTo(_loc4 + w, _loc3);
        mc.lineTo(_loc4 + w / 2, _loc3 + h);
        mc.lineTo(_loc4, _loc3);
        mc.endFill();
    } // End of the function
    var type = cv.core.cv_Draw;
    var className = "cv_Draw";
} // End of Class