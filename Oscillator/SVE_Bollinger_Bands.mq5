/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots 3
#property indicator_color1 DeepSkyBlue
#property indicator_color2 LimeGreen
#property indicator_color3 Red
#property indicator_label1 "SVEBB middle"
#property indicator_label2 "SVEBB upper"
#property indicator_label3 "SVEBB lower"
#property indicator_level1 50
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_width1 2

// Includes EA31337 framework.
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_MA.mqh>
#include <EA31337-classes/Storage/ValueStorage.h>

// Defines macros.
#define extern input
#define Bars (ChartStatic::iBars(_Symbol, _Period))

// Includes the main file.
#include "SVE_Bollinger_Bands.mq4"

// Custom indicator initialization function.
void OnInit() {
  init();
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, fmin(SvePeriod, TEMAPeriod));
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, fmin(SvePeriod, TEMAPeriod));
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, fmin(SvePeriod, TEMAPeriod));
  PlotIndexSetString(0, PLOT_LABEL, "SVEBB Middle");
  PlotIndexSetString(1, PLOT_LABEL, "SVEBB Upper");
  PlotIndexSetString(2, PLOT_LABEL, "SVEBB Lower");
  SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 1);
  SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_DOT, 1);
  SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_DOT, 1);
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  int pos = fmax(0, prev_calculated - 1);
  IndicatorCounted(prev_calculated);
  start();
  return (rates_total);
}
