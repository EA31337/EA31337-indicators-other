/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_separate_window

#property indicator_buffers 6
#property indicator_plots 5
#property indicator_color1 clrBlue
#property indicator_width1 1
#property indicator_color2 clrBlue
#property indicator_width2 1
#property indicator_color3 clrYellow
#property indicator_width3 1
#property indicator_color4 clrRed
#property indicator_width4 2
#property indicator_color5 clrGreen
#property indicator_width5 2
#property indicator_color6 CLR_NONE
#property indicator_width6 1
#property indicator_level1 32
#property indicator_level2 50
#property indicator_level3 68
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
#include "TDI-RT-Clone.mq4"

// Custom indicator initialization function.
void OnInit() {
  init();
  if (!ArrayGetAsSeries(gdaRSI)) {
    ArraySetAsSeries(gdaRSI, true);
    ArraySetAsSeries(gdaRSISig, true);
    ArraySetAsSeries(gdaTradeSig, true);
    ArraySetAsSeries(gdaMktBase, true);
    ArraySetAsSeries(gdaVolaTop, true);
    ArraySetAsSeries(gdaVolaBtm, true);
  }
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated,
                const int begin, const double &price[]) {
  IndicatorCounted(fmin(prev_calculated, Bars));
  ResetLastError();
  return start() >= 0 ? rates_total : 0;
}
