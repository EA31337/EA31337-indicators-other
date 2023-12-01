/**
 * @file
 * Implements indicator under MQL5.
 */

#define ERR_USER_INVALID_HANDLE 1
#define ERR_USER_INVALID_BUFF_NUM 2
#define ERR_USER_ITEM_NOT_FOUND 3
#define ERR_USER_ARRAY_IS_EMPTY 1000

// Defines indicator properties.
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_color1 LightSalmon
#property indicator_color2 Lime
#property indicator_color3 LightSalmon
#property indicator_color4 Lime

// Includes EA31337 framework.
// clang-format off
#define INDICATOR_LEGACY_VERSION_MT4
#include <EA31337-classes/IndicatorLegacy.h>
// clang-format on
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_HeikenAshi.mqh>
#include <EA31337-classes/Indicators/Indi_RSI.mqh>

// Defines macros.
#define extern input
//#define Bars fmin(10000, (ChartStatic::iBars(_Symbol, _Period)))
#define Bars ChartStatic::iBars(_Symbol, _Period)
#define Bid (SymbolInfoStatic::GetBid(_Symbol))
#define TimeDayOfWeek (DateTime::DateOfWeek())

// Includes the main file.
#include "Heiken_Ashi_Smoothed.mq4"

// Custom indicator initialization function.
void OnInit() { init(); }

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated,
                const int begin, const double &price[]) {
  IndicatorCounted(fmin(prev_calculated, Bars));
  ResetLastError();

  ArraySetAsSeries(ExtMapBuffer1, true);
  ArraySetAsSeries(ExtMapBuffer2, true);
  ArraySetAsSeries(ExtMapBuffer3, true);
  ArraySetAsSeries(ExtMapBuffer4, true);
  ArraySetAsSeries(ExtMapBuffer5, true);
  ArraySetAsSeries(ExtMapBuffer6, true);
  ArraySetAsSeries(ExtMapBuffer7, true);
  ArraySetAsSeries(ExtMapBuffer8, true);

  int _res = start() >= 0 ? rates_total : 0;

  ArraySetAsSeries(ExtMapBuffer1, false);
  ArraySetAsSeries(ExtMapBuffer2, false);
  ArraySetAsSeries(ExtMapBuffer3, false);
  ArraySetAsSeries(ExtMapBuffer4, false);
  ArraySetAsSeries(ExtMapBuffer5, false);
  ArraySetAsSeries(ExtMapBuffer6, false);
  ArraySetAsSeries(ExtMapBuffer7, false);
  ArraySetAsSeries(ExtMapBuffer8, false);

  return _res;
}
