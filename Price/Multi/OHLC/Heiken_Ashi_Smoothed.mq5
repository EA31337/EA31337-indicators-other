/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  DodgerBlue, Red
#property indicator_label1  "Heiken Ashi Open;Heiken Ashi High;Heiken Ashi Low;Heiken Ashi Close"

// Includes EA31337 framework.
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_HeikenAshi.mqh>
#include <EA31337-classes/Indicators/Indi_RSI.mqh>

// Defines macros.
#define extern input
#define Bars fmin(10000, (ChartStatic::iBars(_Symbol, _Period)))
#define Bid (SymbolInfoStatic::GetBid(_Symbol))
#define TimeDayOfWeek (DateTime::DateOfWeek())

// Includes the main file.
#include "Heiken_Ashi_Smoothed.mq4"

// Custom indicator initialization function.
void OnInit() {
  init();
  if (!ArrayGetAsSeries(ExtMapBuffer1)) {
    ArraySetAsSeries(ExtMapBuffer1, true);
    ArraySetAsSeries(ExtMapBuffer2, true);
    ArraySetAsSeries(ExtMapBuffer3, true);
    ArraySetAsSeries(ExtMapBuffer4, true);
    ArraySetAsSeries(ExtMapBuffer5, true);
    ArraySetAsSeries(ExtMapBuffer6, true);
    ArraySetAsSeries(ExtMapBuffer7, true);
    ArraySetAsSeries(ExtMapBuffer8, true);
  }
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated,
                const int begin, const double &price[]) {
  IndicatorCounted(fmin(prev_calculated, Bars));
  ResetLastError();
  return start() >= 0 ? rates_total : 0;
}
