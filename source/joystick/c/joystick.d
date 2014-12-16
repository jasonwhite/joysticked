/**
 * D header file for GNU/Linux.
 *
 * Authors: Jason White
 *
 * License:
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Jason White
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
module joystick.c.joystick;

import core.sys.posix.sys.ioctl;
import joystick.c.input;

version (linux):
extern (C):

/*
 * Version
 */
enum JS_VERSION = 0x020100;

/*
 * Types and constants for reading from /dev/js
 */

enum
{
    JS_EVENT_BUTTON = 0x01, // button pressed/released
    JS_EVENT_AXIS   = 0x02, // joystick moved
    JS_EVENT_INIT   = 0x80, // initial state of device
}

struct js_event
{
    uint time;    // event timestamp in milliseconds
    short value; // value
    ubyte type;    // event type
    ubyte number;  // axis/button number
}

/*
 * IOCTL commands for joystick driver
 */

// FIXME: Move this into core.sys.posix.sys.ioctl
private extern (D) int _IOC(int dir, int type, int nr, int len)
{
    return (dir << _IOC_DIRSHIFT) |
           (type << _IOC_TYPESHIFT) |
           (nr << _IOC_NRSHIFT) |
           (len << _IOC_SIZESHIFT);
}

enum TCGETS2         = _IOR!termios2('T', 0x2A);
enum JSIOCGVERSION   = _IOR!uint('j', 0x01);                          /* get driver version */

enum JSIOCGAXES      = _IOR!ubyte('j', 0x11);                         /* get number of axes */
enum JSIOCGBUTTONS   = _IOR!ubyte('j', 0x12);                         /* get number of buttons */
auto JSIOCGNAME(int len) { return _IOC(_IOC_READ, 'j', 0x13, len); }  /* get identifier string */

enum JSIOCSCORR      = _IOW!js_corr('j', 0x21); /* set correction values */
enum JSIOCGCORR      = _IOR!js_corr('j', 0x22); /* get correction values */

enum JSIOCSAXMAP     = _IOW!(ubyte[ABS_CNT])('j', 0x31);                 /* set axis mapping */
enum JSIOCGAXMAP     = _IOR!(ubyte[ABS_CNT])('j', 0x32);                 /* get axis mapping */
enum JSIOCSBTNMAP    = _IOW!(ushort[KEY_MAX - BTN_MISC + 1])('j', 0x33); /* set button mapping */
enum JSIOCGBTNMAP    = _IOR!(ushort[KEY_MAX - BTN_MISC + 1])('j', 0x34); /* get button mapping */

/*
 * Types and constants for get/set correction
 */

enum
{
    JS_CORR_NONE   = 0x00, // returns raw values
    JS_CORR_BROKEN = 0x01, // broken line
}

struct js_corr
{
    int coef[8];
    short prec;
    ushort type;
}

/*
 * v0.x compatibility definitions
 */

enum
{
	JS_RETURN = JS_DATA_TYPE.sizeof,
	JS_TRUE	  = 1,
	JS_FALSE  = 0,
	JS_X_0	  = 0x01,
	JS_Y_0	  = 0x02,
	JS_X_1	  = 0x04,
	JS_Y_1	  = 0x08,
	JS_MAX	  = 2,
}

enum
{
	JS_DEF_TIMEOUT   = 0x1300,
	JS_DEF_CORR      = 0,
	JS_DEF_TIMELIMIT = 10L,
}

enum
{
	JS_SET_CAL       = 1,
	JS_GET_CAL       = 2,
	JS_SET_TIMEOUT   = 3,
	JS_GET_TIMEOUT   = 4,
	JS_SET_TIMELIMIT = 5,
	JS_GET_TIMELIMIT = 6,
	JS_GET_ALL       = 7,
	JS_SET_ALL       = 8,
}

struct JS_DATA_TYPE {
	int buttons;
	int x;
	int y;
}

struct JS_DATA_SAVE_TYPE_32 {
	int JS_TIMEOUT;
	int BUSY;
	int JS_EXPIRETIME;
	int JS_TIMELIMIT;
	JS_DATA_TYPE JS_SAVE;
	JS_DATA_TYPE JS_CORR;
}

struct JS_DATA_SAVE_TYPE_64 {
	int JS_TIMEOUT;
	int BUSY;
	long JS_EXPIRETIME;
	long JS_TIMELIMIT;
	JS_DATA_TYPE JS_SAVE;
	JS_DATA_TYPE JS_CORR;
}
