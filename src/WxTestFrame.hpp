#ifndef WXTESTFRAME_HPP
#define WXTESTFRAME_HPP

//#include <wx/event.h>
#include <wx/frame.h>

class wxSpinCtrl;

class WxTestFrame: public wxFrame
{
public:
  WxTestFrame();

private:
  wxSpinCtrl *m_testSpinCtrl;
};

#endif /* WXTESTFRAME_HPP */
