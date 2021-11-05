/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 5
#property indicator_color1 clrNONE
#property indicator_color2 Coral
#property indicator_color3 Coral
#property indicator_color4 Green
#property indicator_color5 Maroon
#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2

// Includes EA31337 framework.
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_ATR.mqh>
#include <EA31337-classes/Indicators/Indi_MA.mqh>

// Defines macros.
//#define __debug__
#define extern input
#define Bars fmin(2000, (ChartStatic::iBars(_Symbol, _Period)))
#define iCustom iCustom5

// Includes the main file.
#include "TMA+CG_mladen_NRP.mq4"

// Custom indicator initialization function.
void OnInit() {
  init();

  bool as_series = true;

  ArraySetAsSeries(tmBuffer, as_series);
  ArraySetAsSeries(upBuffer, as_series);
  ArraySetAsSeries(dnBuffer, as_series);
  ArraySetAsSeries(dnArrow, as_series);
  ArraySetAsSeries(upArrow, as_series);
  ArraySetAsSeries(wuBuffer, as_series);
  ArraySetAsSeries(wdBuffer, as_series);

  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, AtrPeriod);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, AtrPeriod);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, AtrPeriod);

  SetIndexStyle(0, DRAW_LINE);
  SetIndexStyle(1, DRAW_LINE);
  SetIndexStyle(2, DRAW_LINE);
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated,
                const int begin, const double &price[]) {
  IndicatorCounted(fmin(prev_calculated, Bars));
  ResetLastError();
  return start() >= 0 ? rates_total : 0;
}
