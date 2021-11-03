/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_type2 DRAW_HISTOGRAM
#property indicator_minimum 0
#property indicator_maximum 1

// Includes EA31337 framework.
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_ATR.mqh>
#include <EA31337-classes/Indicators/Indi_MA.mqh>
#include <EA31337-classes/Market.mqh>

// Defines macros.
#define extern input
#define Bars (ChartStatic::iBars(_Symbol, _Period))

// Custom indicator iteration function.
/*
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  // if (begin > 0) PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, begin + SvePeriod);
  // if (begin > 0) PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, begin + SvePeriod);
  // if (begin > 0) PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, begin + SvePeriod);
  int pos = fmax(0, prev_calculated - 1);
  IndicatorCounted(prev_calculated);
  start();
  return (rates_total);
}
*/

// Includes the main file.
#include "TMA+CG_mladen_NRP_Histogram.mq4"
