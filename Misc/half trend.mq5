/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 7

#property indicator_label1 "up"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrDeepSkyBlue
#property indicator_width1 2

#property indicator_label2 "down"
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrTomato
#property indicator_width2 2

#property indicator_label3 "atrlo"
#property indicator_type3 DRAW_LINE
#property indicator_color3 clrDeepSkyBlue
#property indicator_width3 1

#property indicator_label4 "atrhi"
#property indicator_type4 DRAW_LINE
#property indicator_color4 clrTomato
#property indicator_width4 1

#property indicator_label5 "arrup"
#property indicator_type5 DRAW_LINE
#property indicator_color5 clrDeepSkyBlue
#property indicator_width5 1

#property indicator_label6 "arrdwn"
#property indicator_type6 DRAW_LINE
#property indicator_color6 clrTomato
#property indicator_width6 1

// Includes EA31337 framework.
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_ATR.mqh>
#include <EA31337-classes/Indicators/Indi_MA.mqh>

// Defines macros.
#define extern input
#define Bars fmin(10000, (ChartStatic::iBars(_Symbol, _Period)))

// Includes the main file.
#include "half trend.mq4"

// Custom indicator initialization function.
void OnInit() {
  init();
  if (!ArrayGetAsSeries(up)) {
    ArraySetAsSeries(down, true);
    ArraySetAsSeries(atrlo, true);
    ArraySetAsSeries(atrhi, true);
    ArraySetAsSeries(trend, true);
    ArraySetAsSeries(arrup, true);
    ArraySetAsSeries(arrdwn, true);
  }
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated,
                const int begin, const double &price[]) {
  IndicatorCounted(fmin(prev_calculated, Bars));
  ResetLastError();
  return start() >= 0 ? rates_total : 0;
}
