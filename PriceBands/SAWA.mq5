/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2

// Includes EA31337 framework.
#include <EA31337-classes/Draw.mqh>
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_ATR.mqh>
#include <EA31337-classes/Indicators/Indi_CCI.mqh>
#include <EA31337-classes/Indicators/Indi_RSI.mqh>

// Defines macros.
#define extern input
#define Bars fmin(10000, (ChartStatic::iBars(_Symbol, _Period)))

// Includes the main file.
#include "SAWA.mq4"

// Custom indicator initialization function.
void OnInit() {
  init();
  ChartSetSymbolPeriod(0, _Symbol, PERIOD_CURRENT);
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, CCI_per);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, CCI_per);
  if (!ArrayGetAsSeries(ExtMapBuffer1)) {
    ArraySetAsSeries(ExtMapBuffer1, true);
    ArraySetAsSeries(ExtMapBuffer2, true);
    ArraySetAsSeries(ExtMapBuffer3, true);
    ArraySetAsSeries(ExtMapBuffer4, true);
  }
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  int pos = fmax(0, prev_calculated - 1);
  IndicatorCounted(prev_calculated);
  start();
  return (rates_total);
}
