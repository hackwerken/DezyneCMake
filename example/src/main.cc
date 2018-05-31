#include <iostream>
#include <chrono>
#include <thread>

#include <dzn/runtime.hh>
#include <dzn/locator.hh>

#include <system.hh>


int main(int /*argc*/, char **/*argv*/)
{
    std::cout << "Dezyne CMake example" << std::endl;

    //construct the runtime
    dzn::locator loc;
    dzn::runtime rt;
    dzn::illegal_handler illegal_handler;
    loc.set(rt);
    loc.set(illegal_handler);

    Example system(loc);
    system.check_bindings();

    system.iController.in.start();
    std::this_thread::sleep_for(std::chrono::seconds(2));
    system.iController.in.stop();

    return  0;
}

