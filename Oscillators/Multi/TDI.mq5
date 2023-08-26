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

// Defines macros.
#define extern input
#define Bars fmin(10000, (ChartStatic::iBars(_Symbol, _Period)))
#define Bid (SymbolInfoStatic::GetBid(_Symbol))
#define TimeDayOfWeek (DateTime::DateOfWeek())

// Includes the main file.
#include "TDI.mq4"

// Custom indicator initialization function.
void OnInit() {
  init();
  if (!ArrayGetAsSeries(RSIBuf)) {
    ArraySetAsSeries(RSIBuf, true);
    ArraySetAsSeries(UpZone, true);
    ArraySetAsSeries(MdZone, true);
    ArraySetAsSeries(DnZone, true);
    ArraySetAsSeries(MaBuf, true);
    ArraySetAsSeries(MbBuf, true);
  }
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated,
                const int begin, const double &price[]) {
  IndicatorCounted(fmin(prev_calculated, Bars));
  ResetLastError();
  return start() >= 0 ? rates_total : 0;
}
