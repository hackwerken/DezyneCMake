 #include "Led.hh"

#include <iostream>

Led::Led(const dzn::locator &loc)
    : skel::Led(loc)
{

}

void Led::iLed_setOn()
{
    std::cout << dzn_meta.name << " on" << std::endl;
}

void Led::iLed_setOff()
{
    std::cout << dzn_meta.name << " off" << std::endl;
}
