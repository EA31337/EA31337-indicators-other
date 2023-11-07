/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_separate_window

#property indicator_buffers 4
#property indicator_plots 4

// Define indicator properties
#property indicator_type1 DRAW_LINE
#property indicator_color1 Gray
#property indicator_label1 "Slope"

#property indicator_type2 DRAW_ARROW
#property indicator_color2 Lime
#property indicator_label2 "Long"

#property indicator_type3 DRAW_ARROW
#property indicator_color3 Red
#property indicator_label3 "Short"

#property indicator_type4 DRAW_ARROW
#property indicator_color4 Gray
#property indicator_label4 "Flat"

#property indicator_level1 0.0

// Includes.
#include <Charts\Chart.mqh>

// Includes EA31337 framework.
#include <EA31337-classes/Draw.mqh>
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_ATR.mqh>
#include <EA31337-classes/Indicators/Indi_MA.mqh>

// Defines macros.
#define extern input
#define Bars (ChartStatic::iBars(_Symbol, _Period))
#define Bid (SymbolInfoStatic::GetBid(_Symbol))
#define TimeDayOfWeek DateTimeStatic::DayOfWeek

int WindowFirstVisibleBar(const long chart_ID = 0) {
  long result = -1;

  ResetLastError();

  if (!ChartGetInteger(chart_ID, CHART_FIRST_VISIBLE_BAR, 0, result)) {
    Print(__FUNCTION__ + ", Error Code = ", GetLastError());
  }

  return (int)result;
}

int WindowBarsPerChart() { return ChartGetInteger(0, CHART_VISIBLE_BARS, 0); }

int ObjectFind(string name) { return ObjectFind(0, name); }

bool ObjectSetText(string name, string text, int font_size, string font = "",
                   color text_color = CLR_NONE) {
  int tmpObjType = (int)ObjectGetInteger(0, name, OBJPROP_TYPE);
  if (tmpObjType != OBJ_LABEL && tmpObjType != OBJ_TEXT)
    return (false);
  if (StringLen(text) > 0 && font_size > 0) {
    if (ObjectSetString(0, name, OBJPROP_TEXT, text) == true &&
        ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size) == true) {
      if ((StringLen(font) > 0) &&
          ObjectSetString(0, name, OBJPROP_FONT, font) == false)
        return (false);
      if (text_color > -1 &&
          ObjectSetInteger(0, name, OBJPROP_COLOR, text_color) == false)
        return (false);
      return (true);
    }
    return (false);
  }
  return (false);
}

// Define global functions.
#undef DoubleToStr
string DoubleToStr(double _value) { return ::DoubleToString(_value); }
string DoubleToStr(double _value, int _digits) {
  return ::DoubleToString(_value, _digits);
}
int WindowsTotal(const long _cid = 0) {
  long result = -1;
  ResetLastError();
  if (!ChartGetInteger(_cid, CHART_WINDOWS_TOTAL, 0, result)) {
    Print(__FUNCTION__ + "(): Error code = ", GetLastError());
  }
  return (int)result;
}
int WindowOnDropped() { return ChartWindowOnDropped(); }
int WindowFind(string name) {
  int window = -1;
  if ((ENUM_PROGRAM_TYPE)MQLInfoInteger(MQL_PROGRAM_TYPE) ==
      PROGRAM_INDICATOR) {
    window = ChartWindowFind();
  } else {
    window = ChartWindowFind(0, name);
    if (window == -1)
      Print(__FUNCTION__ + "(): Error = ", GetLastError());
  }
  return (window);
}

// Includes the main file.
#include "SuperSlope.mq4"

// Custom indicator initialization function.
/*
void OnInit() {
  init();
  if (!ArrayGetAsSeries(Slope1)) {
    ArraySetAsSeries(Slope1, true);
    ArraySetAsSeries(Slope2, true);
  }
}
*/

// Custom indicator iteration function.
/*
int OnCalculate(const int rates_total, const int prev_calculated,
                const int begin, const double &price[]) {
  IndicatorCounted(fmin(prev_calculated, Bars));
  ResetLastError();
  return start() >= 0 ? rates_total : 0;
}
*/
