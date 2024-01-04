/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_separate_window

#property indicator_buffers 6
#property indicator_plots 6

#property indicator_color1 Black
#property indicator_color2 MediumBlue
#property indicator_color3 Yellow
#property indicator_color4 MediumBlue
#property indicator_color5 Green
#property indicator_color6 Red

#property indicator_level1 50
#property indicator_level2 68
#property indicator_level3 32

#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor DimGray

// Includes EA31337 framework.
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_MA.mqh>
#include <EA31337-classes/Indicators/Indi_RSI.mqh>

int BarsShrinked() {
  static int _initial_bars = MathMax(0, ChartStatic::iBars(_Symbol, _Period) - 1000);
  int _result = ChartStatic::iBars(_Symbol, _Period) - _initial_bars;
  return _result;
}

// Defines macros.
#define extern input
#define Bars BarsShrinked()
#define Bid (SymbolInfoStatic::GetBid(_Symbol))
#define TimeDayOfWeek (DateTime::DateOfWeek())

// Includes the main file.
#include "Traders Dynamic Index.mq4"

// Custom indicator initialization function.
void OnInit() { init(); }

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  ResetLastError();

  ArraySetAsSeries(RSIBuf, true);
  ArraySetAsSeries(UpZone, true);
  ArraySetAsSeries(MdZone, true);
  ArraySetAsSeries(DnZone, true);
  ArraySetAsSeries(MaBuf, true);
  ArraySetAsSeries(MbBuf, true);

  int _result = start() >= 0 ? rates_total : 0;

  ArraySetAsSeries(RSIBuf, false);
  ArraySetAsSeries(UpZone, false);
  ArraySetAsSeries(MdZone, false);
  ArraySetAsSeries(DnZone, false);
  ArraySetAsSeries(MaBuf, false);
  ArraySetAsSeries(MbBuf, false);

  IndicatorCounted(fmin(rates_total, Bars));
  return _result;
}
