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

// Includes EA31337 framework.
#include <EA31337-classes/Draw.mqh>
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_ATR.mqh>
#include <EA31337-classes/Indicators/Indi_MA.mqh>

// Defines macros.
#define extern input
#define Bars (ChartStatic::iBars(_Symbol, _Period))

// Includes the main file.
#include "ATR_MA_Slope.mq4"

// Custom indicator initialization function.
void OnInit() {
  init();
  if (!ArrayGetAsSeries(Slope)) {
    ArraySetAsSeries(Slope, true);
    ArraySetAsSeries(Long, true);
    ArraySetAsSeries(Short, true);
    ArraySetAsSeries(Flat, true);
  }
  PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
  PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
  PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, SlopeMAPeriod);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, SlopeMAPeriod);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, SlopeMAPeriod);
  PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, SlopeMAPeriod);
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated,
                const int begin, const double &price[]) {
  IndicatorCounted(fmin(prev_calculated, Bars));
  ResetLastError();
  return start() >= 0 ? rates_total : 0;
}
