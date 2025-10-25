#include <iostream>

#include <wx/intl.h>
#include <wx/sizer.h>
#include <wx/spinctrl.h>
#include <wx/stattext.h>

#include "WxTestFrame.hpp"

static const wxSize SPINCTRL_SIZE(120, wxDefaultCoord);

WxTestFrame::WxTestFrame(): wxFrame(nullptr, wxID_ANY, "WxTestSpinCtrl Frame"),
        m_testSpinCtrl(nullptr)
{
  wxBoxSizer *topSizer = new wxBoxSizer(wxVERTICAL);

  wxFlexGridSizer *grid = new wxFlexGridSizer(2, 5, 5);

  grid->Add(
    new wxStaticText(this, wxID_ANY, _("Volume:")),
    0,
    wxALIGN_CENTER_VERTICAL | wxALIGN_RIGHT);
  m_testSpinCtrl = new wxSpinCtrl(
    this, wxID_ANY, wxEmptyString, wxDefaultPosition, SPINCTRL_SIZE);
  grid->Add(m_testSpinCtrl, 0, wxALL);
  m_testSpinCtrl->SetRange(-120, 20);
  m_testSpinCtrl->SetValue(0);
  topSizer->Add(grid, 0, wxEXPAND | wxALL, 5);

  SetSizerAndFit(topSizer);
  CreateStatusBar();
  SetStatusText("Welcome to wxWidgets!");
}
