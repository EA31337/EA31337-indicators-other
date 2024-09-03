/**
 * @file
 * Implements indicator under MQL5.
 */

#define ERR_USER_INVALID_HANDLE 1
#define ERR_USER_INVALID_BUFF_NUM 2
#define ERR_USER_ITEM_NOT_FOUND 3

// Defines indicator properties.
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots 1
#property indicator_type1 DRAW_COLOR_CANDLES
#property indicator_style1 STYLE_SOLID
#property indicator_color1 clrNONE, clrLime, clrLightSalmon
#property indicator_width1 1
#property indicator_label1 "HA Open;HA High;HA Low;HA Close"

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
#define Bars fmin(1000, (ChartStatic::iBars(_Symbol, _Period)))
#define Bid (SymbolInfoStatic::GetBid(_Symbol))
#define TimeDayOfWeek (DateTime::DateOfWeek())

// Includes the main file.
#include "Heiken_Ashi_Smoothed.mq4"

double ExtMapBufferCandleColor[];

// Custom indicator initialization function.
void OnInit() {
  init();

  IndicatorBuffers(9);

  // Note switched buffers! We've mapped them from OHLC values into problem
  // index buffers.
  SetIndexBuffer(0, ExtMapBuffer3, INDICATOR_DATA);
  SetIndexBuffer(1, ExtMapBuffer1, INDICATOR_DATA);
  SetIndexBuffer(2, ExtMapBuffer2, INDICATOR_DATA);
  SetIndexBuffer(3, ExtMapBuffer4, INDICATOR_DATA);
  SetIndexBuffer(4, ExtMapBufferCandleColor, INDICATOR_COLOR_INDEX);

  SetIndexBuffer(5, ExtMapBuffer5, INDICATOR_CALCULATIONS);
  SetIndexBuffer(6, ExtMapBuffer6, INDICATOR_CALCULATIONS);
  SetIndexBuffer(7, ExtMapBuffer7, INDICATOR_CALCULATIONS);
  SetIndexBuffer(8, ExtMapBuffer8, INDICATOR_CALCULATIONS);

  SetIndexStyle(0, DRAW_COLOR_CANDLES, STYLE_SOLID, 1, clrLime);

  MathSrand(GetTickCount());
}

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

  if (prev_calculated <= 0) {
    // Initializing haOpen and haClose with open/close prices.
    for (int i = 0; i < rates_total; ++i) {
      ExtMapBuffer5[i] = ::iOpen(NULL, PERIOD_CURRENT, i);
      ExtMapBuffer6[i] = ::iClose(NULL, PERIOD_CURRENT, i);
    }
  }

  ArraySetAsSeries(ExtMapBuffer1, false);
  ArraySetAsSeries(ExtMapBuffer2, false);
  ArraySetAsSeries(ExtMapBuffer3, false);
  ArraySetAsSeries(ExtMapBuffer4, false);
  ArraySetAsSeries(ExtMapBuffer5, false);
  ArraySetAsSeries(ExtMapBuffer6, false);
  ArraySetAsSeries(ExtMapBuffer7, false);
  ArraySetAsSeries(ExtMapBuffer8, false);

  for (int i = prev_calculated; i < rates_total; ++i) {
    // Filling candle color index.
    ExtMapBufferCandleColor[i] = ExtMapBuffer1[i] > ExtMapBuffer4[i] ? 2 : 1;
  }

  for (int i = MathMax(0, prev_calculated - 1); i < rates_total; ++i) {
    // Inserting H/L values into proper slots.
    double _high = MathMax(ExtMapBuffer1[i], ExtMapBuffer2[i]);
    double _low = MathMin(ExtMapBuffer1[i], ExtMapBuffer2[i]);
    ExtMapBuffer1[i] = _high;
    ExtMapBuffer2[i] = _low;
  }

  return _res;
}
