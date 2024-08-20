/**
 * @file
 * Implements indicator under MQL4.
 *
 * @fixme
 */

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 1
#property indicator_label1 "SuperTrend"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrGreen
#property indicator_color2 clrRed
#property indicator_color3 clrDarkGray
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

// Includes EA31337 framework.
// #include <EA31337-classes/Indicator.mqh>

// Includes.
// #include "SuperTrend.mq5"

// Custom indicator initialization function.
void OnInit() {
  // @fixme
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[],
                const double &high[], const double &low[], const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  int start = rates_total - prev_calculated;

  // @todo: Call OnCalculate() in .mq5 file.

  return (rates_total);
}
