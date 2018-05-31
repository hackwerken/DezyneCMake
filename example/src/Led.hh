#pragma once

#include "skel_Led.hh"

class Led : public skel::Led {

public:
  Led(const dzn::locator& loc);

  // Led interface
private:
  virtual void iLed_setOn() override;
  virtual void iLed_setOff() override;
};

