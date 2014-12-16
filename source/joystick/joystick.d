/**
 * Author: Jason White
 *
 * Description:
 * Interface for reading joystick/gamepad events.
 *
 * See also:
 * https://www.kernel.org/doc/Documentation/input/joystick-api.txt
 */
module joystick.joystick;

import joystick.c.joystick;

import core.sys.posix.fcntl;
import core.sys.posix.unistd;
import core.sys.posix.sys.ioctl;


struct Joystick
{
    struct Event
    {
        js_event _event;

        alias _event this;

        bool isButton() const pure @property
        {
            return _event.type == JS_EVENT_BUTTON;
        }

        size_t buttonid() const pure @property
        {
            return _event.number;
        }

        bool isAxis() const pure @property
        {
            return _event.type == JS_EVENT_AXIS;
        }

        size_t stickid() const pure @property
        {
            return _event.number / 2;
        }

        size_t axisid() const pure @property
        {
            return _event.number % 2;
        }
    }

    private
    {
        // File descriptor for the joystick file.
        int _fd = -1;

        // Current event.
        Event _event;

        bool _empty = false;
    }

    this(string device)
    {
        import std.string : toStringz;

        _fd = .open(toStringz(device), O_RDONLY);
        if (_fd == -1)
            throw new Exception("Failed to open joystick device");

        // Prime the cannons
        popFront();
    }

    ~this()
    {
        .close(_fd);
    }

    /**
     * Reads a joystick event from the joystick device.
     */
    void popFront()
    {
        long bytes = .read(_fd, &_event, _event.sizeof);
        if (bytes != _event.sizeof)
            _empty = true;
    }

    @property
    const Event front() pure
    {
        return _event;
    }

    @property
    bool empty()
    {
        return _empty;
    }

    /**
     * Returns the number of axes on the controller or 0 if an error occurs.
     */
    size_t axisCount()
    {
        ubyte axes;

        if (ioctl(_fd, JSIOCGAXES, &axes) == -1)
            return 0;

        return axes;
    }

    /**
     * Returns the number of buttons on the controller or 0 if an error occurs.
     */
    size_t buttonCount()
    {
        ubyte buttons;
        if (ioctl(_fd, JSIOCGBUTTONS, &buttons) == -1)
            return 0;

        return buttons;
    }
}

struct StickState
{
    union
    {
        short[2] axes;
        struct
        {
            short x, y;
        }
    }

    void accumulate(size_t axisid, short value)
    {
        axes[axisid] = value;
    }
}
