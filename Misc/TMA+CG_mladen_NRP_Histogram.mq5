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

// Defines macros.
#define extern input
#define Bars fmin(10000, (ChartStatic::iBars(_Symbol, _Period)))

// Includes the main file.
#include "TMA+CG_mladen_NRP_Histogram.mq4"

// Custom indicator initialization function.
void OnInit() { init(); }

// Custom indicator iteration function.
/*
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  int pos = fmax(0, prev_calculated - 1);
  IndicatorCounted(prev_calculated);
  start();
  return (rates_total);
}
*/
