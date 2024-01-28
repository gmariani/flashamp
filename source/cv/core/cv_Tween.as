class cv.core.cv_Tween
{
    var _targetMC, _tweenInterval, _targetProp, _targetvalue, _targetVelocity, _easingType, _delta, _tweenParams, dispatchEvent, _targetSpeed, _direction, isPlaying;
    function cv_Tween(mc)
    {
        _targetMC = mc;
    } // End of the function
    function addTween(p, t, v, e, args)
    {
        clearInterval(_tweenInterval);
        _targetProp = p;
        _targetvalue = t;
        _targetVelocity = v;
        _easingType = e;
        _delta = this.findDelta();
        if (args)
        {
            _tweenParams = args;
        } // end if
        this.dispatchEvent({type: "onTweenInit"});
    } // End of the function
    function start()
    {
        _targetSpeed = 0;
        _direction = this.findDirection();
        switch (_easingType.toLowerCase())
        {
            case "bounce":
            {
                _tweenInterval = setInterval(bounceInterval, 10, this);
                break;
            } 
            case "elastic":
            {
                _tweenInterval = setInterval(elasticInterval, 10, this);
                break;
            } 
            case "none":
            {
                _tweenInterval = setInterval(noneInterval, 10, this);
                break;
            } 
            case "regular":
            {
                _tweenInterval = setInterval(regularInterval, 10, this);
                break;
            } 
            default:
            {
                break;
            } 
        } // End of switch
        isPlaying = true;
        this.dispatchEvent({type: "onTweenStart", target: _targetMC, value: _targetMC[_targetProp]});
    } // End of the function
    function stop()
    {
        clearInterval(_tweenInterval);
        isPlaying = false;
        this.dispatchEvent({type: "onTweenStop"});
    } // End of the function
    function resume()
    {
    } // End of the function
    function rewind()
    {
    } // End of the function
    function bounceInterval(inst)
    {
    } // End of the function
    function elasticInterval(inst)
    {
        inst._targetSpeed = inst._targetSpeed + (inst._targetvalue - inst._targetMC[inst._targetProp]) * inst._targetVelocity;
        inst._targetSpeed = inst._targetSpeed * inst._tweenParams.damp;
        inst._targetMC[inst._targetProp] = inst._targetMC[inst._targetProp] + inst._targetSpeed;
        inst.checkIfDone();
    } // End of the function
    function noneInterval(inst)
    {
        if (inst._direction == 1)
        {
            inst._targetMC[inst._targetProp] = inst._targetMC[inst._targetProp] + inst._targetVelocity * 10;
        }
        else
        {
            inst._targetMC[inst._targetProp] = inst._targetMC[inst._targetProp] - inst._targetVelocity * 10;
        } // end else if
        inst.checkIfDone();
    } // End of the function
    function regularInterval(inst)
    {
        inst._targetSpeed = inst.findDelta() * inst._targetVelocity;
        if (inst._direction == 1)
        {
            inst._targetMC[inst._targetProp] = inst._targetMC[inst._targetProp] + inst._targetSpeed;
        }
        else
        {
            inst._targetMC[inst._targetProp] = inst._targetMC[inst._targetProp] - inst._targetSpeed;
        } // end else if
        inst.checkIfDone();
    } // End of the function
    function checkIfDone()
    {
        this.dispatchEvent({type: "onTween", target: _targetMC, value: _targetMC[_targetProp]});
        switch (_direction)
        {
            case 1:
            {
                if (_easingType.toLowerCase() != "none")
                {
                    if (_targetSpeed < 5.000000E-001)
                    {
                        this.tweenDone();
                    } // end if
                }
                else if (_targetMC[_targetProp] >= _targetvalue)
                {
                    this.tweenDone();
                } // end else if
                break;
            } 
            case 0:
            {
                if (_easingType.toLowerCase() != "none")
                {
                    if (_targetSpeed < 5.000000E-001)
                    {
                        this.tweenDone();
                    } // end if
                }
                else if (_targetMC[_targetProp] <= _targetvalue)
                {
                    this.tweenDone();
                } // end else if
                break;
            } 
            default:
            {
                trace ("checkIfDone() : Can\'t tell which direction MC is going.");
            } 
        } // End of switch
    } // End of the function
    function findDelta()
    {
        if (_targetMC[_targetProp] < _targetvalue)
        {
            return (_targetvalue - _targetMC[_targetProp]);
        }
        else
        {
            return (_targetMC[_targetProp] - _targetvalue);
        } // end else if
    } // End of the function
    function findDirection()
    {
        if (_targetMC[_targetProp] < _targetvalue)
        {
            return (1);
        }
        else
        {
            return (0);
        } // end else if
    } // End of the function
    function tweenDone()
    {
        clearInterval(_tweenInterval);
        _targetMC[_targetProp] = _targetvalue;
        isPlaying = false;
        this.dispatchEvent({type: "onTweenComplete", target: _targetMC, value: _targetMC[_targetProp]});
    } // End of the function
    var type = cv.core.cv_Tween;
    var className = "cv_Tween";
    static var __mixinFED = mx.events.EventDispatcher.initialize(cv.core.cv_Tween.prototype);
} // End of Class