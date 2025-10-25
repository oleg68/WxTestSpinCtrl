#include <wx/wx.h>

#include "WxTestApp.hpp"
#include "WxTestFrame.hpp"

IMPLEMENT_APP(WxTestApp)
	
bool WxTestApp::OnInit()
{
  if (!wxApp::OnInit())
	  return false;

  WxTestFrame *frame = new WxTestFrame();
  // SetTopWindow(frame);
  frame->Show(true);
  return true;
}

	