/**
 * Author: Jason White
 *
 * Description:
 * Reads joystick/gamepad events and displays them.
 */
import std.stdio;
import joystick.joystick;
import joystick.c.joystick;

int main(string[] args)
{
    string device = "/dev/input/js0";

    if (args.length > 1)
        device = args[1];

    auto js = Joystick(device);
    auto numSticks = js.axisCount / 2;
    auto numButtons = js.buttonCount;

    writefln(":: Detected joystick/gamepad with %d sticks and %d buttons.", numSticks, numButtons);

    StickState[] sticks;
    sticks.length = numSticks;

    auto exitButton = numButtons - 1;

    writefln(":: Press and release button %d to exit.", exitButton);

    foreach (event; js)
    {
        if (event.isButton)
        {
            writefln("Button %u %s", event.number, event.value ? "pressed" : "released");

            if (event.buttonid == exitButton && !event.value)
                break;
        }
        else if (event.isAxis)
        {
            auto id = event.stickid;
            with (sticks[id])
            {
                accumulate(event.axisid, event.value);
                writefln("Stick %u at (%6d, %6d)", id, x, y);
            }
        }
        else
        {
            // Initialization events. If button and stick states are stored,
            // these events should be used to initialize those states.
            writefln("Event: time %10u, value %6d, type 0x%02x, number %3u",
                    event.time, event.value, event.type, event.number);
        }
    }

    return 0;
}
