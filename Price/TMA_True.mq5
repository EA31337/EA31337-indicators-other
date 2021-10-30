/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3
#property indicator_color1 LightSeaGreen
#property indicator_color2 LightSeaGreen
#property indicator_color3 LightSeaGreen
#property indicator_label1 "TMATrue middle"
#property indicator_label2 "TMATrue upper"
#property indicator_label3 "TMATrue lower"
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1

// Includes EA31337 framework.
#include <EA31337-classes/Draw.mqh>
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_ATR.mqh>

// Defines macros.
#define extern input
#define Bars (ChartStatic::iBars(_Symbol, _Period))

// Includes the main file.
#include "TMA_True.mq4"

// Custom indicator initialization function.
void OnInit() {
  init();
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, eintAtrPeriod);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, eintAtrPeriod);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, eintAtrPeriod);
  PlotIndexSetString(0, PLOT_LABEL, "TMATrue Middle");
  PlotIndexSetString(1, PLOT_LABEL, "TMATrue Upper");
  PlotIndexSetString(2, PLOT_LABEL, "TMATrue Lower");
  if (!ArrayGetAsSeries(gadblMid)) {
    ArraySetAsSeries(gadblMid, true);
    ArraySetAsSeries(gadblUpper, true);
    ArraySetAsSeries(gadblLower, true);
  }
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  int pos = fmax(0, prev_calculated - 1);
  IndicatorCounted(prev_calculated);
  start();
  return (rates_total);
}
