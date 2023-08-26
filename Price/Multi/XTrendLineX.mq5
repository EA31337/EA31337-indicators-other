/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 5
#property indicator_color1 Yellow
#property indicator_color2 Magenta     // Sell
#property indicator_color3 DodgerBlue  // Buy
#property indicator_color4 LimeGreen   // Buy
#property indicator_color5 Plum        // Buy
#property indicator_label1 "Open"
#property indicator_label2 "High"
#property indicator_label3 "Low"
#property indicator_label4 "Close"
#property indicator_label5 "Last Price"
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_LINE
#property indicator_type5 DRAW_LINE
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT
#property indicator_style5 STYLE_DOT

// Includes EA31337 framework.
#include <EA31337-classes/Draw.mqh>
#include <EA31337-classes/Indicator.mqh>

// Defines macros.
#define extern input
#define Bars (ChartStatic::iBars(_Symbol, _Period))
bool RefreshRates() { return Market::RefreshRates(); }

// Includes the main file.
#include "XTrendLineX.mq4"

// Custom indicator initialization function.
void OnInit() {
  init();
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, 0);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, 0);
  PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, 0);
  PlotIndexSetInteger(4, PLOT_DRAW_BEGIN, 0);
  PlotIndexSetString(0, PLOT_LABEL, "Open");
  PlotIndexSetString(1, PLOT_LABEL, "High");
  PlotIndexSetString(2, PLOT_LABEL, "Low");
  PlotIndexSetString(3, PLOT_LABEL, "Close");
  PlotIndexSetString(4, PLOT_LABEL, "Price");
  if (!ArrayGetAsSeries(ChartOpen)) {
    ArraySetAsSeries(ChartOpen, true);
    ArraySetAsSeries(ChartHigh, true);
    ArraySetAsSeries(ChartLow, true);
    ArraySetAsSeries(ChartClose, true);
    ArraySetAsSeries(LastPrice, true);
  }
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  IndicatorCounted(fmin(prev_calculated, Bars));
  ResetLastError();
  return start() >= 0 ? rates_total : 0;
}
