/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_chart_window
#property indicator_buffers 5
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
#include <EA31337-classes/Chart.mqh>
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_ATR.mqh>
#include <EA31337-classes/Indicators/Indi_MA.mqh>

// Defines macros.
#define extern input
#define Bars fmin(10000, (ChartStatic::iBars(_Symbol, _Period)))

// Includes the main file.
#include "TMA+CG_mladen_NRP.mq4"

// Custom indicator initialization function.
void OnInit() {
  init();
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, AtrPeriod);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, AtrPeriod);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, AtrPeriod);
  if (!ArrayGetAsSeries(tmBuffer)) {
    ArraySetAsSeries(tmBuffer, true);
    ArraySetAsSeries(upBuffer, true);
    ArraySetAsSeries(dnBuffer, true);
    ArraySetAsSeries(dnArrow, true);
    ArraySetAsSeries(upArrow, true);
    ArraySetAsSeries(wuBuffer, true);
    ArraySetAsSeries(wdBuffer, true);
  }
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  // if (begin > 0) PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, begin + SvePeriod);
  // if (begin > 0) PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, begin + SvePeriod);
  // if (begin > 0) PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, begin + SvePeriod);

  // Resizing buffers, as sometimes index buffers aren't automatically resized in MT5.
  if (ArraySize(upBuffer) < rates_total) {
    ArrayResize(upBuffer, rates_total, 4096);
  }
  if (ArraySize(dnBuffer) < rates_total) {
    ArrayResize(dnBuffer, rates_total, 4096);
  }
  if (ArraySize(wuBuffer) < rates_total) {
    ArrayResize(wuBuffer, rates_total, 4096);
  }
  if (ArraySize(wdBuffer) < rates_total) {
    ArrayResize(wdBuffer, rates_total, 4096);
  }
  if (ArraySize(upArrow) < rates_total) {
    ArrayResize(upArrow, rates_total, 4096);
  }
  if (ArraySize(dnArrow) < rates_total) {
    ArrayResize(dnArrow, rates_total, 4096);
  }

  int pos = fmax(0, prev_calculated - 1);
  IndicatorCounted(prev_calculated);
  start();
  return (rates_total);
}
